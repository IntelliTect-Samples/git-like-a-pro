# Try-it: a shared commit-msg hook that requires a ticket key like PROJ-123.
# Built by: bash lab try commit-msg-hook
# The hook is tracked in .githooks with the executable bit, so it runs on macOS and Linux after a
# clone. Git for Windows ignores the bit and runs any hook file that starts with #!.

build() {
  new_repo .
  put README.md <<'EOF2'
# Shop

Prices are in cents.
EOF2
  put notes.txt <<'EOF2'
Ideas for the shop
EOF2
  commit "Add README and notes"
  put .githooks/commit-msg <<'EOF2'
#!/bin/sh
# Shared commit-msg hook. Git runs it with the path of the message file as $1.
# Exit non-zero to stop the commit.

if grep -v '^#' "$1" | grep -qE '[A-Z][A-Z0-9]+-[0-9]+'; then
  exit 0
fi

echo "commit-msg hook: add a ticket key like PROJ-123 to your commit message." >&2
exit 1
EOF2
  chmod +x .githooks/commit-msg
  git add --chmod=+x .githooks/commit-msg
  commit "Add a shared commit-msg hook"
}
