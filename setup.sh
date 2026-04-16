#!/bin/bash

echo "🚀 Creating Render-ready Flask forum..."

PROJECT="tech-forum"

rm -rf $PROJECT
mkdir $PROJECT
cd $PROJECT

mkdir templates
mkdir static

###################################
# requirements.txt
###################################

cat <<EOF > requirements.txt
flask
gunicorn
EOF

###################################
# app.py (Render correct version)
###################################

cat <<EOF > app.py
from flask import Flask, render_template, request, redirect
import sqlite3
import os

app = Flask(__name__)

DB = "forum.db"

def get_db():
    conn = sqlite3.connect(DB)
    conn.row_factory = sqlite3.Row
    return conn

@app.route("/")
def index():
    db = get_db()
    posts = db.execute("SELECT * FROM posts ORDER BY id DESC").fetchall()
    return render_template("index.html", posts=posts)

@app.route("/post", methods=["POST"])
def create_post():
    title = request.form["title"]
    content = request.form["content"]

    db = get_db()
    db.execute("INSERT INTO posts (title, content, score) VALUES (?, ?, 0)", (title, content))
    db.commit()

    return redirect("/")

@app.route("/post/<int:post_id>")
def post(post_id):
    db = get_db()

    post = db.execute("SELECT * FROM posts WHERE id=?", (post_id,)).fetchone()
    comments = db.execute("SELECT * FROM comments WHERE post_id=?", (post_id,)).fetchall()

    return render_template("post.html", post=post, comments=comments)

@app.route("/comment/<int:post_id>", methods=["POST"])
def comment(post_id):
    text = request.form["text"]

    db = get_db()
    db.execute("INSERT INTO comments (post_id, text) VALUES (?, ?)", (post_id, text))
    db.commit()

    return redirect(f"/post/{post_id}")

@app.route("/upvote/<int:post_id>")
def upvote(post_id):
    db = get_db()
    db.execute("UPDATE posts SET score = score + 1 WHERE id=?", (post_id,))
    db.commit()
    return redirect("/")

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
EOF

###################################
# index.html
###################################

cat <<EOF > templates/index.html
<h1>科技論壇 MVP</h1>

<form method="POST" action="/post">
  <input name="title" placeholder="標題" required>
  <br>
  <textarea name="content" placeholder="內容" required></textarea>
  <br>
  <button type="submit">發文</button>
</form>

<hr>

{% for p in posts %}
  <div>
    <h3><a href="/post/{{p['id']}}">{{p['title']}}</a></h3>
    👍 {{p['score']}}
    <a href="/upvote/{{p['id']}}">+1</a>
    <p>{{p['content']}}</p>
  </div>
  <hr>
{% endfor %}
EOF

###################################
# post.html
###################################

cat <<EOF > templates/post.html
<h2>{{post['title']}}</h2>

<p>{{post['content']}}</p>

<hr>

<h3>留言</h3>

{% for c in comments %}
  <p>💬 {{c['text']}}</p>
{% endfor %}

<form method="POST" action="/comment/{{post['id']}}">
  <textarea name="text" required></textarea>
  <br>
  <button>留言</button>
</form>

<br>
<a href="/">回首頁</a>
EOF

###################################
# database init
###################################

python3 <<EOF
import sqlite3

conn = sqlite3.connect("forum.db")
cur = conn.cursor()

cur.execute("""
CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    content TEXT,
    score INTEGER
)
""")

cur.execute("""
CREATE TABLE IF NOT EXISTS comments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    post_id INTEGER,
    text TEXT
)
""")

conn.commit()
conn.close()
EOF

###################################
# git init
###################################

git init
git add .
git commit -m "render-ready flask forum"

echo ""
echo "✅ DONE!"
echo ""
echo "Next steps:"
echo "1. git remote add origin <your github repo>"
echo "2. git push -u origin main"
echo "3. Deploy on Render:"
echo "   Start: gunicorn app:app"
echo ""