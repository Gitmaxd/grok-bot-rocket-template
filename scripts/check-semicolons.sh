#!/usr/bin/env bash
# Fail if a semicolon appears in prose in README.md, SECURITY.md,
# CONTRIBUTING.md, docs/TEST-RESULTS.md, docs/SAFETY-TESTS.md,
# docs/build/*.md, template/**/*.md or skills/**/*.md (plus any extra files
# given as arguments). Fenced code blocks, inline code spans and HTML entities such as
# &amp; are ignored. Exit 0 when clean.

set -u
export LC_ALL=C

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root" || exit 2

mapfile -t files < <(
  {
    for f in README.md SECURITY.md CONTRIBUTING.md docs/TEST-RESULTS.md docs/SAFETY-TESTS.md; do [[ -f "$f" ]] && printf '%s\n' "$f"; done
    find docs/build -maxdepth 1 -type f -name '*.md'
    find template -type f -name '*.md'
    find skills -type f -name '*.md'
    for a in "$@"; do printf '%s\n' "$a"; done
  } 2>/dev/null | sort -u
)

if (( ${#files[@]} == 0 )); then
  echo "check-semicolons: no files to check" >&2
  exit 2
fi

hits="$(awk '
  # Remove inline code spans. A span opens with a run of N backticks and
  # closes at the next run of exactly N backticks, as in CommonMark.
  function strip_code(s,    out, n, i, rest, pos, m, found) {
    out = ""
    while (match(s, /`+/)) {
      out = out substr(s, 1, RSTART - 1)
      n = RLENGTH
      rest = substr(s, RSTART + n)
      found = 0
      pos = 0
      while (match(substr(rest, pos + 1), /`+/)) {
        m = RLENGTH
        pos += RSTART + m - 1
        if (m == n) { found = 1; break }
      }
      if (found) {
        s = substr(rest, pos + 1)
      } else {
        for (i = 0; i < n; i++) out = out "`"
        s = rest
      }
    }
    return out s
  }
  FNR == 1 { fence = "" }
  {
    line = $0
    if (match(line, /^ {0,3}(```+|~~~+)/)) {
      marker = substr(line, RSTART, RLENGTH)
      gsub(/ /, "", marker)
      if (fence == "") { fence = substr(marker, 1, 3); next }
      if (substr(marker, 1, 3) == fence) { fence = ""; next }
    }
    if (fence != "") next
    line = strip_code(line)
    gsub(/&[A-Za-z0-9#]+;/, "", line)
    if (index(line, ";") > 0) printf "%s:%d: %s\n", FILENAME, FNR, $0
  }
' "${files[@]}")"

if [[ -n "$hits" ]]; then
  printf '%s\n' "$hits"
  echo "check-semicolons: FAIL, $(printf '%s\n' "$hits" | wc -l) line(s) with a semicolon in prose"
  exit 1
fi
echo "check-semicolons: PASS, ${#files[@]} file(s) checked"
exit 0
