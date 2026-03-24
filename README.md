# macosx-audit

macOS security audit script. Checks for indicators of compromise, persistence mechanisms, supply chain risks, and system hardening — all read-only, no modifications.

## Requirements

- **macOS** (Darwin)
- **bash 4+** — macOS ships bash 3; install with `brew install bash`
- Uses built-in tools: `codesign`, `csrutil`, `spctl`, `fdesetup`, `lsof`, `ps`, `PlistBuddy`, `profiles`, `systemextensionsctl`, `scutil`, `networksetup`, `sqlite3`

## Install

```bash
git clone git@github.com:3h4x/macosx-audit.git ~/workspace/macosx-audit
ln -s ~/workspace/macosx-audit/security-audit ~/bin/security-audit
```

## Usage

```bash
security-audit                        # Run all non-root checks
security-audit --config=./config.yaml  # Use specific config file
security-audit --check=supply_chain    # Run single check
security-audit --list                  # List all checks with on/off status
security-audit --root                  # Also run checks needing elevated privileges
sudo security-audit --all             # Run everything including TCC/BTM
security-audit --help                 # Show usage
```

## Configuration

Optional `config.yaml` with `key: true/false` format. Config is auto-detected from:
1. `./config.yaml`
2. `~/.config/macosx-audit/config.yaml`
3. `<script_dir>/config.yaml`

Or specify with `--config=PATH`. Without a config file, all non-root checks run by default.

## Checks

**Core:**
- **System Hardening** — SIP, Gatekeeper, FileVault, Firewall
- **Persistence** — LaunchAgents/Daemons (with allowlist + Apple path validation), cron/at jobs, MDM profiles
- **Shell Profiles** — scans `.zshrc`, `.bashrc`, `.zshrc.d/` etc. for reverse shells, `eval+curl`, base64 decode
- **Environment** — DYLD injection, LD_PRELOAD, proxy hijacking
- **Extensions** — kernel extensions, system extensions, authorization plugins
- **SSH** — authorized_keys audit
- **Processes** — code signature verification, binaries from unusual paths (full args, no 16-char truncation)
- **Network** — listening ports, established connections (deduplicated), suspicious port detection
- **Docker** — running containers

**Persistence & Integrity (new):**
- **Periodic Scripts** — `/etc/periodic/` non-standard scripts
- **Folder Actions** — workflow bundles in Folder Actions directory
- **Privileged Helpers** — `/Library/PrivilegedHelperTools/` signature verification
- **XProtect Status** — version and staleness check (warns if >30 days old)
- **Login Items** — visible login items (use BTM for full coverage)

**Supply Chain (new):**
- **VS Code extensions** — count + flag recently installed (<7 days)
- **npm globals** — list global packages
- **Homebrew taps** — flag non-default taps
- **MCP servers** — parse Claude Desktop and Cursor MCP configs
- **pip user packages** — count user-installed packages

**Configuration Abuse (new):**
- **SSH Config** — ProxyCommand (CVE-2025-61984), SendEnv/SetEnv, forwarding rules
- **Git Hooks** — global hooks path + workspace repo hooks
- **PATH Security** — world-writable, missing, or empty PATH entries
- **DNS & Proxy** — DNS resolver audit, system proxy settings

**Elevated (disabled by default):**
- **TCC Permissions** — camera, mic, screen recording, accessibility, FDA grants
- **BTM Dump** — full Background Task Management audit via sfltool

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

=== Supply Chain ===
  [-] VS Code: 42 extension(s) installed
  [OK] No recently installed VS Code extensions
  [!] Non-default brew tap: some/custom-tap
  [!] MCP config with 3 server(s): Claude/claude_desktop_config.json

─── Summary ───

2 finding(s):
  - User Agent UNKNOWN: bot.molt.gateway -> /opt/homebrew/bin/node
  - Non-default brew tap: some/custom-tap
```

## License

MIT
