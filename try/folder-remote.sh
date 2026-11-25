# Try-it: use a folder as a remote (the "USB stick"): push to it, clone from it.
# Built by: bash lab try folder-remote. The workspace holds one repo, project; the user makes the rest.

build() {
  new_repo project
  cd project || exit 1
  put README.md <<'EOF'
# Shop
EOF
  commit "Add README"
  put src/price.sh <<'EOF'
TAX_PERCENT=8
EOF
  commit "Add price settings"
}
