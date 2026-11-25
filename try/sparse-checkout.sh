# Try-it: check out only the folders you need (cone mode). Built by: bash lab try sparse-checkout
# A small monorepo with four top-level folders.

build() {
  new_repo .
  put README.md <<'EOF2'
# Shop monorepo

web, api, mobile and docs live side by side.
EOF2
  put web/index.html <<'EOF2'
<h1>Shop</h1>
EOF2
  put web/css/site.css <<'EOF2'
h1 { color: navy; }
EOF2
  put api/server.sh <<'EOF2'
echo "API listening"
EOF2
  put api/routes/prices.sh <<'EOF2'
prices() { echo "TAX_PERCENT=8"; }
EOF2
  put mobile/app.txt <<'EOF2'
Mobile app placeholder
EOF2
  put mobile/screens/cart.txt <<'EOF2'
Cart screen
EOF2
  put docs/setup.md <<'EOF2'
# Setup
EOF2
  put docs/api.md <<'EOF2'
# API
EOF2
  commit "Add web, api, mobile and docs"
}
