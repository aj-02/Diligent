#!/usr/bin/env bash
# sync.sh — one command: commit everything local, pull what's on GitHub, push it back.
#
#   ./scripts/sync.sh                     commit + pull + push, auto-written message
#   ./scripts/sync.sh "ZMB5B qty fix"     same, with your own commit message
#   ./scripts/sync.sh --no-push           commit + pull only, leave the push for later
#   ./scripts/sync.sh --pull-only         no commit, no push — just bring the repo up to date
#
# Safe to run when there is nothing to do: it says so and exits 0.

set -euo pipefail

msg=""
do_commit=1
do_push=1

while [ $# -gt 0 ]; do
  case "$1" in
    --no-push)   do_push=0 ;;
    --pull-only) do_commit=0; do_push=0 ;;
    -h|--help)   sed -n '2,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)          echo "sync: unknown option $1" >&2; exit 2 ;;
    *)           msg="${msg:+$msg }$1" ;;
  esac
  shift
done

root="$(git rev-parse --show-toplevel)"
cd "$root"
branch="$(git rev-parse --abbrev-ref HEAD)"

if [ "$branch" = "HEAD" ]; then
  echo "sync: detached HEAD — check out a branch first." >&2
  exit 1
fi

if [ -d .git/rebase-merge ] || [ -d .git/rebase-apply ] || [ -f .git/MERGE_HEAD ]; then
  echo "sync: a rebase or merge is already in progress. Finish or abort it first." >&2
  exit 1
fi

echo "sync: branch $branch"

# ------------------------------------------------------- 0. commit identity
# GitHub counts a commit towards the profile contribution graph only when the
# AUTHOR email is verified on the GitHub account. A Claude Code session commits
# as Claude <noreply@anthropic.com>, which GitHub attributes to the @claude
# account instead — so work done in a session never appeared on Arnav's profile.
# Re-stamp the identity when it is unset or is Anthropic's default; a real
# identity (Arnav's own laptop) is left untouched.
current_email="$(git config user.email 2>/dev/null || true)"
case "$current_email" in
  ""|*@anthropic.com)
    git config user.name  "Arnav Johri"
    git config user.email "82252072+aj-02@users.noreply.github.com"
    echo "sync: commit identity set to Arnav Johri <82252072+aj-02@users.noreply.github.com>"
    ;;
esac

# ---------------------------------------------------------------- 1. commit
if [ "$do_commit" = 1 ]; then
  git add -A
  if git diff --cached --quiet; then
    echo "sync: nothing new to commit"
  else
    count="$(git diff --cached --name-only | wc -l | tr -d ' ')"
    if [ -z "$msg" ]; then
      areas="$(git diff --cached --name-only | cut -d/ -f1 | sort -u | paste -sd', ' -)"
      msg="Auto-sync: $count file(s) — $areas"
    fi
    git commit -q -m "$msg" -m "$(git diff --cached --name-status)"
    echo "sync: committed $count file(s) — $(git log -1 --format=%h) $msg"
  fi
fi

# ------------------------------------------------------------------ 2. pull
# --prune also clears stale origin/* refs for branches deleted on GitHub, so the
# "does this branch exist on origin?" test below is answered against reality.
fetched=0
for delay in 2 4 8 16 0; do
  if git fetch --prune --quiet origin; then fetched=1; break; fi
  [ "$delay" = 0 ] && break
  echo "sync: could not reach GitHub, retrying in ${delay}s..."
  sleep "$delay"
done

if [ "$fetched" = 0 ]; then
  echo "sync: could not reach GitHub. Your work is committed locally — re-run when the network is back." >&2
  exit 1
fi

if git rev-parse --verify --quiet "origin/$branch" >/dev/null; then
  behind="$(git rev-list --count "HEAD..origin/$branch")"
  if [ "$behind" -gt 0 ]; then
    echo "sync: pulling $behind commit(s) from origin/$branch"
    if ! git rebase --quiet --autostash "origin/$branch"; then
      git rebase --abort || true
      echo "sync: the same file changed here and on GitHub — automatic merge refused." >&2
      echo "sync: nothing was lost; your commit is intact. Resolve with:" >&2
      echo "        git pull --rebase origin $branch" >&2
      exit 1
    fi
  else
    echo "sync: already up to date with origin/$branch"
  fi
else
  echo "sync: origin/$branch does not exist yet — it will be created on push"
fi

# ------------------------------------------------------------------ 3. push
if [ "$do_push" = 0 ]; then
  echo "sync: push skipped"
  exit 0
fi

ahead="$(git rev-list --count "origin/$branch..HEAD" 2>/dev/null || echo 1)"
if [ "$ahead" = "0" ]; then
  echo "sync: nothing to push — everything is on GitHub"
  exit 0
fi

for delay in 2 4 8 16 0; do
  if git push -u origin "$branch"; then
    echo "sync: pushed $ahead commit(s) to origin/$branch"
    exit 0
  fi
  [ "$delay" = 0 ] && break
  echo "sync: push failed, retrying in ${delay}s..."
  sleep "$delay"
done

echo "sync: push failed. Your work is committed locally — re-run ./scripts/sync.sh when you can." >&2
exit 1
