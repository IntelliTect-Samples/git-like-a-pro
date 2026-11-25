# Try-it: check-ignore -v and rm --cached. Built by: bash lab try ignore-rules
# debug.log was committed before .gitignore said *.log; server.log and build/ are ignored files on disk.

build() {
  new_repo .
  put README.md <<'EOF'
# Shop
EOF
  put debug.log <<'EOF'
debug: started
EOF
  commit "Add README and a debug log"
  put .gitignore <<'EOF'
# Logs, except the one we keep on purpose
*.log
!keep.log

# Build output
build/
EOF
  commit "Ignore logs and build output"
  put server.log <<'EOF'
server: started
EOF
  put keep.log <<'EOF'
Release notes draft
EOF
  commit "Keep keep.log"
  put build/app.js <<'EOF'
console.log("built");
EOF
}
