# Try-it: rerere records how you resolved a conflict and replays it next time.
# Built by: bash lab try rerere

build() {
  new_repo .
  put greeting.txt <<'EOF'
Welcome to the shop.
Open Monday to Friday.
EOF
  commit "Add the greeting"
  git switch -q -c feature
  put greeting.txt <<'EOF'
Welcome to the shop, friend.
Open Monday to Friday.
EOF
  commit "Make the greeting friendlier"
  git switch -q main
  put greeting.txt <<'EOF'
Welcome to our shop.
Open Monday to Friday.
EOF
  commit "Say our shop"
  git switch -q feature
}
