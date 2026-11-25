# Try-it: two files with the same content share one blob. Built by: bash lab try same-blob

build() {
  new_repo .
  put LICENSE.txt <<'EOF'
Free to use for the Git like a pro course.
EOF
  put docs/LICENSE.txt <<'EOF'
Free to use for the Git like a pro course.
EOF
  put README.md <<'EOF'
# Shop
EOF
  commit "Add README and two copies of the license"
}
