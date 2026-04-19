# CLAUDE.md

## Project Overview

macOS security audit script — single-file bash tool that checks for indicators of compromise, persistence mechanisms, supply chain risks, and system hardening status. Designed for personal use on macOS (Darwin). Requires bash 4+ (for associative arrays).

## Usage

```bash
security-audit                        # Run all non-root checks (uses config if found)
security-audit --config=./config.yaml  # Use specific config file
security-audit --check=supply_chain    # Run single check
security-audit --list                  # List all checks with on/off status
security-audit --root                  # Also run checks needing elevated privileges
sudo security-audit --all             # Run everything including TCC/BTM
security-audit --help                 # Show usage
```

Symlink into PATH: `ln -s ~/workspace/macosx-audit/security-audit ~/bin/security-audit`

## Config

YAML config (`config.yaml`) with `key: true/false` format. Config search order:
1. `--config=PATH` (CLI flag)
2. `./config.yaml` (current directory)
3. `~/.config/macosx-audit/config.yaml`
4. `<script_dir>/config.yaml`
5. Built-in defaults (all non-root checks enabled)

Root-requiring checks (`tcc_permissions`, `btm_dump`) default to off — enable with `--root` or set `true` in config.

## What It Checks

| Category | Check Name | Details |
|----------|------------|---------|
| System Hardening | `system_hardening` | SIP, Gatekeeper, FileVault, macOS Firewall, software update auto-check |
| System Hardening | `sharing_services` | Automatic login, guest account, Remote Login (SSH), Screen Sharing (VNC), File Sharing (SMB/AFP) |
| Persistence | `launch_agents` | LaunchAgents/Daemons with allowlist + Apple path validation |
| Persistence | `cron_jobs` | Cron, at jobs, /etc/crontab |
| Persistence | `mdm_profiles` | MDM/configuration profiles |
| Persistence | `periodic_scripts` | /etc/periodic/ non-standard scripts |
| Persistence | `folder_actions` | Folder Action workflows |
| Persistence | `privileged_helpers` | /Library/PrivilegedHelperTools/ signature verification |
| Persistence | `login_items` | Login items (limited without root) |
| Persistence | `xprotect_status` | XProtect version + staleness check (>30 days) |
| Shell | `shell_profiles` | .zshrc, .zprofile, .zshenv, .bashrc, .bash_profile, .profile, .zshrc.d/ |
| Environment | `env_injection` | DYLD_INSERT_LIBRARIES, LD_PRELOAD, proxy hijack vars |
| Extensions | `extensions` | Kernel extensions, system extensions |
| Extensions | `auth_plugins` | Authorization plugins |
| SSH | `ssh_access` | authorized_keys entries |
| SSH | `ssh_config` | ProxyCommand (CVE-2025-61984), SendEnv/SetEnv, forwarding |
| Supply Chain | `supply_chain` | VS Code/Cursor extensions, npm globals, brew taps, MCP servers, pip, cargo binaries, Go binaries, ~/.local/bin |
| Supply Chain | `trusted_certs` | Custom trusted root CAs (user + admin domains): detects HTTPS interception proxies (mitmproxy, Charles, Burp Suite, Proxyman) and MDM-installed surveillance CAs |
| Supply Chain | `ai_agent_hooks` | Claude Code settings.json hooks, Cursor rules prompt injection, GitHub Copilot instructions injection |
| Supply Chain | `quarantine_events` | QuarantineEventsV2 DB: files downloaded via curl/wget/python/bash in the last 14 days (CLI downloads bypass browser security UI) |
| Config Abuse | `git_hooks` | Global hooks path + workspace repo hooks |
| Config Abuse | `path_security` | World-writable, missing, or empty PATH entries |
| Config Abuse | `dns_proxy` | DNS resolvers, system web/SOCKS proxy settings |
| Processes | `process_integrity` | Code signature verification (uses full args, not truncated comm) |
| Processes | `process_paths` | Binaries running from unusual paths |
| Network | `network_listening` | Listening ports via lsof |
| Network | `network_established` | Established connections (deduplicated, optional reverse DNS) |
| Network | `suspicious_ports` | Flag known backdoor ports (4444, 5555, 1337, etc.) |
| Network | `reverse_dns` | Reverse DNS on connections (off by default, adds latency) |
| Docker | `docker` | Running containers |
| Deep: Temp | `temp_executables` | Executables/scripts in /tmp, /var/tmp, /private/tmp |
| Deep: Privesc | `sudoers` | sudoers NOPASSWD entries, custom sudoers.d files, PAM module tampering |
| Deep: Supply | `browser_extensions` | Chrome, Brave, Firefox, Safari extension count + recent installs |
| Deep: Hiding | `hidden_files` | Dotfiles in temp dirs, extended attributes, Application Support hidden files |
| Deep: C2 | `reverse_shells` | Shell processes with network sockets, nc/ncat/socat connections |
| Deep: Integrity | `system_integrity` | Code signatures on critical binaries (login, sudo, ssh, sshd, su, env, passwd) |
| Deep: Persistence | `launchctl_state` | Running launchd services without matching plist files on disk |
| Deep: Injection | `dylib_injection` | DYLD_LIBRARY_PATH, DYLD_FRAMEWORK_PATH in profiles, /etc/launchd.conf, .dylib in temp/Downloads |
| Deep: C2 | `dns_tunneling` | Direct external DNS connections, DoH config, high DNS query volume |
| Deep: Forensic | `recently_modified` | Modified files in /usr/bin, /usr/sbin, /usr/lib, /System (last 7 days) |
| Deep: Forensic | `process_spoofing` | Process comm name vs actual binary path mismatch (com.apple.* fakes) |
| Deep: Forensic | `promiscuous_interfaces` | Network interfaces in promiscuous mode (packet sniffing) |
| Deep: Forensic | `deleted_running` | Processes running from deleted files (lsof +L1) |
| Elevated | `tcc_permissions` | TCC database: camera, mic, screen, accessibility, FDA (needs root/FDA) |
| Elevated | `btm_dump` | Background Task Management audit via sfltool (needs root) |

## Architecture

Single bash script (`security-audit`), no dependencies beyond macOS builtins + bash 4+. Optional YAML config file parsed with built-in grep/regex (no `yq` dependency).

Each check is a `check_<name>()` function. A dispatcher loop iterates `CHECKS` array and calls `check_enabled()` to gate execution based on config + CLI flags.

Output uses severity levels:
- `[OK]` green — check passed
- `[-]` dim — informational (known-good items, details)
- `[!]` yellow — warning, needs review
- `[!!]` red — critical finding

`KNOWN_AGENTS` array whitelists recognized LaunchAgent/Daemon prefixes. `com.apple.*` entries are additionally validated to point to Apple system paths.

## Threat Research (Round 2 Context)

The deep checks (round 2) are informed by research into:

- **C2 frameworks:** Mythic, Sliver, EvilOSX — use DYLD injection, reverse shells, DNS tunneling, process spoofing
- **macOS malware (2024-2025):** LightSpy (temp dir staging, deleted-file execution), RustyAttr (extended attribute abuse), ChillyHell (DYLD hijacking), NightPaw (DNS-based C2), DigitStealer (browser extension side-loading)
- **Rootkit techniques:** Binary replacement, promiscuous interfaces, process name spoofing, deleted-but-running binaries
- **rkhunter gaps:** The script now covers what rkhunter checks on Linux but adapted for macOS (system binary integrity, hidden files, /tmp abuse)

Detection strategy: each check targets a specific attack phase:
- **Initial access:** browser extensions, sudoers tampering
- **Persistence:** launchctl state, dylib injection
- **Execution:** temp executables, hidden files
- **C2 communication:** reverse shells, DNS tunneling
- **Defense evasion:** process spoofing, deleted running binaries, promiscuous interfaces
- **Discovery:** recently modified system files, system integrity

## Code Style

- Bash with `set -euo pipefail`
- Functions: `header()`, `ok()`, `warn()`, `fail()`, `info()` for consistent output
- Each check is a named `check_<name>()` function
- Findings accumulated in `FINDINGS` array for summary
- Read-only — never modifies the system
- Internal helper functions prefixed with `_` (e.g., `_check_plist_dir`)
