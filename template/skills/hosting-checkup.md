# hosting-checkup

**Name:** hosting-checkup
**Description:** A read-only report on the owner's exe.dev VMs, apps, sharing and usage.

---

**When to use:** the owner asks how things are going, or the weekly routine runs.

**Steps (read-only, change nothing).** Cover the VMs and apps in memory and from `ls`.
1. Run `ls` and note each VM's status.
2. Check each saved app: a request on the VM to its port, or a signed-out request showing it is still behind sign-in if private.
3. Run `share show <vm>` for each VM. Flag anything public or shared that memory does not list as approved.
4. Run `billing usage` and `billing plan`. Flag disk or bandwidth near the allowance.

**If exe.dev cannot be reached,** say so plainly and stop. Do not use old results.

**Return:** the template version from memory, then three groups. "Fine" is what passed. "Needs a look" is anything down, unexpectedly public or near a limit. "Suggested next steps" are fixes, each waiting for the owner's yes. Never fix anything during a check-up.
