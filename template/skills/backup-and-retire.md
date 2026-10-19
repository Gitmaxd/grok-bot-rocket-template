# backup-and-retire

**Name:** backup-and-retire
**Description:** Back up an app's data, move it to another VM, or delete a VM, without ever losing the only copy.

---

**When to use:** the owner wants a backup, wants to merge small VMs, remove something, or disconnect.

**Backup.** Offer two options.
- Copy the files out, to the Bot's shared workspace or another VM, and compare sha256 checksums.
- Copy the whole VM. This makes a new VM, so it uses capacity and may cost money. **Ask first.**

**Move.** Copy the data, compare checksums, start the app in the new place and run the `launch-app` checks. Show the owner both places working. The old VM stays until the owner confirms the new one.

**Retire (delete).**
1. Run `share show <vm>` and `domain ls <vm>`. List what will stop working: the address, shares, domains and the data on disk.
2. Say clearly: "Deleting `<vm>` is permanent. Its disk cannot be recovered." Ask for a yes that names the VM.
3. Remove domains first if the owner wants them moved.
4. Run `rm <vm>`, then `ls` to confirm it is gone.

A yes covers one VM. For a second VM, ask again.

**Disconnect.** Removing the connector in Grok Bot does not revoke its exe.dev key. Find its `mcp-cursor-N` label, or a retired token's label, with `ssh-key list`. With the owner's yes, run `ssh-key remove <label>`, then `ssh-key list` to confirm.

**Return:** what was copied and verified, what was deleted or revoked, and what remains.
