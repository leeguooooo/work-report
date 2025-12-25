#!/usr/bin/env bash
set -euo pipefail

root="/Users/leo/tk.com"
repo=""
author=""
period="daily"
since=""
with_repo=0
group_by_repo=0

usage() {
  cat <<'USAGE'
Usage: git_today_commits.sh [--root <path>] [--repo <path>] [--author "Name"]
                            [--period daily|weekly] [--since "expr"] [--with-repo]
                            [--group-by-repo]

Print commit subjects by author across repos (defaults to git config --global user.name).
Only directories containing a .git folder are treated as repos; non-git dirs are ignored.
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --root)
      root="$2"
      shift 2
      ;;
    --repo)
      repo="$2"
      shift 2
      ;;
    --author)
      author="$2"
      shift 2
      ;;
    --period)
      period="$2"
      shift 2
      ;;
    --since)
      since="$2"
      shift 2
      ;;
    --with-repo)
      with_repo=1
      shift 1
      ;;
    --group-by-repo)
      group_by_repo=1
      shift 1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ -z "$since" ]; then
  case "$period" in
    daily) since="midnight" ;;
    weekly) since="1 week ago" ;;
    *)
      echo "Unknown period: $period" >&2
      exit 1
      ;;
  esac
fi

repos=()
if [ -n "$repo" ]; then
  repos=("$repo")
else
  while IFS= read -r gitdir; do
    repos+=("$(dirname "$gitdir")")
  done < <(find "$root" -name .git -type d -prune)
fi

if [ ${#repos[@]} -eq 0 ]; then
  echo "No git repos found under: $root" >&2
  exit 1
fi

if [ -z "$author" ]; then
  author=$(git config --global user.name || true)
  if [ -z "$author" ]; then
    author=$(git config --global user.email || true)
  fi
fi

if [ -z "$author" ]; then
  first_repo="${repos[0]}"
  author=$(git -C "$first_repo" config user.name || true)
  if [ -z "$author" ]; then
    author=$(git -C "$first_repo" config user.email || true)
  fi
fi

for repo_path in "${repos[@]}"; do
  if ! git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not a git repo: $repo_path" >&2
    continue
  fi
  if ! git -C "$repo_path" rev-parse --verify HEAD >/dev/null 2>&1; then
    continue
  fi

  if [ -n "$author" ]; then
    commits=$(git -C "$repo_path" log --since="$since" --author="$author" --pretty=format:%s)
  else
    commits=$(git -C "$repo_path" log --since="$since" --pretty=format:%s)
  fi

  if [ -z "$commits" ]; then
    continue
  fi

  if [ "$group_by_repo" -eq 1 ]; then
    printf '%s\n' "$(basename "$repo_path")"
    printf '%s\n' "$commits" | while IFS= read -r line; do
      if [ -n "$line" ]; then
        printf '%s\n' "- $line"
      fi
    done
    continue
  fi

  printf '%s\n' "$commits" | while IFS= read -r line; do
    if [ -z "$line" ]; then
      continue
    fi
    if [ "$with_repo" -eq 1 ]; then
      printf '[%s] %s\n' "$(basename "$repo_path")" "$line"
    else
      printf '%s\n' "$line"
    fi
  done
done
