# Try-it: see which file each setting comes from. Built by: bash lab try config-origin
# The repo sets its own user.email, as you might for a work repo on a personal laptop.

build() {
  new_repo .
  put README.md <<'EOF'
# Shop
EOF
  commit "Add README"
  git config user.email "sam@work.example.com"
}
