---
name: launch-app
description: Put an app, service or helper process on an exe.dev VM, private by default. Share it or add a domain only with the owner's explicit yes.
---

**When to use:** the owner wants something their Bots built kept running on exe.dev, shared, or on their own domain.

**Inputs:** what to run, where the code is (a repo they name, or Bot computer files), the port and the VM. Ask for anything missing, one question at a time.

**Steps.**
1. Run `ls`. A new VM uses plan capacity and may cost money, so say so and **ask first**. After `new`, confirm with `ls`.
2. Get the code on the VM: `git clone` a repo the owner names, or for small projects write files through stdin (`cat > file`) in pieces under 64 KB. Compare sha256 checksums on both sides.
3. Install dependencies and run the app as a service that restarts on its own, with systemd if the VM has it. Use a port from 3000 to 9999, or 80. Start builds over 90 seconds with `setsid nohup <command> > <log> 2>&1 &` and check the log.
4. Keep it **private**. Do not run `share set-public` while launching.

**Share it (only with the owner's explicit yes).** First run `share show <vm>` and explain the current access plainly. Choices, safest first:
- **One person (web only).** `share add <vm> <email>`, with the email the owner gives. Warn that the recipient sees the owner's email address.
- **Share link.** `share add-link <vm>`. The link is a credential. Give it only in my reply to the owner, never save it. Removing a link later does not remove people who already used it.
- **Root access.** The person can change or delete anything on the VM. Strongly discourage it and ask twice.
- **Public.** `share port <vm> <port>` if needed, then `share set-public <vm>`. Say: "Anyone on the internet will be able to open this." Only one port can be public.
- **Custom domain.** The owner adds a CNAME to `<vm>.exe.xyz` at their DNS provider, or ALIAS or a flattened CNAME for a root domain, with Cloudflare proxy mode off. Then run `domain add <vm> <domain>`.

**Verify, every time.**
- On the VM, a request to `localhost:<port>` returns the expected response.
- A signed-out request to `https://<vm>.exe.xyz:<port>/` (or the main address) goes to the exe.dev sign-in, not the app. Once public, it reaches the app.
- The service still runs after a restart, if the owner agrees to one.
- After each share or domain change, run `share show <vm>` or `domain ls <vm>`. For private again, run `share set-private <vm>`, and a signed-out request goes to sign-in.

**Return:** the private address, each check and its result, the service name, and how to see its logs. Save the VM, port and service name as a memory. After a share or domain change, say what changed, who can now reach it, and how to undo it.

**Needs approval:** a new VM, deleting or overwriting anything, plan changes, and every share, going public or custom domain. Each approval names the VM, port, person or domain. A yes covers that one change only.
