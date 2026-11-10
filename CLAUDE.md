# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ansible-based provisioning for Arch Linux personal workstations (installed with `archinstall`; previously ArchLabs, which is discontinued). Automates package installation, system configuration, and user setup to make a fresh machine ready for development. Also holds the dotfiles (`dotfiles/`, linked into `~` with rcm; see `dotfiles/CLAUDE.md`).

## Commands

```bash
# List the targets (default)
make

# Dry run: show what would change with diffs (prompts for sudo password)
make dry-run

# Apply for real
make apply

# Limit to specific Ansible tags (works with both)
make apply tags=provision-user
make dry-run tags=provision-arch skip-tags=provision-config

# Bootstrap on a fresh Arch install (one-liner)
bash <( curl -s https://raw.githubusercontent.com/ndench/provision-local/master/bootstrap.sh )

# Link dotfiles/ into ~ (bootstrap runs this; rerun after adding a file)
make rcup
```

## Architecture

**Ansible playbook** (`playbook.yml`) runs four roles against localhost:

| Role | Privilege | Tags | Purpose |
|------|-----------|------|---------|
| `weareinteractive.sudo` | `become: yes` | `provision-system`, `provision-sudo` | `/etc/sudoers.d/ansible` from `sudo_defaults`/`sudo_users` in vars.yml (external Galaxy role) |
| `arch` | `become: yes` | `provision-system`, `provision-arch` | Package installation, services, AUR |
| `system-config` | `become: yes` | `provision-system`, `provision-config` | LightDM, samba, X11 keyboard, systemd services |
| `user-config` | no sudo | `provision-user`, `provision-config` | SSH keys, `~/.rcrc`, app configs (ngrok, wakatime, docker) |

**Key files:**
- `group_vars/dev/vars.yml` — all package lists and configuration variables
- `group_vars/dev/vault.yml` — encrypted secrets (GitHub token, etc.)
- `ansible.cfg` — vault password file at `.ansible_vault.pass`, imported roles in `.imported_roles/`
- `requirements.yml` — external Ansible Galaxy role and collection dependencies (pinned versions)
- `bootstrap.sh` — initial setup script (installs git/make, clones repo, runs provisioning)
- `dotfiles/` — home directory config (i3, zsh, nvim, ...) symlinked into `~` by rcm, not Ansible
- `pkgbuilds/` — local PKGBUILDs (not on the AUR), built by the `arch` role from the `local_packages` var

**Patterns:**
- System and secret config lives in `roles/*/files/` and is deployed via Ansible `copy`. Plain user config goes in `dotfiles/` instead, so edits are live without `make apply`
- A dedicated `aur_builder` user is created for AUR package operations
- Swap is zram only (zswap disabled), with earlyoom as the OOM killer; systemd-oomd is deliberately unused because it kills whole cgroups and i3 runs every app in one session scope
- Nvidia early KMS (mkinitcpio `MODULES`, `kms` hook removed) is required: without it Xorg can start before nvidia-drm and come up intel-only (black screen / dead dock monitors). It fits the 260M `/boot` because dropping `kms` removes nouveau's firmware
- Secrets are managed with Ansible Vault (password file: `.ansible_vault.pass`)
- The Makefile auto-installs Ansible (pacman) and `requirements.yml` (the sudo role and the `kewlfft.aur` collection, pinned, into `.imported_roles/`) when missing or changed
- Modules use FQCNs (`ansible.builtin.*`, `community.general.*`, `kewlfft.aur.aur`); lint with `uvx ansible-lint` (config in `.ansible-lint`; the two `community.general` unknown-module errors are false positives from uvx's isolated env)

## Working on the live machine

This repo provisions the machine you're running on, so commands act on the user's real desktop session. Never run session or power actions to test them: no `xautolock -locknow`, `i3lock`, `i3-msg exit`, `systemctl poweroff`/`reboot`/`suspend` (not even with `--dry-run`), and nothing a rofi/menu entry would trigger. Debug these by reading the scripts and checking state (`command -v`, `pacman -Q`, `fc-list`, `journalctl`). If a live test is really needed, give the user the command to run themselves.

sudo needs a password, so Claude can't run it. When something needs root (installing a package, `make apply`), give the user the command to run in their own terminal, and don't suggest running it in the session with the `!` prefix.

## Git

Commit straight to `master` and push; don't create feature branches or PRs. If you're in a worktree on another branch, push with `git push origin HEAD:master`.
