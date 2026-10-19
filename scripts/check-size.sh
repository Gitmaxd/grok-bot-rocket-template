#!/usr/bin/env bash
# Count words across the packed template drafts and check the storefront
# description length. Exit 0 when both are within limits, 1 otherwise.
#
# The count covers whole draft files, including headings and builder notes,
# so it overstates what is packed. That keeps the check conservative.

set -u
export LC_ALL=C.UTF-8 2>/dev/null || export LC_ALL=C

max_words=2500
max_desc=140

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root" || exit 2

profile="template/PROFILE.md"
if [[ ! -f "$profile" ]]; then
  echo "check-size: missing $profile" >&2
  exit 2
fi

mapfile -t files < <(
  printf '%s\n' "$profile"
  find template/memory template/skills template/routines -type f -name '*.md' 2>/dev/null | sort
)

status=0
total=0
for f in "${files[@]}"; do
  [[ "$f" == "template/README.md" ]] && continue
  n=$(wc -w < "$f")
  total=$((total + n))
  printf '%6d  %s\n' "$n" "$f"
done
printf '%6d  total (limit %d)\n' "$total" "$max_words"
if (( total > max_words )); then
  echo "check-size: FAIL, $total words is over $max_words"
  status=1
fi

# The description is the first blockquote line in PROFILE.md.
desc="$(grep -m1 '^> ' "$profile" | sed 's/^> //')"
if [[ -z "$desc" ]]; then
  echo "check-size: FAIL, no quoted description found in $profile"
  status=1
else
  len=${#desc}
  printf 'description: %d characters (limit %d)\n' "$len" "$max_desc"
  if (( len > max_desc )); then
    echo "check-size: FAIL, description is over $max_desc characters"
    status=1
  fi
fi

(( status == 0 )) && echo "check-size: PASS"
exit "$status"
