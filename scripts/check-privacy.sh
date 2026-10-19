#!/usr/bin/env bash
# Scan for personal or secret data that must never be published.
#
#   check-privacy.sh [path ...]   template mode: scans template/ plus any
#                                 paths given, all with the strict allowlist
#   check-privacy.sh --repo       repo mode: scans every file from
#                                 git ls-files (never untracked files), with
#                                 the strict allowlist for template/ and the
#                                 docs allowlist everywhere else
#
# Exit 0 when clean, 1 when anything is found, 2 on usage errors. Matched
# values are always masked in the output.
#
# Emails, phone numbers, tokens, keys and real VM hostnames are checked
# strictly in every file. Only the URL allowlist differs by mode and path.
#
# Strict (template) URL allowlist:
#   exe.dev /mcp, /exec, /docs, /docs.md and anything under /docs/
#   docs.x.ai /grok-bot and below, x.ai /bot/guides/, cursor.com /help/grok-bot/
#   raw.githubusercontent.com: exe.dev's official skill file, and Bot Rocket's
#     own skill files for the four skill names (or the literal <name> pattern)
#     in the public Gitmaxd/bot-rocket-skills repo, pinned to commit
#     65469e386f1f35bb0fa942aff4a78ab44c1433d8. A new pin means a new commit
#     there and new entries here.
#   the private-address placeholder for <vm> at exe.xyz, root path only, with
#     an optional :<port> or numeric port
# Docs URL allowlist: the strict list, plus any https URL on the public hosts
# in docs_hosts below. Hosts match exactly, so subdomains are not included.
# In repo mode skills/ is strict too, because bots fetch those files.

set -u
export LC_ALL=C

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mode=template
if [[ "${1:-}" == "--repo" ]]; then
  mode=repo
  shift
  if (( $# > 0 )); then
    echo "check-privacy: --repo takes no other arguments" >&2
    exit 2
  fi
  cd "$repo_root" || exit 2
  targets=()
  while IFS= read -r f; do
    [[ -f "$f" ]] && targets+=("$f")
  done < <(git ls-files)
  if (( ${#targets[@]} == 0 )); then
    echo "check-privacy: git ls-files returned no files" >&2
    exit 2
  fi
else
  targets=("$repo_root/template" "$@")
fi

for t in "${targets[@]}"; do
  if [[ ! -e "$t" ]]; then
    echo "check-privacy: path not found: $t" >&2
    exit 2
  fi
done

docs_hosts=(
  exe.dev
  docs.x.ai
  x.ai
  cursor.com
  github.com
)

findings=0

mask() {
  local v="$1" keep="${2:-4}"
  if (( ${#v} <= keep )); then
    printf '%s***' "${v:0:1}"
  else
    printf '%s*** (%d chars)' "${v:0:keep}" "${#v}"
  fi
}

report() {
  local file="$1" line="$2" kind="$3" value="$4" keep="${5:-4}"
  printf '%s:%s: %s: %s\n' "$file" "$line" "$kind" "$(mask "$value" "$keep")"
  findings=$((findings + 1))
}

# Prints "file:line:match" for every match of an extended regex.
scan() {
  grep -rHnoE --binary-files=without-match -e "$1" -- "${targets[@]}" 2>/dev/null
}

# Template mode is strict for every path. Repo mode is strict for template/
# and skills/.
strict_file() {
  [[ "$mode" == template || "$1" == template/* || "$1" == skills/* ]]
}

# Usage: check_simple kind regex
check_simple() {
  local kind="$1" regex="$2"
  local f l m
  while IFS=: read -r f l m; do
    # Drop the boundary character some patterns capture before the value.
    [[ "$m" =~ ^[^A-Za-z0-9+\(-] ]] && m="${m:1}"
    [[ -n "$m" ]] && report "$f" "$l" "$kind" "$m"
  done < <(scan "$regex")
}

check_simple "email address" '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'
check_simple "phone number" '(\+[0-9]{1,3}[ .-]?)?\(?[0-9]{3}\)?[ .-][0-9]{3}[ .-][0-9]{4}'
check_simple "phone number" '\+[0-9]{1,3}[ .-]?[0-9]{2,4}[ .-]?[0-9]{3,4}[ .-]?[0-9]{3,4}'
check_simple "exe.dev token" 'exe[01]\.[A-Za-z0-9_-]{4,}'
check_simple "GitHub token" '(^|[^A-Za-z0-9_])gh[op]_[A-Za-z0-9]{8,}'
check_simple "API key (sk-)" '(^|[^A-Za-z0-9_-])sk-[A-Za-z0-9_-]{8,}'
check_simple "private key header" '-----BEGIN ([A-Z0-9]+ )*PRIVATE KEY-----'

# "Bearer " followed by a value. A single lowercase word ("Bearer token") is
# prose, not a value, and placeholders like "Bearer <token>" are allowed.
while IFS=: read -r f l m; do
  value="${m#Bearer}"
  value="${value#"${value%%[! ]*}"}"
  [[ "$value" =~ ^[a-z]+$ ]] && continue
  report "$f" "$l" "bearer value" "$m" 7
done < <(scan 'Bearer +[A-Za-z0-9._~+/=-]{6,}')

# The scheme and host are taken apart with ${u%%://*} and ${u#*://} rather
# than written out, so this file does not flag its own source in repo mode.
vm_placeholder_url() {
  local u="$1" rest
  [[ "${u%%://*}" == https ]] || return 1
  rest="${u#*://}"
  [[ "${rest%%[:/]*}" == '<vm>.exe.xyz' ]] || return 1
  rest="${rest#'<vm>.exe.xyz'}"
  case "$rest" in
    '' | / | ':<port>' | ':<port>/') return 0 ;;
  esac
  [[ "$rest" =~ ^:[0-9]+/?$ ]]
}

template_url_allowed() {
  local u="$1"
  case "$u" in
    https://exe.dev/mcp | https://exe.dev/exec) return 0 ;;
    https://exe.dev/docs | https://exe.dev/docs.md | https://exe.dev/docs/*) return 0 ;;
    https://docs.x.ai/grok-bot | https://docs.x.ai/grok-bot/*) return 0 ;;
    https://x.ai/bot/guides/*) return 0 ;;
    https://cursor.com/help/grok-bot/*) return 0 ;;
    https://raw.githubusercontent.com/boldsoftware/exe.dev/main/skill/SKILL.md) return 0 ;;
    https://raw.githubusercontent.com/Gitmaxd/bot-rocket-skills/65469e386f1f35bb0fa942aff4a78ab44c1433d8/skills/getting-started/SKILL.md | \
    https://raw.githubusercontent.com/Gitmaxd/bot-rocket-skills/65469e386f1f35bb0fa942aff4a78ab44c1433d8/skills/launch-app/SKILL.md | \
    https://raw.githubusercontent.com/Gitmaxd/bot-rocket-skills/65469e386f1f35bb0fa942aff4a78ab44c1433d8/skills/hosting-checkup/SKILL.md | \
    https://raw.githubusercontent.com/Gitmaxd/bot-rocket-skills/65469e386f1f35bb0fa942aff4a78ab44c1433d8/skills/backup-and-retire/SKILL.md | \
    "https://raw.githubusercontent.com/Gitmaxd/bot-rocket-skills/65469e386f1f35bb0fa942aff4a78ab44c1433d8/skills/<name>/SKILL.md") return 0 ;;
  esac
  vm_placeholder_url "$u"
}

docs_url_allowed() {
  local u="$1" host h
  template_url_allowed "$u" && return 0
  [[ "${u%%://*}" == https ]] || return 1
  host="${u#*://}"
  host="${host%%[/:?#]*}"
  for h in "${docs_hosts[@]}"; do
    [[ "$host" == "$h" ]] && return 0
  done
  return 1
}

while IFS=: read -r f l m; do
  # Strip trailing sentence punctuation, markdown emphasis and the backslash of
  # an escaped backtick. A trailing ">" is an autolink bracket only when the
  # URL has no "<placeholder>" in it.
  u="$m"
  while [[ "$u" =~ [.,:\;!?\*\\]$ || ( "$u" == *">" && "$u" != *"<"* ) ]]; do u="${u%?}"; done
  if strict_file "$f"; then
    template_url_allowed "$u" && continue
  else
    docs_url_allowed "$u" && continue
  fi
  report "$f" "$l" "URL not on allowlist" "${u#*://}" 6
done < <(scan 'https?://[^][:space:])(`"'"'"'|]+')

# Bare www. links. Never allowed in strict files. Elsewhere only a host from
# docs_hosts is allowed.
while IFS=: read -r f l m; do
  [[ "$m" =~ ^[^A-Za-z0-9] ]] && m="${m:1}"
  if ! strict_file "$f"; then
    allowed=0
    for h in "${docs_hosts[@]}"; do
      [[ "$m" == "$h" ]] && allowed=1 && break
    done
    (( allowed )) && continue
  fi
  report "$f" "$l" "URL not on allowlist" "$m"
done < <(scan '(^|[^A-Za-z0-9./])www\.[A-Za-z0-9-]+\.[A-Za-z]{2,}')

# VM hostnames: any name under the exe.xyz domain other than the <vm>
# placeholder counts as a real VM.
while IFS=: read -r f l m; do
  name="${m%.exe.xyz}"
  name="${name##*/}"
  [[ "$name" == "<vm>" ]] && continue
  report "$f" "$l" "real-looking VM hostname" "$m" 3
done < <(scan '[A-Za-z0-9_.<>-]+\.exe\.xyz')

if (( findings > 0 )); then
  echo "check-privacy: FAIL, $findings finding(s)"
  exit 1
fi
echo "check-privacy: PASS ($mode mode), no findings in ${#targets[@]} path(s)"
exit 0
