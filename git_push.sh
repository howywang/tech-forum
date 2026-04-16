#!/bin/bash

echo "🚀 Git Auto Push Starting..."

#####################################
# 確認在 git repo
#####################################

if [ ! -d ".git" ]; then
  echo "❌ No git repo found. Initializing..."
  git init
fi

#####################################
# GitHub repo input
#####################################

echo ""
echo "👉 請貼上 GitHub repo URL："
read repo

#####################################
# add
#####################################

echo "📦 Adding files..."
git add .

#####################################
# commit
#####################################

echo "📝 Creating commit..."
git commit -m "auto deploy commit" 2>/dev/null

#####################################
# branch fix
#####################################

git branch -M main

#####################################
# remote handling
#####################################

if git remote get-url origin >/dev/null 2>&1; then
    echo "🔁 Updating remote origin..."
    git remote remove origin
fi

git remote add origin $repo

#####################################
# push
#####################################

echo "🚀 Pushing to GitHub..."

git push -u origin main

#####################################
# done
#####################################

echo ""
echo "✅ DONE!"
echo "👉 If successful, your code is now on GitHub:"
echo $repo
echo ""