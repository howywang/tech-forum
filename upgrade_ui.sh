#!/bin/bash

echo "🚀 Fixing Infinite Scroll (Dcard mode stable version)..."

mkdir -p templates

########################################
# 1. 修 index.html JS（只替換 script）
########################################

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

button {
  background: #3b82f6;
  border: none;
  padding: 6px 10px;
  border-radius: 8px;
  color: white;
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

  console.log("loading page:", page);

  const res = await fetch(`/api/posts?page=${page}`);
  const data = await res.json();

  console.log("data:", data);

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
    window.removeEventListener("scroll", handleScroll);
  }

  page++;
  loading = false;
}

// 🔥 stable scroll detection
function handleScroll() {
  const scrollTop = window.scrollY;
  const windowHeight = window.innerHeight;
  const fullHeight = document.body.offsetHeight;

  if (scrollTop + windowHeight >= fullHeight - 150) {
    loadPosts();
  }
}

window.addEventListener("scroll", handleScroll);

// init
loadPosts();
</script>

</body>
</html>
EOF

echo "✅ Infinite scroll fixed (stable version)"

########################################
# 2. git commit + push
########################################

git add .
git commit -m "fix infinite scroll loading issue" 2>/dev/null
git branch -M main

git push -u origin main

########################################
# done
########################################

echo ""
echo "🎉 DONE!"
echo "👉 Wait Render redeploy (1-2 min)"
echo ""
echo "👉 Then test:"
echo "https://tech-forum-k3m3.onrender.com/"
echo ""