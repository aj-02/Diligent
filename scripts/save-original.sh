# save-original.sh — file an as-supplied SE80 download into <object>/original/.
#
#   ./scripts/save-original.sh kpmg/zmb5b ~/Downloads/ZRM07MLBD.txt
#   ./scripts/save-original.sh kpmg/zmmims incoming/*.abap
#
# The first copy of a file becomes the baseline and is never overwritten. A later
# download of the same object that DIFFERS is kept alongside it, stamped with today's
# date, and the drift is reported — that is the trail that shows someone edited the
# object in SAP behind us.
#
# Corrected code does NOT go here. It goes in the object folder itself (src/ for
# abapGit objects, loose .abap at the folder root for paste-only ones) and is
# overwritten by each new fix; git history keeps every prior version.

set -euo pipefail

if [ $# -lt 2 ]; then
  sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//' >&2
  exit 2
fi

root="$(git rev-parse --show-toplevel)"
target="$1"; shift
dest="$root/$target/original"

if [ ! -d "$root/$target" ]; then
  echo "save-original: $target is not a folder in this repo." >&2
  echo "save-original: create it first, or check the client/object path." >&2
  exit 1
fi

mkdir -p "$dest"
today="$(date +%Y-%m-%d)"
drift=0

for src in "$@"; do
  if [ ! -f "$src" ]; then
    echo "save-original: no such file: $src" >&2
    exit 1
  fi

  name="$(basename "$src")"
  base="$dest/$name"

  if [ ! -e "$base" ]; then
    cp "$src" "$base"
    echo "baseline  $target/original/$name"
    continue
  fi

  if cmp -s "$src" "$base"; then
    echo "unchanged $target/original/$name — identical to the stored baseline"
    continue
  fi

  # Same object, different content: keep both. Never overwrite a baseline.
  case "$name" in
    *.*) stem="${name%.*}"; ext=".${name##*.}" ;;
    *)   stem="$name";      ext="" ;;
  esac
  snap="$dest/$stem.$today$ext"
  n=2
  while [ -e "$snap" ] && ! cmp -s "$src" "$snap"; do
    snap="$dest/$stem.$today-$n$ext"
    n=$((n + 1))
  done
  cp "$src" "$snap"
  drift=1
  echo "DRIFT     $target/original/$(basename "$snap") — differs from the baseline:"
  diff "$base" "$snap" | head -40 | sed 's/^/          /' || true
done

if [ "$drift" = 1 ]; then
  echo
  echo "save-original: the object changed in SAP since the baseline was taken."
  echo "save-original: review the diff above before applying any new fix."
fi
