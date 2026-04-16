#!/bin/bash

echo "🚀 Git Auto Push (Fixed Repo Mode)"

REPO="https://github.com/howywang/tech-forum.git"

#####################################
# init git if needed
#####################################

if [ ! -d ".git" ]; then
  echo "📦 init git repo..."
  git init
fi

#####################################
# add files
#####################################

echo "📦 git add ."
git add .

#####################################
# commit (ignore empty)
#####################################

echo "📝 git commit"
git commit -m "auto update" 2>/dev/null

#####################################
# branch fix
#####################################

git branch -M main

#####################################
# remote setup
#####################################

if git remote get-url origin >/dev/null 2>&1; then
    echo "🔁 reset origin..."
    git remote remove origin
fi

git remote add origin $REPO

#####################################
# push
#####################################

echo "🚀 pushing to GitHub..."
git push -u origin main

echo ""
echo "✅ DONE!"
echo "👉 Repo: $REPO"
echo ""