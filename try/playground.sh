# Playground: a small repo to experiment in. Built by: bash lab play

build() {
  new_repo .
  put README.md <<'EOF'
# Playground

Experiment freely here. Reset it any time with: bash lab play
EOF
  commit "Add README"
  put notes.txt <<'EOF'
first note
EOF
  commit "Add notes"
  echo "second note" >> notes.txt
  commit "Add a second note"
  git switch -q -c feature
  put feature.txt <<'EOF'
work in progress
EOF
  commit "Start the feature"
  echo "more work" >> feature.txt
  commit "Continue the feature"
  git switch -q main
  echo "third note" >> notes.txt
  commit "Add a third note"
}
