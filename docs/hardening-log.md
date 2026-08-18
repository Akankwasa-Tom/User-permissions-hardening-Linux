#Hardening log

#2026-06-20 ---------> Initial Hardening complete

### Environment
- OS: Ubuntu (WSL2 on Windows)
- Machine: Atomix
- Admin user: atom
- Project user: devuser

------------------
### Phase 1 — User Management
- Deleted unknown legacy users: bsit, b24316
- Locked sync system account (shell changed to /usr/sbin/nologin)
- Created dedicated admin user: devuser
- Added devuser to sudo group
- Verified only root, atom, devuser can log in interactively
- Set sudoers timestamp_timeout to 5 minutes

-------------------

### Phase 2 — SSH Hardening
- Installed OpenSSH server
- Configured SSH to run on non-default port 222 (I used port 222 because my 22 port is having another service running 
- Generated ed25519 key pair for atom
- Configured authorized_keys for devuser
- Disabled password authentication (key-based only)
- Disabled direct root SSH login
- Set MaxAuthTries to 3 (brute force protection)
- Set idle timeout: ClientAliveInterval 300 x ClientAliveCountMax 2 = 10 minutes
- Fixed missing /run/sshd privilege separation directory
- Persisted /run/sshd creation via /etc/rc.local
- Removed invalid Authentication: label that was crashing sshd

---------------------

### Phase 3 — Firewall
- Installed and enabled UFW
- Set default policy: deny all incoming, allow all outgoing
- Allowed port 222/tcp (SSH)
- Allowed port 80/tcp (HTTP)
- Allowed port 443/tcp (HTTPS)

### Phase 4 — Verification
- Written check-hardening.sh with 12 automated checks
- All 12 checks passing on final run

----------------------

### Lessons learned
- Git does not track empty directories — solved with .gitkeep files
- sshd_config crashed due to invalid Authentication: label on line 39
- /run/sshd is ephemeral on WSL — must be recreated on each WSL start
- SSH keys must live in WSL filesystem, not Windows filesystem
- SSH commands require -p 222 because of non-default port
- Always test SSH key login before disabling password auth

----------------------
# Brief description of process
SSH is locked down to key-based authentication only on **port 222** — meaning no passwords, no root login,
and automatic disconnection after **10 minutes** of idle time, so the only way into the server is with the correct private key.

A firewall using **UFW** is configured to deny all incoming traffic by default and only allow the three ports the server actually needs:

| Port | Protocol | Purpose |
|------|----------|---------|
| 222  | TCP      | SSH     |
| 80   | TCP      | HTTP    |
| 443  | TCP      | HTTPS   |

Everything is verified by an **automated bash script** that runs 12 checks and produces a pass/fail report,
with all configs and documentation tracked in **Git** so the entire hardened state is reproducible and auditable.
