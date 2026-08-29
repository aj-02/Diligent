#!/usr/bin/env bash
# find-download.sh — locate an SE80 download in ~/Downloads by program name.
#
#   .claude/skills/solve/find-download.sh ZJVTB
#   .claude/skills/solve/find-download.sh ZAA_IMPAIRMENTLOSS
#
# Prints one candidate per line, newest first:  <mtime>  <size>  <path>
# Exit 0 = at least one candidate. Exit 1 = nothing matched (near misses printed
# to stderr so the caller can show Arnav what IS there).
#
# Matching is deliberately loose. The download is named by hand, so it drifts from
# the repo folder name: case varies (.TXT vs .txt), separators vary, and the name is
# sometimes misspelt (ZAA_IMPARMENTLOSS.txt for zaa_impairmentloss). Pass 1 is an
# exact substring match on the squashed name; pass 2 falls back to a shared prefix.
#
# Downloads holds hundreds of files, so the match loop uses bash string operations
# only — a forked tr/basename per file made this take minutes.

set -uo pipefail

DL="${DOWNLOADS:-$HOME/Downloads}"
q_raw="${1:-}"
[ -z "$q_raw" ] && { echo "usage: find-download.sh <PROGRAM_NAME>" >&2; exit 2; }

# squash: uppercase, drop separators, so ZFI_BNK_APP == "zfi bnk app" == zfi-bnk.app
# ('-' sits last inside the bracket expression, where it is a literal, not a range.)
q="${q_raw^^}"; q="${q//[_ .-]/}"
[ -z "$q" ] && { echo "find-download: '$q_raw' has no usable characters." >&2; exit 2; }

# Source-bearing extensions only. Spreadsheets, archives and Office lock files
# (~$foo.xlsx) are never the program source and only add noise.
mapfile -t cands < <(
  find "$DL" -maxdepth 1 -type f \
       \( -iname '*.txt' -o -iname '*.abap' \) \
       ! -name '~$*' -printf '%T@\t%s\t%p\n' 2>/dev/null | sort -rn
)
[ ${#cands[@]} -eq 0 ] && { echo "find-download: no .txt/.abap files in $DL." >&2; exit 1; }

hits=()
for line in "${cands[@]}"; do
  p="${line##*$'\t'}"          # path is the last tab-separated field
  b="${p##*/}"                 # basename
  b="${b%.*}"                  # strip extension
  b="${b^^}"; b="${b//[_ .-]/}"
  [[ "$b" == *"$q"* ]] && hits+=("$line")
done

# Pass 2: shared leading run of >=5 chars, for the misspelt-download case.
if [ ${#hits[@]} -eq 0 ]; then
  for line in "${cands[@]}"; do
    p="${line##*$'\t'}"; b="${p##*/}"; b="${b%.*}"
    b="${b^^}"; b="${b//[_ .-]/}"
    n=0
    while [ $n -lt ${#q} ] && [ $n -lt ${#b} ] && [ "${q:$n:1}" = "${b:$n:1}" ]; do n=$((n+1)); done
    [ $n -ge 5 ] && hits+=("$line")
  done
  [ ${#hits[@]} -gt 0 ] && echo "find-download: no exact match for '$q_raw' — these share a prefix:" >&2
fi

fmt() { awk -F'\t' '{ printf "%s\t%s\t%s\n", strftime("%Y-%m-%d %H:%M", $1), $2, $3 }'; }

if [ ${#hits[@]} -eq 0 ]; then
  echo "find-download: nothing in $DL matches '$q_raw'." >&2
  echo "find-download: 15 most recent source files there:" >&2
  printf '%s\n' "${cands[@]}" | head -15 | fmt >&2
  exit 1
fi

printf '%s\n' "${hits[@]}" | fmt
