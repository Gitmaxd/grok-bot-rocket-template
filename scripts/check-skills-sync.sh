#!/usr/bin/env bash
# Check that skills/<name>/SKILL.md matches its source in template/skills/.
#
#   check-skills-sync.sh           check only, exit 0 when every file matches
#   check-skills-sync.sh --write   regenerate skills/ from template/skills/
#
# template/skills/<name>.md is the single source of truth. Each SKILL.md is
# rebuilt from it as YAML frontmatter (name from the **Name:** line,
# description from the **Description:** line, both verbatim), a blank line,
# then the job text below the first --- line, verbatim.
#
# Exit 1 on any difference, a missing file, an extra folder or file in
# skills/, or a source file that cannot be converted. --write never deletes
# anything, so extra folders and files still fail and must be removed by hand.
# Exit 2 on usage errors.

set -u
export LC_ALL=C

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root" || exit 2

write=0
case "${1:-}" in
  "") ;;
  --write) write=1 ;;
  *) echo "check-skills-sync: unknown argument: $1 (use --write or nothing)" >&2; exit 2 ;;
esac

src_dir="template/skills"
out_dir="skills"

mapfile -t sources < <(find "$src_dir" -maxdepth 1 -type f -name '*.md' | sort)
if (( ${#sources[@]} == 0 )); then
  echo "check-skills-sync: no skill sources in $src_dir" >&2
  exit 2
fi

problems=0
problem() {
  echo "check-skills-sync: $1"
  problems=$((problems + 1))
}

# Prints the expected SKILL.md for one source file, or fails.
build() {
  local src="$1" name="$2" desc
  desc="$(grep -m1 '^\*\*Description:\*\* ' "$src" | sed 's/^\*\*Description:\*\* //')"
  if [[ -z "$desc" ]]; then
    echo "check-skills-sync: $src has no **Description:** line" >&2
    return 1
  fi
  # A plain YAML scalar cannot hold ": " or " #", or start with a YAML
  # indicator character. Fail rather than emit frontmatter that misparses.
  local unsafe=0
  [[ "$desc" == *": "* || "$desc" == *" #"* || "$desc" == *":" ]] && unsafe=1
  case "${desc:0:1}" in
    '[' | ']' | '{' | '}' | '>' | '|' | '*' | '&' | '!' | '%' | '@' | '`' | '"' | "'" | ',' | '?' | ':' | '#' | '-') unsafe=1 ;;
  esac
  if (( unsafe )); then
    echo "check-skills-sync: $src description is not a safe plain YAML value" >&2
    return 1
  fi
  if ! grep -qx -- '---' "$src"; then
    echo "check-skills-sync: $src has no --- line before the job text" >&2
    return 1
  fi
  printf -- '---\nname: %s\ndescription: %s\n---\n\n' "$name" "$desc"
  awk '
    !seen && $0 == "---" { seen = 1; next }
    !seen { next }
    !started && $0 ~ /^[[:space:]]*$/ { next }
    { started = 1; print }
  ' "$src"
}

expected_names=()
for src in "${sources[@]}"; do
  name="$(basename "$src" .md)"
  expected_names+=("$name")
  label="$(grep -m1 '^\*\*Name:\*\* ' "$src" | sed 's/^\*\*Name:\*\* //')"
  if [[ "$label" != "$name" ]]; then
    problem "$src **Name:** line is '${label}', expected '${name}'"
    continue
  fi
  if ! expected="$(build "$src" "$name")"; then
    problems=$((problems + 1))
    continue
  fi
  out="$out_dir/$name/SKILL.md"
  if [[ -f "$out" ]] && cmp -s <(printf '%s\n' "$expected") "$out"; then
    continue
  fi
  if (( write )); then
    mkdir -p "$out_dir/$name"
    printf '%s\n' "$expected" > "$out"
    echo "check-skills-sync: wrote $out"
  elif [[ ! -f "$out" ]]; then
    problem "missing $out"
  else
    problem "$out differs from $src"
    diff <(printf '%s\n' "$expected") "$out" | sed 's/^/    /'
  fi
done

if [[ -d "$out_dir" ]]; then
  while IFS= read -r entry; do
    base="${entry#"$out_dir"/}"
    found=0
    for n in "${expected_names[@]}"; do
      [[ "$base" == "$n" && -d "$entry" ]] && found=1 && break
    done
    (( found )) || problem "extra entry $entry has no source in $src_dir"
  done < <(find "$out_dir" -mindepth 1 -maxdepth 1 | sort)
  for n in "${expected_names[@]}"; do
    [[ -d "$out_dir/$n" ]] || continue
    while IFS= read -r entry; do
      problem "extra entry $entry (only SKILL.md belongs here)"
    done < <(find "$out_dir/$n" -mindepth 1 -maxdepth 1 ! -name SKILL.md | sort)
  done
fi

if (( problems > 0 )); then
  echo "check-skills-sync: FAIL, $problems problem(s)"
  (( write )) || echo "check-skills-sync: edit template/skills/ first, then run with --write"
  exit 1
fi
if (( write )); then
  echo "check-skills-sync: PASS, ${#expected_names[@]} skill(s) in sync after --write"
else
  echo "check-skills-sync: PASS, ${#expected_names[@]} skill(s) in sync"
fi
exit 0
