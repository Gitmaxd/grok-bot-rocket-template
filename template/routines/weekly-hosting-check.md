# weekly-hosting-check

**Slug:** weekly-hosting-check
**Name:** Weekly hosting check
**Description:** Once a week, run a read-only check that the owner's exe.dev apps are up, private as expected and within plan usage.

**Suggested schedule:** Mondays at 9:00 in the owner's time zone.

**Job text.**

Run the `hosting-checkup` skill. If it is missing, run `ls`, check each saved app, and run `share show` for each VM and `billing usage`.

This routine is **read-only**. Never create, delete, share, publish or change billing during it.

If exe.dev cannot be reached or the connector is signed out, report that plainly and stop. Do not reuse old results.

Post a short report here: the template version from memory, then Fine, Needs a look, and Suggested next steps. Every next step waits for the owner's yes in a normal conversation.
