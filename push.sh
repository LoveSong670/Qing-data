#!/bin/sh
# 用法: sh push.sh <GitHub用户名> <token> [仓库名]
set -e
U=${1:?need user}
T=${2:?need token}
R=${3:-Qing-data}
git init -q 2>/dev/null || true
git add -A
git -c user.email=x@x -c user.name=x commit -qm data || true
git branch -M main
git remote remove origin 2>/dev/null || true
git remote add origin "https://$U:$T@github.com/$U/$R.git"
git push -u origin main
