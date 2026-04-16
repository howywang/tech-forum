#!/bin/bash

echo "🚀 Full Upgrade: Dcard UI + API + Infinite Scroll"

#####################################
# 1. 修改 app.py（自動加 API）
#####################################

if ! grep -q "/api/posts" app.py; then

cat <<'EOF' >> app.py


from flask import jsonify

@app.route("/api/posts")
def api_posts():
    page = int(request.args.get("page", 0))
    limit = 10
    offset = page * limit

    db = get_db()
    posts = db.execute(
        "SELECT * FROM posts ORDER BY id DESC LIMIT ? OFFSET ?",
        (limit, offset)
    ).fetchall()

    return jsonify([dict(p) for p in posts])
EOF

echo "✅ API added to app.py"
else
echo "⚠️ API already exists, skip"
fi

#####################################
# 2. 重寫 index.html（Dcard UI + infinite scroll）
#####################################

mkdir -p templates

cat <<'EOF' > templates/index.html
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>科技論壇</title>

<style>
body {
  margin: 0;
  font-family: -apple-system;
  background: #0b1220;
  color: #e5e7eb;
}

.container {
  max-width: 700px;
  margin: auto;
  padding: 20px;
}

h1 {
  text-align: center;
}

.card {
  background: #111827;
  padding: 16px;
  border-radius: 14px;
  margin-bottom: 12px;
}

.title {
  font-size: 18px;
  color: #60a5fa;
  font-weight: bold;
}

.meta {
  font-size: 12px;
  color: #9ca3af;
}

.content {
  margin-top: 8px;
}

button {
  background: #3b82f6;
  border: none;
  padding: 6px 10px;
  border-radius: 8px;
  color: white;
  cursor: pointer;
}

#loader {
  text-align: center;
  padding: 20px;
  color: #9ca3af;
}
</style>
</head>

<body>

<div class="container">
  <h1>🚀 科技論壇</h1>

  <div id="posts"></div>
  <div id="loader">載入中...</div>
</div>

<script>
let page = 0;
let loading = false;

async function loadPosts() {
  if (loading) return;
  loading = true;

  const res = await fetch(`/api/posts?page=${page}`);
  const data = await res.json();

  const container = document.getElementById("posts");

  data.forEach(p => {
    const div = document.createElement("div");
    div.className = "card";

    div.innerHTML = `
      <div class="title">${p.title}</div>
      <div class="meta">👍 ${p.score} | ID ${p.id}</div>
      <div class="content">${p.content}</div>
      <a href="/upvote/${p.id}"><button>+1</button></a>
    `;

    container.appendChild(div);
  });

  if (data.length === 0) {
    document.getElementById("loader").innerText = "沒有更多文章";
  }

  page++;
  loading = false;
}

window.addEventListener("scroll", () => {
  if (window.innerHeight + window.scrollY >= document.body.offsetHeight - 200) {
    loadPosts();
  }
});

loadPosts();
</script>

</body>
</html>
EOF

echo "✅ UI replaced with Dcard infinite scroll"
#####################################

echo ""
echo "🎉 FULL UPGRADE DONE"
echo ""
echo "👉 Run:"
echo "python3 app.py"
echo ""