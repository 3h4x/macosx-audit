# macosx-audit

macOS security audit script. Checks for indicators of compromise, persistence mechanisms, and system hardening — all read-only, no modifications.

## Install

```bash
git clone git@github.com:3h4x/macosx-audit.git ~/workspace/macosx-audit
ln -s ~/workspace/macosx-audit/security-audit ~/bin/security-audit
```

## Usage

```bash
security-audit
```

## Checks

- **System Hardening** — SIP, Gatekeeper, FileVault, Firewall
- **Persistence** — LaunchAgents/Daemons (with known-good allowlist), cron/at jobs, MDM profiles
- **Shell Profiles** — scans `.zshrc`, `.bashrc`, `.zshrc.d/` etc. for reverse shells, `eval+curl`, base64 decode patterns
- **Environment** — DYLD injection, LD_PRELOAD, proxy hijacking
- **Extensions** — kernel extensions, system extensions, authorization plugins
- **SSH** — authorized_keys audit
- **Processes** — code signature verification, binaries running from unusual paths
- **Network** — listening ports, established connections (deduplicated)
- **Docker** — running containers

## Output

```
macOS Security Audit — 2026-03-24 10:00:00
Host: myhost | User: me | macOS 15.4

=== System Hardening ===
  [OK] System Integrity Protection (SIP) enabled
  [OK] Gatekeeper enabled
  [OK] FileVault disk encryption enabled
  [OK] macOS Firewall enabled

=== Persistence: LaunchAgents & LaunchDaemons ===
  [-] System Agent: com.google.keystone.agent -> /usr/bin/open
  [!] User Agent UNKNOWN: bot.molt.gateway -> /opt/homebrew/bin/node
      File: /Users/me/Library/LaunchAgents/bot.molt.gateway.plist
      Modified: 2026-01-29 15:03

─── Summary ───

1 finding(s):
  - User Agent UNKNOWN: bot.molt.gateway -> /opt/homebrew/bin/node
```

## Requirements

macOS only. Uses built-in tools: `codesign`, `csrutil`, `spctl`, `fdesetup`, `lsof`, `ps`, `PlistBuddy`, `profiles`, `systemextensionsctl`.

## License

MIT
