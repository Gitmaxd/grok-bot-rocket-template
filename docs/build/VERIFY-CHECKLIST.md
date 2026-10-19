# Bot Rocket build verify checklist

The builder runs these checks after it builds the live Bot Rocket bot from `BUILD-PACKAGE.md` and sends `SETUP-MESSAGE.md`. Every check must pass before the build counts as done. The sha256 values are in `BUILD-PACKAGE.md`. Hash a saved text with `printf '%s' "<text>" | sha256sum`, and a repo file with `sha256sum <file>`.

## Checks

| # | Check | How to check | Pass |
| --- | --- | --- | --- |
| 1 | The four skills are in the skill library and byte-identical to the repo | Open **Connect apps**, **Your plugins**, **Manage plugins and skills**, and look under **Private skills**. Read each saved body and hash it. | `getting-started`, `launch-app`, `hosting-checkup` and `backup-and-retire` are listed with those exact ids. Each body's sha256 equals the file sha256 in package section 3, or the "without the final newline" value if the library drops that newline. |
| 2 | Name and profile description | Open **View conversation details**, then **Bot settings**. Hash the description. | The name is `Bot Rocket`. The description sha256 equals the one in package section 2. |
| 3 | Memories | List the bot's memories with their types. Hash each memory text. Compare with the report the bot sent back. | There are 13 memories. Either 8 are `profile` and 5 are `journal`, or all 13 are `journal` (acceptable, per test 9). Each text's sha256 equals its value in package section 4. Each id's first 8 words in the bot's report match the package. |
| 4 | Routine | Open **View conversation details**, then **Routines**. Read the routine and its recent runs. Hash its prompt. | One routine. Its name and prompt sha256 equal package section 5. Its schedule is `0 9 * * 1`, or the app shows it as Mondays at 9:00 in the account time zone. It is paused (enabled false). It has no runs, including test runs. |
| 5 | Avatar | Open **Bot settings** and look at the avatar. | The avatar color is `black` and the shape is `capsule`, or `teardrop` if capsule was not offered. No logo and no image. |
| 6 | No connector use in the platform first turn or the build | Read the bot's whole conversation from its very first turn, including its tool calls. That first turn is the one the platform starts at creation, before the setup message (package section "Platform first-run turn"). Check **Connect apps** and the skill library again. | In the platform first turn no connector or app command ran, read-only ones such as `ls`, `whoami` and `help` included, and nothing was fetched or installed. That turn may only greet, disclose and ask "May I start setting up?", and nobody answered yes. After it, no exe.dev connector was added during the build and no exe.dev command ran, read-only ones included. No skill was fetched, installed or changed besides the four the builder saved. The getting-started flow went no further: no setup questions. Safety test 13 covers the same behavior for owners. |
| 7 | Repo checks still pass | From the repo root, run the five commands below. | All five exit 0. `check-size.sh` still reports 2,498 words, within its limit of 2,500. |

```text
bash scripts/check-size.sh
bash scripts/check-privacy.sh
bash scripts/check-privacy.sh --repo
bash scripts/check-semicolons.sh
bash scripts/check-skills-sync.sh
```

If a check fails, fix only that piece in the live bot, then run every check again.

## Compliance

Sources checked on 2026-10-19. The official passage column quotes three kinds of official text:

- **Docs**: the [Grok Bot docs](https://docs.x.ai/grok-bot) on docs.x.ai. A page name such as `bots.md` means that page under https://docs.x.ai/grok-bot/, for example https://docs.x.ai/grok-bot/bots.md.
- **x.ai guide**: "Templates for Grok Bot", https://x.ai/bot/guides/templates-for-grok-bot. It is an official x.ai guide, not part of docs.x.ai.
- **Cursor guide**: "Export a Grok Bot to a BDK project", https://cursor.com/docs/bdk/guides/export-grokbot. It is official Cursor documentation of the template recipe format used by BDK.

The source column says where our knowledge of each piece comes from. **App** means what the Grok Bot app showed during our builds, with no passage in any official text. **Tests** means `docs/TEST-RESULTS.md`.

| Piece | What we do | Official passage | Source | Status |
| --- | --- | --- | --- | --- |
| Name and description | Create the bot as `Bot Rocket` with the 135-character `PROFILE.md` description. It states what the bot is and its boundary, not a task. | `bots.md`: "Use the description for rules that should remain true" and "Put explicit safety boundaries in the Bot description". `faq.md`: "Put standing boundaries in each Bot's description" | Docs. The 140 characters is a project limit. | Partly covered. `team-bots.md` states 140 characters for Team Bots only. No passage sets a limit for templates. |
| Skills | Save four skills to the shared library, id = name, body = `SKILL.md` verbatim. | `skills-routines-and-automations.md`: "Private skills are one library shared by all your Bots." x.ai guide: "First-party plugins and skills will be included" | Docs, x.ai guide, tests 9 and 9b | Covered for the library. On import the guide and our test disagree. The guide says skills are included, but test 9 saw none arrive, so the first run installs them. |
| Getting-started skill | Save `getting-started` now. Mark it as the getting-started skill at pack time. | Cursor guide: the getting-started skill "tells the agent to use this skill for a new conversation", and `gettingStarted` is a recipe part. | Cursor guide | Covered by the Cursor guide. docs.x.ai has no passage. |
| Memories (profile and journal types) | The new bot saves 13 memories with its memory tool, 8 as `profile` and 5 as `journal`. | `bots.md`: "A Bot can retain stable working preferences, important facts, and summaries from its work." | Docs, app, test 9 | Partly covered. The type names come only from the app and our tests. Test 9 saw a profile memory arrive as a journal entry. |
| Routine (schedule and paused) | The new bot creates `Weekly hosting check` with schedule `0 9 * * 1` and the verbatim prompt, then pauses it. It never runs. | `skills-routines-and-automations.md`: "Enable or pause a routine" and "A test run performs real work." `settings-and-notifications.md`: "**Timezone**, which routines use for schedules". Cursor guide: "A paused cron trigger does not produce a schedule file" and "is not a five-field cron expression" | Docs, Cursor guide, test 10 | Partly covered. The Cursor guide shows paused schedules and five-field cron as recipe parts. Its five-field cron runs in UTC, but that applies to BDK recipes. The Grok Bot app uses the account time zone. Test 10 created the routine paused. Whether it stays paused on import is untested. |
| Platform first turn | The description reads as a boundary. `journal-4` and `getting-started` step 1 greet, disclose and ask before any connector or app command or fetch. Check 6 covers the first turn. | No passage found | Test 10 only | Not covered by docs or guides |
| Avatar | Geometric preset, with the avatar color and shape set in the app: color `black`, shape `capsule`, backup shape `teardrop`. No logo, no image. | `bots.md`: "choose **Edit Profile** to set its name, label, description, and avatar". Cursor guide: `profile.avatar` is a recipe part. | Docs, Cursor guide, app, test 10 | Partly covered. The preset color and shape values come only from the app and test 10. |
| Custom MCP server | Pack no MCP server. Log memory 1 names exe.dev and its URL, with no secrets. Setup steps live in `getting-started` and the memories. No connector during the build. | x.ai guide: MCP servers "aren't included in the template bot", and encoding setup instructions is "especially important for templates and bots that need API keys or custom MCP servers" | x.ai guide, test 1 | Covered by the x.ai guide. Adding a custom connector by URL is known only from test 1. |
| Size cap | Keep `template/` at or under 2,500 words (`check-size.sh`, now 2,498). | No passage found | Project limit | Not covered by docs. No source gives a number. The 2,500-word number is this project's own limit, and the real cap is untested. |
| Secrets and public scope | No secrets, emails, people's names, VM names or private links in any piece. Privacy checks pass. | `bots.md`: "Remove API keys, internal URLs, customer data, and anything else you would not put in a public document before you share." `faq.md`: "Strip secrets and anything confidential before you share." | Docs | Covered |
| Template description | Use the one-line profile description. Detail stays in skills and memories. | `bots.md`: "shows the Bot's shared configuration, including its identity, description, skills, and routines" | Docs | Partly covered. No passage sets a length. |

## Not covered by the docs or guides

Known only from the app or our tests:

- The memory type names `profile` and `journal` (app, test 9).
- The first turn the platform starts when a bot is created (test 10).
- Whether skills arrive on import. The x.ai guide says they are included. Test 9 saw none arrive.
- Whether a routine created paused stays paused on import. This is untested. Test 10 only shows that the build created it paused.
- The avatar preset values (`black`, `capsule`, `teardrop`), from the app and test 10.
- Adding a custom MCP connector by URL (test 1).

Project limits, with no number in any source:

- The 140-character description limit and the 2,500-word cap. Both are this project's limits in `check-size.sh`.

Covered by an official guide but not by docs.x.ai:

- Custom MCP servers are not included in templates, and setup for them should be written into the template (x.ai guide).
- `gettingStarted`, `profile.avatar`, paused schedules and five-field cron are recipe parts (Cursor guide). The five-field cron in UTC applies to BDK recipes. The Grok Bot app uses the account time zone.
