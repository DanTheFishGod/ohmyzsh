# Update master from upstream, keep custom branch as the only place for local changes,
# and optionally push the rewritten branch tips to your fork via origin.
#
# Safe usage:
#   omz-customupdate             # upstream -> master -> custom; push origin/master + origin/custom
#   omz-customupdate --fork-only # align local master/custom to origin without pushing
#   omz-customupdate --client    # read-only client: sync local custom to origin/custom without pushing
#   omz-customupdate --help      # show usage

omz-customupdate() {
  local mode="sync"
  local original_branch

  case "${1:-}" in
    --fork-only|-f)
      mode="fork-only"
      ;;
    --client|-c)
      mode="client"
      ;;
    --help|-h)
      echo "Usage: omz-customupdate [--fork-only|--client]"
      echo ""
      echo "  --fork-only  Fetch origin and align local master/custom to origin without pushing."
      echo "  --client     Read-only client sync: fetch origin and align local custom to origin/custom."
      echo "  default      Upstream sync: update master from upstream, rebase custom, and push origin/master + origin/custom."
      return 0
      ;;
    "")
      mode="sync"
      ;;
    *)
      echo "omz-customupdate: unknown option: $1" >&2
      echo "Use --help for usage." >&2
      return 1
      ;;
  esac

  if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "omz-customupdate: not inside a git repository" >&2
    return 1
  fi

  if ! git diff --quiet --ignore-submodules HEAD -- || ! git diff --cached --quiet --ignore-submodules HEAD -- || [[ -n "$(git ls-files --others --exclude-standard)" ]]; then
    echo "omz-customupdate: working tree must be clean before syncing branches" >&2
    echo "Commit or stash your changes first." >&2
    return 1
  fi

  original_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  if [[ -z "$original_branch" ]]; then
    echo "omz-customupdate: could not determine the current branch" >&2
    return 1
  fi

  if [[ "$mode" == "client" ]]; then
    if ! git remote get-url origin >/dev/null 2>&1; then
      echo "omz-customupdate: origin remote is not configured" >&2
      return 1
    fi

    echo "[omz-customupdate] Fetching origin for read-only client sync..."
    git fetch origin --prune || return 1

    if git show-ref --verify --quiet refs/remotes/origin/master; then
      echo "[omz-customupdate] Fast-forwarding master to origin/master..."
      git checkout master || return 1
      git merge --ff-only origin/master || return 1
    else
      echo "[omz-customupdate] origin/master not found; skipping master update."
    fi

    echo "[omz-customupdate] Resetting custom to origin/custom..."
    git checkout custom || {
      git checkout -B custom origin/custom || return 1
      git checkout custom || return 1
    }
    git reset --hard origin/custom || return 1

    if [[ "$original_branch" != "custom" ]]; then
      git checkout "$original_branch" || return 1
    fi

    echo "[omz-customupdate] Done. This client host is synced to the fork's custom branch without pushing."
    return 0
  fi

  if [[ "$mode" == "fork-only" ]]; then
    if ! git remote get-url origin >/dev/null 2>&1; then
      echo "omz-customupdate: origin remote is not configured" >&2
      return 1
    fi

    echo "[omz-customupdate] Fetching origin..."
    git fetch origin --prune || return 1

    echo "[omz-customupdate] Fast-forwarding master to origin/master..."
    git checkout master || return 1
    git merge --ff-only origin/master || return 1

    echo "[omz-customupdate] Resetting custom to origin/custom..."
    git checkout custom || {
      git checkout -B custom origin/custom || return 1
      git checkout custom || return 1
    }
    git reset --hard origin/custom || return 1

    if [[ "$original_branch" != "custom" ]]; then
      git checkout "$original_branch" || return 1
    fi

    echo "[omz-customupdate] Done. local master/custom now match the fork."
    return 0
  fi

  if ! git remote get-url upstream >/dev/null 2>&1; then
    echo "omz-customupdate: upstream remote is not configured" >&2
    return 1
  fi

  if ! git remote get-url origin >/dev/null 2>&1; then
    echo "omz-customupdate: origin remote is not configured" >&2
    return 1
  fi

  echo "[omz-customupdate] Fetching upstream and origin..."
  git fetch upstream --prune || return 1
  git fetch origin --prune || return 1

  echo "[omz-customupdate] Updating master from upstream/master..."
  git checkout master || return 1
  git rebase upstream/master || return 1
  git push origin master --force-with-lease || return 1

  echo "[omz-customupdate] Rebuilding custom on top of master..."
  git checkout custom || return 1
  git rebase master || return 1
  git push origin custom --force-with-lease || return 1

  if [[ "$original_branch" != "custom" ]]; then
    git checkout "$original_branch" || return 1
  fi

  echo "[omz-customupdate] Done. master tracks upstream, custom holds local customizations, and origin is updated."
}
