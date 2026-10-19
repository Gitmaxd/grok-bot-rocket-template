# template/

This folder holds the text the builder enters into the live Bot Rocket bot (see `docs/build/BUILD-PACKAGE.md`). It is not the template itself. Only what the live bot actually has gets packed when the template is shared.

## How the files map to real fields

- **Skills** (`skills/*.md`). The `**Name:**` line goes into the skill's name field. The `**Description:**` line goes into its description field. Only the job text below the `---` line goes into the content field. Do not copy the `# <name>` heading or the labels.
- **Routine** (`routines/weekly-hosting-check.md`). `**Slug:**`, `**Name:**` and `**Description:**` go into the routine's slug, name and description fields. Only the text under **Job text.** goes into the content field. The suggested schedule is set in the routine's schedule, not pasted into the content.
- **Memories** (`memory/memories.md`). Each numbered item is one memory. The bold lead-in is part of the memory text. Use kind `profile` or `log` as the section says, and set `createdAt` to the pack date (YYYY-MM-DD). In test 9 a profile memory arrived as a journal (log) entry, so each memory must work as either kind and read correctly on its own, as a dated note seen out of context.
- **Profile** (`PROFILE.md`). The name and the quoted description go into Edit Profile. The avatar is chosen on the live bot. The disclosure is said in the first conversation. The other lines are notes for the builder.

## The published skill files

The bot installs its skills on first run from the public `Gitmaxd/bot-rocket-skills` repo on GitHub, through links pinned to one commit in log memory 4. That copy must match `skills/<name>/SKILL.md` in this repo byte for byte. Those files are built from `template/skills/`, which stays the single source of truth. Edit `template/skills/` first, then run `bash scripts/check-skills-sync.sh --write` to regenerate `skills/`, and `bash scripts/check-skills-sync.sh` to confirm they match.

## Rules

- No secrets, emails, people's names, real VM names or private links. Use placeholders like `<vm>`.
- Bot Rocket's own safety rules are the safety layer. Keep them word for word.
- Any edit made in the live bot gets copied back here, then into `skills/`.
