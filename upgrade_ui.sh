#!/bin/bash

echo "🎨 Upgrading Tech Forum UI..."

########################################
# 檢查資料夾
########################################

if [ ! -d "templates" ]; then
  echo "❌ templates folder not found"
  exit 1
fi

########################################
# index.html（科技風 UI）
########################################

cat <<'EOF' > templates/index.html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>科技業論壇</title>

  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI";
      background: #0f172a;
      color: #e2e8f0;
      margin: 0;
      padding: 0;
    }

    .container {
      max-width: 800px;
      margin: auto;
      padding: 20px;
    }

    h1 {
      text-align: center;
      font-size: 28px;
    }

    .card {
      background: #1e293b;
      padding: 16px;
      border-radius: 12px;
      margin-bottom: 12px;
      box-shadow: 0 4px 10px rgba(0,0,0,0.3);
    }

    input, textarea {
      width: 100%;
      padding: 10px;
      margin-top: 8px;
      margin-bottom: 8px;
      border-radius: 8px;
      border: none;
      background: #334155;
      color: white;
    }

    button {
      background: #38bdf8;
      border: none;
      padding: 10px 14px;
      border-radius: 8px;
      cursor: pointer;
      font-weight: bold;
    }

    button:hover {
      background: #0ea5e9;
    }

    a {
      color: #38bdf8;
      text-decoration: none;
    }

    .post-title {
      font-size: 18px;
      font-weight: bold;
    }

    .meta {
      font-size: 12px;
      color: #94a3b8;
    }
  </style>
</head>

<body>
  <div class="container">

    <h1>🚀 科技業論壇</h1>

    <div class="card">
      <form method="POST" action="/post">
        <input name="title" placeholder="標題">
        <textarea name="content" placeholder="發文內容"></textarea>
        <button type="submit">發文</button>
      </form>
    </div>

    {% for p in posts %}
    <div class="card">
      <div class="post-title">
        <a href="/post/{{p['id']}}">{{p['title']}}</a>
      </div>

      <div class="meta">
        👍 {{p['score']}} | ID {{p['id']}}
      </div>

      <p>{{p['content']}}</p>

      <a href="/upvote/{{p['id']}}">+1 👍</a>
    </div>
    {% endfor %}

  </div>
</body>
</html>
EOF

########################################
# post.html（科技風）
########################################

cat <<'EOF' > templates/post.html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>貼文</title>

  <style>
    body {
      font-family: -apple-system;
      background: #0f172a;
      color: white;
      padding: 20px;
    }

    .box {
      max-width: 700px;
      margin: auto;
      background: #1e293b;
      padding: 20px;
      border-radius: 12px;
    }

    textarea {
      width: 100%;
      height: 80px;
      margin-top: 10px;
      background: #334155;
      color: white;
      border: none;
      border-radius: 8px;
      padding: 10px;
    }

    button {
      margin-top: 10px;
      background: #38bdf8;
      border: none;
      padding: 8px 12px;
      border-radius: 8px;
      font-weight: bold;
    }

    .comment {
      background: #0f172a;
      padding: 10px;
      margin-top: 8px;
      border-radius: 8px;
    }

    a {
      color: #38bdf8;
    }
  </style>
</head>

<body>

<div class="box">

  <a href="/">← 回首頁</a>

  <h2>{{post['title']}}</h2>
  <p>{{post['content']}}</p>

  <hr>

  <h3>留言</h3>

  {% for c in comments %}
    <div class="comment">
      💬 {{c['text']}}
    </div>
  {% endfor %}

  <form method="POST" action="/comment/{{post['id']}}">
    <textarea name="text" placeholder="寫留言..."></textarea>
    <br>
    <button>留言</button>
  </form>

</div>

</body>
</html>
EOF

########################################
# 完成提示
########################################

echo ""
echo "✅ UI upgrade completed!"
echo ""
echo "👉 Please restart server:"
echo "python3 app.py"
echo ""