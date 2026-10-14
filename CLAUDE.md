# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ansible-based provisioning for Arch Linux personal workstations (installed with `archinstall`; previously ArchLabs, which is discontinued). Automates package installation, system configuration, and user setup to make a fresh machine ready for development.

## Commands

```bash
# Run full provisioning (prompts for sudo password)
make

# Run with specific Ansible tags
make tags=provision-user
make tags=provision-arch skip-tags=provision-config

# Bootstrap on a fresh Arch install (one-liner)
bash <( curl -s https://raw.githubusercontent.com/ndench/provision-local/master/bootstrap.sh )

# After bootstrap, set up dotfiles
make rcup
```

## Architecture

**Ansible playbook** (`playbook.yml`) runs four roles against localhost:

| Role | Privilege | Tags | Purpose |
|------|-----------|------|---------|
| `weareinteractive.sudo` | `become: yes` | `provision-system`, `provision-sudo` | `/etc/sudoers.d/ansible` from `sudo_defaults`/`sudo_users` in vars.yml (external Galaxy role) |
| `arch` | `become: yes` | `provision-system`, `provision-arch` | Package installation, services, AUR |
| `system-config` | `become: yes` | `provision-system`, `provision-config` | LightDM, samba, X11 keyboard, systemd services |
| `user-config` | no sudo | `provision-user`, `provision-config` | SSH keys, dotfiles, app configs (ngrok, wakatime, docker) |

**Key files:**
- `group_vars/dev/vars.yml` — all package lists and configuration variables
- `group_vars/dev/vault.yml` — encrypted secrets (GitHub token, etc.)
- `ansible.cfg` — vault password file at `.ansible_vault.pass`, imported roles in `.imported_roles/`
- `requirements.yml` — external Ansible Galaxy role dependencies
- `bootstrap.sh` — initial setup script (installs git/make, clones repo, runs provisioning)
- `pkgbuilds/` — local PKGBUILDs (not on the AUR), built by the `arch` role from the `local_packages` var

**Patterns:**
- Config files live in `roles/*/files/` and are deployed via Ansible `copy` module
- A dedicated `aur_builder` user is created for AUR package operations
- Nvidia early KMS (mkinitcpio `MODULES`) is only applied when `/boot` is at least 1 GiB
- Secrets are managed with Ansible Vault (password file: `.ansible_vault.pass`)
- The Makefile auto-installs Ansible and the AUR helper module if missing
