---
description: Commit everything in the working tree, pull from GitHub, push it back.
allowed-tools: Bash(./scripts/sync.sh:*)
---

Run `./scripts/sync.sh $ARGUMENTS` from the repo root and report what it did in one or
two lines — commit hash and message, how many commits came down from GitHub, whether the
push succeeded.

If it exits non-zero, say plainly what blocked it (no network, or the same file changed
in both places) and that nothing was lost. Do not attempt the merge resolution yourself
unless Arnav asks.
