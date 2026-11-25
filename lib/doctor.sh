# bash lab doctor: checks tools before the course. Warns, never changes anything.

DOCTOR_PROBLEMS=0
DOCTOR_WARNINGS=0
ok()   { echo "  ok       $*"; }
warn() { echo "  warning  $*"; DOCTOR_WARNINGS=$((DOCTOR_WARNINGS + 1)); }
bad()  { echo "  PROBLEM  $*"; DOCTOR_PROBLEMS=$((DOCTOR_PROBLEMS + 1)); }

run_doctor() {
  local v setting value root
  echo "git-like-a-pro kit $KIT_VERSION"
  echo "System: $(uname -s) $(uname -r)"
  echo "Shell:  bash $BASH_VERSION ($BASH)"
  echo

  echo "Git"
  if command -v git >/dev/null 2>&1; then
    v="$(git --version)"; v="${v#git version }"
    if git_version_ok "$v"; then ok "Git $v"
    else
      bad "Git $v is older than $MIN_GIT_MAJOR.$MIN_GIT_MINOR."
      case "$(uname -s)" in
        Darwin) echo "           Install a newer Git with Homebrew: brew install git (then open a new terminal)" ;;
        MINGW*|MSYS*|CYGWIN*) echo "           Install the latest Git for Windows: https://git-scm.com/download/win" ;;
        *) echo "           Install a newer Git from your package manager or https://git-scm.com/downloads" ;;
      esac
    fi
  else
    bad "Git isn't installed or isn't on your PATH: https://git-scm.com/downloads"
  fi

  if git lfs version >/dev/null 2>&1; then ok "$(git lfs version | head -n 1)"
  else
    warn "git-lfs isn't installed (needed for the LFS part of the air-gap lab)."
    case "$(uname -s)" in
      Darwin) echo "           Install it: brew install git-lfs, then: git lfs install" ;;
      *) echo "           Install it: https://git-lfs.com, then: git lfs install" ;;
    esac
  fi

  echo
  echo "Identity (your name on the commits you make in the labs)"
  if value="$(git config --get user.name 2>/dev/null)" && [ -n "$value" ]; then ok "user.name = $value"
  else bad "user.name isn't set: git config --global user.name \"Your Name\""; fi
  if value="$(git config --get user.email 2>/dev/null)" && [ -n "$value" ]; then ok "user.email = $value"
  else bad "user.email isn't set: git config --global user.email \"you@example.com\""; fi

  echo
  echo "Editor"
  if [ -n "${GIT_EDITOR:-}" ]; then ok "GIT_EDITOR is set: $GIT_EDITOR"
  elif value="$(git config --get core.editor 2>/dev/null)"; then ok "core.editor is set: $value"
  elif command -v code >/dev/null 2>&1; then ok "no Git editor set; labs will use VS Code (code --wait)"
  else
    warn "no Git editor set and VS Code's 'code' command isn't on your PATH, so Git will open vim."
    case "$(uname -s)" in
      Darwin) echo "           In VS Code: Command Palette > Shell Command: Install 'code' command in PATH" ;;
      *) echo "           Add VS Code to your PATH, or set an editor: git config --global core.editor \"code --wait\"" ;;
    esac
  fi

  echo
  echo "Your global settings that labs override in their own repos"
  for setting in pull.rebase rerere.enabled commit.gpgsign tag.gpgsign core.hooksPath core.autocrlf; do
    if value="$(git config --get "$setting" 2>/dev/null)"; then
      echo "  note     $setting = $value"
    fi
  done
  echo "  (Labs set their own values for these, so they won't change the exercises.)"

  echo
  echo "Workspace folder"
  root="$(lab_root)"
  local probe="$root"
  while [ ! -d "$probe" ] && [ "$probe" != "/" ] && [ -n "$probe" ]; do probe="$(dirname "$probe")"; done
  if [ -w "$probe" ]; then ok "$(native_path "$root")$([ -d "$root" ] || echo " (created on first use)")"
  else bad "can't write to $(native_path "$root"); set LAB_HOME to a folder you can write to"; fi
  case "$root" in *OneDrive*|*Documents*) warn "the workspace is under OneDrive or Documents; syncing can lock files. Set LAB_HOME to another folder." ;; esac

  echo
  if [ "$DOCTOR_PROBLEMS" -gt 0 ]; then
    echo "$DOCTOR_PROBLEMS problem(s) to fix before the course, $DOCTOR_WARNINGS warning(s)."
    return 2
  fi
  echo "All set ($DOCTOR_WARNINGS warning(s))."
}
