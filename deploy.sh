#!/bin/bash

echo "🚀 Tech Forum Deploy Script Starting..."

########################################
# 1. 確保在專案根目錄
########################################

if [ ! -f "app.py" ]; then
  echo "❌ app.py not found. Please run inside project folder."
  exit 1
fi

########################################
# 2. 建立 requirements.txt（保險）
########################################

echo "Flask" > requirements.txt
echo "gunicorn" >> requirements.txt

echo "📦 requirements.txt ready"

########################################
# 3. Git 初始化
########################################

if [ ! -d ".git" ]; then
  git init
  echo "git init done"
fi

########################################
# 4. commit
########################################

git add .
git commit -m "deploy update"

########################################
# 5. 提醒使用者輸入 GitHub repo
########################################

echo ""
echo "👉 下一步你要做："
echo "1. 建立 GitHub repo（例如 tech-forum）"
echo "2. 貼上 repo URL"
echo ""

read -p "Enter your GitHub repo URL: " repo

git branch -M main
git remote remove origin 2>/dev/null
git remote add origin $repo

git push -u origin main

########################################
# 6. Render 部署提示
########################################

echo ""
echo "🌐 GitHub push 完成！"
echo ""
echo "👉 接下來去 Render："
echo "1. New Web Service"
echo "2. connect this repo"
echo "3. Build Command:"
echo "   pip install -r requirements.txt"
echo "4. Start Command:"
echo "   gunicorn app:app"
echo ""

echo "✅ Done!"