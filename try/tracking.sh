# Try-it: main vs. origin/main after a teammate pushes. Built by: bash lab try tracking
# Workspace: origin.git (the shared remote), me (your clone), teammate (Alex's clone)
# and teammate.sh, which makes Alex commit and push one change.

tracking_script() {
  put teammate.sh <<'EOF'
#!/usr/bin/env bash
# Plays your teammate Alex: commits one change in ./teammate and pushes it to origin.git.
set -e
cd "$(dirname "$0")/teammate"
if grep -q FREE_SHIPPING_FROM src/price.sh; then
  echo "Alex already pushed: $(git log -1 --format='%h %s')"
  exit 0
fi
export GIT_AUTHOR_NAME="Alex Teammate" GIT_AUTHOR_EMAIL="alex@example.com"
export GIT_COMMITTER_NAME="Alex Teammate" GIT_COMMITTER_EMAIL="alex@example.com"
export GIT_AUTHOR_DATE="1767312000 +0000" GIT_COMMITTER_DATE="1767312000 +0000"
echo "FREE_SHIPPING_FROM=5000" >> src/price.sh
git -c commit.gpgsign=false commit -q -am "Add free shipping threshold"
git push -q origin main
echo "Alex pushed: $(git log -1 --format='%h %s')"
EOF
}

build() {
  new_repo seed
  (
    cd seed || exit 1
    put README.md <<'EOF'
# Shop
EOF
    commit "Add README"
    put src/price.sh <<'EOF'
TAX_PERCENT=8
SHIPPING=500
EOF
    commit "Add price settings"
  )
  git init -q --bare -b main origin.git
  git -C seed push -q ../origin.git main
  rm -rf seed
  git clone -q origin.git me
  git clone -q origin.git teammate
  tracking_script
}
