# Rebase custom on top of the latest upstream/master and push both branches.
# This keeps master clean and preserves only the customizations on custom.
omz-customupdate() {
  local original_branch

  if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "omz-customupdate: not inside a git repository" >&2
    return 1
  fi

  original_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  if [[ -z "$original_branch" ]]; then
    echo "omz-customupdate: could not determine the current branch" >&2
    return 1
  fi

  if ! git remote get-url upstream >/dev/null 2>&1; then
    echo "omz-customupdate: upstream remote is not configured" >&2
    return 1
  fi

  if ! git remote get-url origin >/dev/null 2>&1; then
    echo "omz-customupdate: origin remote is not configured" >&2
    return 1
  fi

  echo "[omz-customupdate] Updating master from upstream/master..."
  git checkout master || return 1
  git fetch upstream || return 1
  git rebase upstream/master || return 1
  git push origin master --force-with-lease || return 1

  echo "[omz-customupdate] Rebuilding custom on top of master..."
  git checkout custom || return 1
  git rebase master || return 1
  git push origin custom --force-with-lease || return 1

  if [[ "$original_branch" != "custom" ]]; then
    git checkout "$original_branch" || return 1
  fi

  echo "[omz-customupdate] Done. master and custom are aligned with upstream and custom still contains only your local customizations."
}
