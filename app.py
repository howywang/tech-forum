from flask import Flask, render_template, request, redirect
import sqlite3

app = Flask(__name__)

def get_db():
    return sqlite3.connect("forum.db")

@app.route("/")
def index():
    db = get_db()
    posts = db.execute("SELECT * FROM posts").fetchall()
    return render_template("index.html", posts=posts)

@app.route("/post", methods=["POST"])
def post():
    title = request.form["title"]
    content = request.form["content"]

    db = get_db()
    db.execute("INSERT INTO posts (title,content,score) VALUES (?,?,0)", (title,content))
    db.commit()

    return redirect("/")

@app.route("/post/<int:id>")
def view_post(id):
    db = get_db()
    post = db.execute("SELECT * FROM posts WHERE id=?", (id,)).fetchone()
    comments = db.execute("SELECT * FROM comments WHERE post_id=?", (id,)).fetchall()

    return render_template("post.html", post=post, comments=comments)

@app.route("/comment/<int:id>", methods=["POST"])
def comment(id):
    text = request.form["text"]

    db = get_db()
    db.execute("INSERT INTO comments (post_id,text) VALUES (?,?)", (id,text))
    db.commit()

    return redirect(f"/post/{id}")

@app.route("/upvote/<int:id>")
def upvote(id):
    db = get_db()
    db.execute("UPDATE posts SET score = score + 1 WHERE id=?", (id,))
    db.commit()

    return redirect("/")

if __name__ == "__main__":
    app.run(debug=True)
