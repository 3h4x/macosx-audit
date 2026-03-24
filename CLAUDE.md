# CLAUDE.md

## Project Overview

macOS security audit script — single-file bash tool that checks for indicators of compromise, persistence mechanisms, and system hardening status. Designed for personal use on macOS (Darwin).

## Usage

```bash
security-audit        # Run full audit (read-only, no system modifications)
```

Symlink into PATH: `ln -s ~/workspace/macosx-audit/security-audit ~/bin/security-audit`

## What It Checks

| Category | Details |
|----------|---------|
| System Hardening | SIP, Gatekeeper, FileVault, macOS Firewall |
| Persistence | LaunchAgents/Daemons, cron, at jobs, MDM profiles |
| Shell Profiles | .zshrc, .zprofile, .zshenv, .bashrc, .bash_profile, .profile, .zshrc.d/ — scanned for reverse shells, eval+curl, base64 decode |
| Environment | DYLD_INSERT_LIBRARIES, LD_PRELOAD, proxy hijack vars |
| Extensions | Kernel extensions, system extensions, authorization plugins |
| SSH | authorized_keys entries |
| Processes | Code signature verification, unusual binary paths |
| Network | Listening ports, established connections (deduplicated by process+dest) |
| Docker | Running containers |

## Architecture

Single bash script, no dependencies beyond macOS builtins (`codesign`, `csrutil`, `spctl`, `fdesetup`, `lsof`, `ps`, `PlistBuddy`, `profiles`, `systemextensionsctl`).

Output uses severity levels:
- `[OK]` green — check passed
- `[-]` dim — informational (known-good items, details)
- `[!]` yellow — warning, needs review
- `[!!]` red — critical finding

`KNOWN_AGENTS` array whitelists recognized LaunchAgent/Daemon prefixes. Unknown entries are flagged as warnings with file path and modification time.

## Code Style

- Bash with `set -euo pipefail`
- Functions: `header()`, `ok()`, `warn()`, `fail()`, `info()` for consistent output
- Findings accumulated in `FINDINGS` array for summary
- Read-only — never modifies the system
