# enable-auto-sync.sh — turn on the pull-at-start / push-at-end hooks, once, on this machine.
#
#   ./scripts/enable-auto-sync.sh          install them
#   ./scripts/enable-auto-sync.sh --off    remove them
#
# After this, Claude Code pulls from GitHub when a session opens and pushes whatever
# changed when a reply finishes — including edits you made by hand. Nobody has to remember.

set -euo pipefail

root="$(git rev-parse --show-toplevel)"
example="$root/.claude/settings.sync-hook.example.json"
target="$root/.claude/settings.json"

if [ "${1:-}" = "--off" ]; then
  if [ ! -f "$target" ]; then
    echo "auto-sync: nothing to turn off — $target does not exist."
    exit 0
  fi
  if ! grep -q 'sync\.sh' "$target"; then
    echo "auto-sync: the hooks are not installed in $target — nothing to do."
    exit 0
  fi
  cp "$target" "$target.bak"
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$target" <<'PY'
import json, sys
p = sys.argv[1]
cfg = json.load(open(p))
hooks = cfg.get("hooks", {})
for event in ("SessionStart", "Stop"):
    kept = [g for g in hooks.get(event, [])
            if not any("sync.sh" in h.get("command", "") for h in g.get("hooks", []))]
    if kept:
        hooks[event] = kept
    else:
        hooks.pop(event, None)
if not hooks:
    cfg.pop("hooks", None)
else:
    cfg["hooks"] = hooks
json.dump(cfg, open(p, "w"), indent=2)
open(p, "a").write("\n")
PY
    echo "auto-sync: removed. Backup at .claude/settings.json.bak"
  else
    echo "auto-sync: no python3 here — open $target and delete the SessionStart and Stop"
    echo "auto-sync: blocks that mention sync.sh. Backup at .claude/settings.json.bak"
  fi
  echo "auto-sync: reopen Claude Code (or open /hooks once) for it to take effect."
  exit 0
fi

if [ ! -f "$example" ]; then
  echo "auto-sync: $example is missing — pull the repo first." >&2
  exit 1
fi

if [ ! -f "$target" ]; then
  cp "$example" "$target"
  echo "auto-sync: installed into .claude/settings.json"
elif grep -q 'sync\.sh' "$target"; then
  echo "auto-sync: already installed — nothing to do."
  exit 0
elif command -v python3 >/dev/null 2>&1; then
  cp "$target" "$target.bak"
  python3 - "$target" "$example" <<'PY'
import json, sys
target, example = sys.argv[1], sys.argv[2]
cfg = json.load(open(target))
add = json.load(open(example))["hooks"]
hooks = cfg.setdefault("hooks", {})
for event, groups in add.items():
    hooks.setdefault(event, []).extend(groups)   # merge, never replace
json.dump(cfg, open(target, "w"), indent=2)
open(target, "a").write("\n")
PY
  echo "auto-sync: merged into your existing .claude/settings.json"
  echo "auto-sync: backup at .claude/settings.json.bak"
else
  echo "auto-sync: .claude/settings.json already exists and python3 is not available here."
  echo "auto-sync: copy the \"hooks\" block from this file into it by hand:"
  echo "auto-sync:   $example"
  exit 1
fi

echo "auto-sync: reopen Claude Code (or open /hooks once) so it loads."
echo "auto-sync: pull runs at session start, push runs after each reply."
echo "auto-sync: turn it off any time with ./scripts/enable-auto-sync.sh --off"
