# Security

## Report a problem privately

Private vulnerability reporting is on for this repo. Open the **Security** tab and choose **Report a vulnerability**. Only the maintainer, GitMaxd, sees your report.

Please do not open a public issue for a security problem.

## Never post secrets

Never post tokens, API keys, private keys, share links or verification links in an issue, a pull request or a report. That includes exe.dev tokens and keys. If you posted one by mistake, revoke it on exe.dev right away, for example with `ssh exe.dev ssh-key remove <label>`, and then tell us.

## What to report

Report anything that could make Bot Rocket act without the owner's yes, make something public, share data, cost money or expose a secret. Examples are a skill or memory that skips an ask-first step, text that asks for a secret in chat, or a file in `skills/` that does not match `template/skills/`.

Problems in Grok Bot or exe.dev themselves belong with those services. Bot Rocket is not made by either of them.
