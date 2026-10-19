# Bot Rocket

Bot Rocket is a Grok Bot Custom Template I made to give the things your Bots build a home of their own. Apps, services and helper processes go on exe.dev VMs in your own exe.dev account, with persistent disks and HTTPS behind exe.dev sign-in. Everything starts private. When you want to share something, you name it and Bot Rocket opens it up, either to specific people or to the public.

It asks before it runs its first command, and it asks again before anything risky: deleting, making something public, sharing, spending money, or creating or revoking keys.

**[Add Bot Rocket](https://x.ai/bot/TGzxElzv7Auy7U2vlipxe)**

[![Bot Rocket launch video: an app your Bot built moves off the shared computer into its own private home, then the end card shows the Add Bot Rocket link](docs/media/bot-rocket-launch-poster.jpg)](docs/media/bot-rocket-launch.mp4)

*The launch video runs 28 seconds. Click the image to play it.*

You sign up with exe.dev and pay them directly. Bot Rocket itself is free. It has no servers, no accounts and no service of its own. It is a set of instructions for a Grok Bot, plus the files in this repo.

## Unofficial and community-made

Bot Rocket is not made by or endorsed by exe.dev, SpaceXSI or xAI. It is a community project by [GitMaxd](https://github.com/Gitmaxd).

The Grok Bot docs say this about every shared Bot:

> Shared Bots are created by other users, not by SpaceXSI. Adding one accepts the [third-party bot terms](https://x.ai/legal/bot-sharing-terms).

Read those terms before you add Bot Rocket.

## Why you might want it

I built Bot Rocket because the shared Grok Bot computer is not a good place for things that should keep running. The Grok Bot docs say: "Treat temporary directories, manually installed packages, and uncommitted application state as replaceable." They also say a reset "rebuilds the computer from your last saved snapshot". An exe.dev VM keeps its disk.

I wrote it for one person with their own exe.dev account. Team accounts on exe.dev's Work plan are not covered yet.

## What you need

- **The Grok Bot app**, with a plan that includes Grok Bot. See [Get started](https://docs.x.ai/grok-bot/get-started.md) in the Grok Bot docs. You add the Ask first rule from the first-run steps in the desktop app.
- **An exe.dev account and plan.** exe.dev needs an active subscription before you can create VMs. Plans and prices are in exe.dev's [billing docs](https://exe.dev/docs/billing/overview.md). Bot Rocket never signs up or pays for you.
- **The exe.dev MCP connector** at `https://exe.dev/mcp`. You add it in Grok Bot as a custom connector and sign in through your browser. Bot Rocket walks you through it on first run.

The public Grok Bot docs ([Computer and apps](https://docs.x.ai/grok-bot/computer-and-apps.md)) only describe connectors installed as plugins from **Connect apps**. They do not describe adding a custom connector by URL. I tested it and it worked (see `docs/TEST-RESULTS.md`, test 1). Adding a connector by URL is not documented by Grok Bot, so it could change. exe.dev documents its side in its [MCP docs](https://exe.dev/docs/mcp.md).

## Add it

Adding Bot Rocket follows the flow in the Grok Bot docs ([Share a Bot](https://docs.x.ai/grok-bot/bots.md)):

1. Open the [template link](https://x.ai/bot/TGzxElzv7Auy7U2vlipxe). It opens a preview on x.ai.
2. Choose **Add to Grok Bot**. You need the Grok Bot app to finish.

You get your own copy of Bot Rocket. You do not get anyone else's computer, logins or conversations.

## What happens on first run

Bot Rocket's first conversation asks one question per message and waits for your answer.

1. It greets you and says what it does, that it is not made by exe.dev, and that exe.dev bills you directly. It says what it will install and from where, then asks if it may start. Until you say go, it runs no connector command, not even a read-only one, and installs nothing.
2. After your yes, it installs its skills (see below).
3. It asks whether you have an exe.dev account. If not, you sign up and pick a plan yourself while it waits.
4. It asks you to add the `https://exe.dev/mcp` connector and approve the browser sign-in. If that does not work, it offers a token path, where you create a scoped token in your own terminal and paste it only into Grok Bot's secure secret request.
5. It runs a read-only check (`whoami` and `ls`) and changes nothing.
6. It asks your preferences: whether anything should ever be public, one VM per app or a shared VM, and a preferred region.
7. It asks you to add an **Ask first** rule in Grok Bot under Settings, General, Auto-review, and suggests the rule text. These rules are stored per desktop, so a template cannot ship one. You add it once on each desktop you use.
8. It offers a weekly read-only check-up, the `weekly-hosting-check` routine, and asks before it turns it on. In my live build the routine was created paused and never ran (`docs/TEST-RESULTS.md`, test 10). I have not tested yet whether it arrives paused when you add the template, so check **Routines** after you add it.
9. It saves your answers as memories and asks what to launch first.

### The skills it installs

Bot Rocket installs its own skills on first run, after you say yes. First it fetches exe.dev's own agent skill, `using-exe-dev`, from exe.dev's GitHub repo. It never overwrites a skill you already have with that name.

Then it adds any of its four skills that are missing:

- `getting-started` runs the first conversation above.
- `launch-app` puts an app, service or helper process on an exe.dev VM, private by default, and shares it or adds a domain only with your yes.
- `hosting-checkup` gives a read-only report on your VMs, apps, sharing and usage.
- `backup-and-retire` backs up an app's data, moves it to another VM or deletes a VM, without losing the only copy.

These come from pinned links to the public [`Gitmaxd/bot-rocket-skills`](https://github.com/Gitmaxd/bot-rocket-skills) repo at a fixed commit, so the files it fetches cannot change under you. You don't need to install them yourself.

I do it this way because a template's skills did not arrive when I added a template in my import test (`docs/TEST-RESULTS.md`, test 9). A first-run step that downloaded and saved exe.dev's own skill did work (test 9b). I have not tested that path yet with Bot Rocket's own skills. Its memories keep a short copy of the setup steps and safety rules in case a skill is missing.

## Safety model

Bot Rocket follows these rules (full text in `template/memory/memories.md`):

- It asks first before anything that deletes, makes something public, shares, costs money, changes billing, or creates or revokes keys and tokens. It names the action, the target and any cost. A yes covers that one action only.
- It never deletes a VM or a share without your explicit yes in chat.
- Everything stays private behind exe.dev sign-in unless you name the exact VM and port to make public.
- It never asks for a password, token or key in chat. Tokens go only into Grok Bot's secure secret request, which the Grok Bot docs say is masked, excluded from the transcript and not shown to the model. If you paste a token in chat, it does not repeat it and advises you to revoke it.
- It checks the result after every action and reports what it checked.
- It reads exe.dev's live `help` before any command it has not used in the conversation.

exe.dev's MCP connector exposes one tool, `exec`, and its own description says it "may run every exe.dev command". There is no read-only scope. Grok Bot connectors are also account-wide, so your other Bots can use it too.

That leaves two safety layers. One is your own Ask first rule, which stops matching actions for your approval. The other is Bot Rocket's own rules above. The Grok Bot docs say Auto Review "is model-based and should complement, not replace, least privilege and explicit approval boundaries."

The 13 safety tests these rules must pass are in `docs/SAFETY-TESTS.md`.

## Disconnect and clean up

**Pause instead of delete.** Ask Bot Rocket to pause an idle VM with `pause <vm>` and bring it back with `resume <vm>`. It asks first for both. exe.dev has no stop or start command. You can pause the weekly check-up from the Bot's **View conversation details**, then **Routines**.

**Disconnect exe.dev.** Removing the connector in Grok Bot does not revoke its key on exe.dev. Each connector sign-in creates an exe.dev key with a label like `mcp-cursor-N` (`docs/TEST-RESULTS.md`, test 2). To revoke it:

1. Ask Bot Rocket to do it (it asks first), or run the commands below in your own terminal. The terminal path needs your SSH key on your exe.dev account.
2. List keys with `ssh exe.dev ssh-key list` and find the `mcp-cursor-N` label, or the label of a token you made.
3. Remove it with `ssh exe.dev ssh-key remove <label>`.
4. Run `ssh exe.dev ssh-key list` again to confirm it is gone.

**Delete the Bot.** Deleting a Bot removes its profile, conversation and routines from Grok Bot. The Grok Bot docs add that shared computer files and sign-ins are not isolated by Bot and may remain on the computer.

The docs also say a few things stay behind when you delete the Bot:

- Skills are one private library shared by all your Bots. You can see what is there under **Connect apps**, **Your plugins**, **Manage plugins and skills**.
- Connectors are account-wide, so the exe.dev connector stays until you remove it. Revoke its key as described above.
- Your VMs and plan live on exe.dev. Retire the VMs you no longer need before you delete the Bot, or manage them on exe.dev.

## Repo layout

This repo, `Gitmaxd/grok-bot-rocket-template`, is the source for Bot Rocket.

- `template/` holds the text the live Bot Rocket is built from: profile, memories, skills and the weekly routine. See `template/README.md`.
- `skills/` holds the `SKILL.md` files generated from `template/skills/`. They must match the pinned copy in `Gitmaxd/bot-rocket-skills` byte for byte.
- `scripts/` holds the check scripts.
- `docs/TEST-RESULTS.md` holds the test results.
- `docs/SAFETY-TESTS.md` holds the safety tests checklist.
- `docs/build/` holds the build package, setup message and verify checklist for the live bot.
- `docs/media/` holds the launch video and its poster.

The facts Bot Rocket relies on come from the public [Grok Bot docs](https://docs.x.ai/grok-bot) and [exe.dev docs](https://exe.dev/docs), plus the tests in `docs/TEST-RESULTS.md`.

Edits to skills go into `template/skills/` first. Then regenerate `skills/` with `bash scripts/check-skills-sync.sh --write`. A skill change also needs a new commit in `bot-rocket-skills` and a new pin in log memory 4 and `scripts/check-privacy.sh`. The sync check compares `skills/` with `template/skills/` only. It does not check the public repo.

## How to verify

The scripts need only bash, coreutils, grep and awk, plus git for `--repo`. None of them make network calls. Each exits 0 when clean and 1 when something fails. Run them from the repo root.

| Command | What it checks |
| --- | --- |
| `bash scripts/check-size.sh` | The packed template text (`template/` except its README) totals 2,500 words or fewer, and the profile description is 140 characters or fewer |
| `bash scripts/check-privacy.sh` | `template/` has no emails, phone numbers, tokens, keys, real VM hostnames or URLs outside a strict allowlist |
| `bash scripts/check-privacy.sh --repo` | The same checks on every tracked file, with a wider allowlist of public documentation hosts outside `template/` and `skills/` |
| `bash scripts/check-semicolons.sh` | No semicolons in prose in the READMEs, `SECURITY.md`, `CONTRIBUTING.md`, `docs/TEST-RESULTS.md`, `docs/SAFETY-TESTS.md`, `docs/build/`, `template/` and `skills/` |
| `bash scripts/check-skills-sync.sh` | Every `skills/<name>/SKILL.md` matches its source in `template/skills/`, with no missing or extra files |

## Contributing and security

Read [CONTRIBUTING.md](CONTRIBUTING.md) before you open a pull request.

To report a security problem, see [SECURITY.md](SECURITY.md). Never post tokens or keys in an issue.

## License

MIT, copyright 2026 GitMaxd. See [LICENSE](LICENSE).
