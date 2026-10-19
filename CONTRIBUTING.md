# Contributing

Bot Rocket is a small template that bots read and act on. These rules keep it safe and short.

## Edit the template text first

- Skill text lives in `template/skills/<name>.md`. That is the single source of truth.
- `skills/<name>/SKILL.md` is generated from it. Do not edit `skills/` by hand. After you change `template/skills/`, run `bash scripts/check-skills-sync.sh --write`.
- Keep the packed text in `template/` at or under 2,500 words. `check-size.sh` counts it.
- Keep Bot Rocket's safety rules word for word unless a fact in them is wrong. Say why in the pull request.

## Run every check before a pull request

Run these from the repo root. Each must exit 0.

```
bash scripts/check-size.sh
bash scripts/check-privacy.sh
bash scripts/check-privacy.sh --repo
bash scripts/check-semicolons.sh
bash scripts/check-skills-sync.sh
```

## Writing rules

- No semicolons in prose. `check-semicolons.sh` checks the READMEs, `SECURITY.md`, this file, `docs/TEST-RESULTS.md`, `docs/SAFETY-TESTS.md`, `docs/build/`, `template/` and `skills/`.
- No secrets. That means no tokens, keys, share links or verification links.
- No personal details. That means no names, emails, phone numbers, account details or real VM names. Use placeholders like `<vm>`.
- Every fact must trace to a primary source: the public [Grok Bot docs](https://docs.x.ai/grok-bot), the public [exe.dev docs](https://exe.dev/docs), or a test in `docs/TEST-RESULTS.md`. Link to the live docs. Do not copy them into this repo. Do not invent commands, flags, URLs or behavior.

## Security problems

Do not open a public issue. See [SECURITY.md](SECURITY.md).
