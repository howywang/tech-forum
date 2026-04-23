#!/bin/bash

echo "🧪 Deploying DEBUG Infinite Scroll Version..."

mkdir -p templates

cat <<'EOF' > templates/index.html
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>科技論壇 DEBUG MODE</title>

<style>
body {
  margin: 0;
  font-family: monospace;
  background: #0b1220;
  color: #e5e7eb;
}

.container {
  max-width: 800px;
  margin: auto;
  padding: 20px;
}

.card {
  background: #111827;
  padding: 12px;
  margin-bottom: 10px;
  border-radius: 10px;
}

.title { color: #60a5fa; font-weight: bold; }

.debug {
  background: #1f2937;
  padding: 10px;
  margin-bottom: 10px;
  border-radius: 10px;
  font-size: 12px;
  color: #fbbf24;
}

#error {
  color: red;
  white-space: pre-wrap;
}
</style>
</head>

<body>

<div class="container">

<h2>🚀 DEBUG MODE - Infinite Scroll</h2>

<div class="debug">
  page: <span id="page">0</span><br>
  loading: <span id="loading">false</span><br>
  status: <span id="status">idle</span>
</div>

<div id="error"></div>

<div id="posts"></div>
<div id="loader">載入中...</div>

</div>

<script>

let page = 0;
let loading = false;
let consecutiveFailures = 0;
const MAX_RETRIES = 5;
const MAX_RETRY_DELAY_MS = 8000;
const FETCH_TIMEOUT_MS = 5000;

function showError(msg) {
  document.getElementById("error").innerText = msg;
}

function clearError() {
  document.getElementById("error").innerText = "";
}

function scheduleRetry(delayMs, reason) {
  if (consecutiveFailures >= MAX_RETRIES) {
    showError(`${reason}\n已達最大重試次數 (${MAX_RETRIES})，請重新整理頁面`);
    updateDebug("max retries exceeded");
    return;
  }

  const delaySec = Math.round(delayMs / 1000);
  updateDebug(`retry in ${delaySec}s`);
  showError(`${reason}\n${delaySec} 秒後自動重試...`);
  setTimeout(() => {
    loadPosts();
  }, delayMs);
}

function renderPost(container, post) {
  const card = document.createElement("div");
  card.className = "card";

  const title = document.createElement("div");
  title.className = "title";
  title.textContent = post.title ?? "(無標題)";

  const id = document.createElement("div");
  id.textContent = `ID: ${post.id ?? "-"}`;

  const score = document.createElement("div");
  score.textContent = `score: ${post.score ?? 0}`;

  const content = document.createElement("div");
  content.textContent = post.content ?? "";

  card.appendChild(title);
  card.appendChild(id);
  card.appendChild(score);
  card.appendChild(content);
  container.appendChild(card);
}

function updateDebug(statusText) {
  document.getElementById("page").innerText = page;
  document.getElementById("loading").innerText = loading;
  document.getElementById("status").innerText = statusText;
}

async function loadPosts() {
  if (loading) {
    updateDebug("blocked (loading=true)");
    return;
  }

  loading = true;
  updateDebug("fetching API...");

  try {
    console.log("FETCH page:", page);

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), FETCH_TIMEOUT_MS);

    let res;
    try {
      res = await fetch(`/api/posts?page=${page}`, {
        headers: {
          "Accept": "application/json"
        },
        signal: controller.signal
      });
    } finally {
      clearTimeout(timeoutId);
    }

    updateDebug("status: " + res.status);

    const text = await res.text();
    console.log("RAW RESPONSE:", text);

    let data;
    try {
      data = JSON.parse(text);
    } catch (e) {
      showError("JSON PARSE ERROR:\n" + text);
      loading = false;
      consecutiveFailures += 1;
      scheduleRetry(Math.min(MAX_RETRY_DELAY_MS, 1000 * consecutiveFailures), "回應不是 JSON");
      return;
    }

    if (!res.ok) {
      const msg = `${data?.error || "API Error"}${data?.error_description ? `\n${data.error_description}` : ""}`;
      loading = false;
      consecutiveFailures += 1;
      scheduleRetry(Math.min(MAX_RETRY_DELAY_MS, 1000 * consecutiveFailures), msg);
      return;
    }

    if (!Array.isArray(data)) {
      const msg = `${data?.error || "API 回傳格式錯誤"}${data?.error_description ? `\n${data.error_description}` : ""}`;
      loading = false;
      consecutiveFailures += 1;
      scheduleRetry(Math.min(MAX_RETRY_DELAY_MS, 1000 * consecutiveFailures), msg);
      return;
    }

    const container = document.getElementById("posts");
    if (!container) {
      loading = false;
      showError("錯誤：找不到貼文容器元素");
      updateDebug("dom error");
      return;
    }

    try {
      data.forEach(p => renderPost(container, p));
    } catch (renderErr) {
      loading = false;
      const message = renderErr instanceof Error ? renderErr.message : String(renderErr);
      showError(`渲染錯誤: ${message}`);
      updateDebug("render error");
      return;
    }

    if (data.length === 0) {
      document.getElementById("loader").innerText = "NO MORE DATA";
    }

    clearError();
    consecutiveFailures = 0;
    page++;
    loading = false;
    updateDebug("done");

  } catch (err) {
    loading = false;
    consecutiveFailures += 1;
    const message = err instanceof Error ? err.message : String(err);
    scheduleRetry(Math.min(MAX_RETRY_DELAY_MS, 1000 * consecutiveFailures), `網路錯誤: ${message}`);
  }
}

function handleScroll() {
  const scrollTop = window.scrollY;
  const windowHeight = window.innerHeight;
  const fullHeight = document.body.offsetHeight;

  if (scrollTop + windowHeight >= fullHeight - 200) {
    loadPosts();
  }
}

window.addEventListener("scroll", handleScroll);

loadPosts();

</script>

</body>
</html>
EOF

echo "✅ DEBUG MODE deployed"

git add .
git commit -m "debug infinite scroll mode" 2>/dev/null
git push -u origin main

echo ""
echo "🎯 DONE - DEBUG MODE LIVE"
echo "👉 Wait Render redeploy (1-2 min)"
echo ""
echo "👉 Then open:"
echo "https://tech-forum-k3m3.onrender.com/"
echo ""
echo "👉 You will now see:"
echo "- page number"
echo "- loading state"
echo "- API status"
echo "- raw response"
echo "- errors if any"
echo ""