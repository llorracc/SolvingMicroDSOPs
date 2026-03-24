#!/usr/bin/env bash
# Postprocess a *-clean.tex file: escape # in \href URLs for hyperref, then strip
# \begin{comment}...\end{comment} blocks. Modifies the file in place.
# Usage: de-macro-postprocess.sh <path-to-clean.tex>
# Call from the directory that contains the file (or use an absolute path).

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <path-to-clean.tex>" >&2
  exit 1
fi

CLEAN_TEX="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$CLEAN_TEX" ]]; then
  echo "Not a file: $CLEAN_TEX" >&2
  exit 1
fi

# Fix hyperref: escape # in \href{URL}{...} so \Hy@tempa doesn't see raw # (illegal parameter number)
perl -i.bak -0777 -pe 's/\\href(\{(?:[^{}]|\{[^{}]*\})*\})/my $u=$1; $u =~ s!#!\\#!g; "\\href$u"/ge' "$CLEAN_TEX"
rm -f "$CLEAN_TEX.bak"

# Strip \begin{comment}...\end{comment} so LaTeX never sees \code or verbatim inside comments
"$SCRIPT_DIR/strip-comment-blocks.pl" "$CLEAN_TEX" > "$CLEAN_TEX.tmp" && mv "$CLEAN_TEX.tmp" "$CLEAN_TEX"
