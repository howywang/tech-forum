from flask import Flask, render_template, request, redirect, jsonify
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

    db.execute("""
    CREATE TABLE IF NOT EXISTS posts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        score INTEGER DEFAULT 0
    )
    """)

    db.commit()

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


@app.route("/upvote/<int:post_id>")
def upvote(post_id):
    db = get_db()
    db.execute("UPDATE posts SET score = score + 1 WHERE id=?", (post_id,))
    db.commit()
    return redirect("/")


@app.route("/api/posts")
def api_posts():
    try:
        page = int(request.args.get("page", 0))
        limit = 10
        offset = page * limit

        db = get_db()

        db.execute("""
        CREATE TABLE IF NOT EXISTS posts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            content TEXT,
            score INTEGER DEFAULT 0
        )
        """)
        db.commit()

        posts = db.execute(
            "SELECT * FROM posts ORDER BY id DESC LIMIT ? OFFSET ?",
            (limit, offset)
        ).fetchall()

        return jsonify([dict(p) for p in posts])

    except Exception as e:
        print("API ERROR:", e)
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
