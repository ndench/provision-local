# provision-local
Scripts to provision my PCs in the "one true way".

## Setup from scratch

[ArchLabs Linux](https://en.wikipedia.org/wiki/ArchLabs) is discontinued (last release June 2023), so
install plain Arch with the official guided installer instead:

1. Boot the [Arch ISO](https://archlinux.org/download/) and run `archinstall`
2. Choose:
    - **Disk layout**: wipe the disk, ext4 root, and a **2 GiB** `/boot` (EFI) partition so the nvidia
      modules fit in the initramfs
    - **Disk encryption**: LUKS on the root partition
    - **Bootloader**: systemd-boot
    - **Profile**: Desktop → i3 (pulls in xorg, lightdm and lightdm-gtk-greeter), graphics driver: nvidia (open kernel modules)
    - **Network**: NetworkManager
    - **Audio**: pipewire
    - **User**: `nathan` with sudo
3. Reboot into the new install and run the bootstrap one liner:

```sh
$ bash <( curl -s https://raw.githubusercontent.com/ndench/provision-local/master/bootstrap.sh )
```

If you format the root filesystem by hand, use `mkfs.ext4 -m 1` so ext4 only reserves 1% (instead of 5%)
for root.

## Running on an existing machine

Just run:

```sh
$ make
```

You can speed up ansible execution by passing in `tags` and `skip-tags`

```sh
$ make tags=foo,bar skip-tags=baz
# Will pass --tags foo,bar --skip-tags baz to ansible-playbook
```

## Blocking a broken package version

Add the package to `pacman_blocked_versions` in `group_vars/dev/vars.yml` with the broken version and the
last good one, then run `make tags=pacman-hold`. While the repo still has the broken version the package is
in `IgnorePkg` (and the good version is installed from the Arch Linux Archive if needed). Once a newer version
is released the next `make` lets it upgrade again, and the entry can be deleted.

## Reinstall plan (Oct 2026)

Goal: remove the Windows partitions, give Linux the whole disk, and grow `/boot` from 260M to 2G so the
nvidia modules can be loaded early from the initramfs.

### 1. Make sure this repo reproduces the current machine

The packages, services, `/etc` config and cleanup timers that had been set up by hand are now in this
repo. Things that can't live here:

- [ ] Copy drifted/unmanaged configs into the dotfiles repo:
    - real files (not symlinks): `~/.gtkrc-2.0`, `~/.config/gtk-3.0/settings.ini`,
      `~/.config/mimeapps.list`, `~/.config/nitrogen/nitrogen.cfg`
    - not in dotfiles at all: `~/.zshenv`, `~/.profile`, `~/.config/alacritty/`, `~/.config/i3status/`,
      `~/.config/htop/`, `~/.config/zed/`, `~/.config/herdr/`, `~/.config/rofi/archlabs.rasi`,
      `~/.config/git/ignore`, `~/.config/autostart/`, `~/.local/share/applications/`
    - fix the broken `~/.zsh/settings/completion.zsh` symlink
- [ ] Replace ArchLabs-only bits the dotfiles rely on:
    - `session-logout` (from `archlabs-scripts`) is used by `bin/rofi_run`
    - ArchLabs-Dark GTK theme and ArchLabs icons (`archlabs-themes`, `archlabs-icons`)
    - `i3lock-color` now comes from the AUR instead of `archlabs-i3lock-color`
    - `xfsettingsd` is started by the i3 config but isn't installed (drop it from the i3 config)
- [ ] Move the `~/.local/bin` PATH line from `/etc/profile` into the dotfiles `zshenv`

### 2. Back up everything that only exists on this machine

- [ ] Push or back up unpushed git work (check with
      `for d in ~/git/*/*/; do git -C "$d" log --branches --not --remotes --oneline 2>/dev/null | head -1 | sed "s|^|$d: |"; done`):
    - `hyraiq/topcat`: ~124 local-only commits across 41 branches, 2 stashes, and worktrees in
      `~/git/hyraiq/topcat-wt/` (especially `pla-794-trade-timeline-interface`)
    - stashes / local branches in tequila, on-prem-proxy, prototypes, mobjack, trussle
    - `~/git/hyraiq/bdd-metrics` (not a git repo)
- [ ] Secrets:
    - `.ansible_vault.pass` (this repo, gitignored; nothing in the vault can be decrypted without it)
    - `~/.ssh/` (`id_rsa` and the `.pem` jump host keys)
    - gitignored `.env*`, `.Halite.key`, `terraform.tfvars` and certs across `~/git`
      (`find ~/git \( -name '.env*' -o -name '*.tfvars' -o -name '*.key' -o -name '*.pem' \) -not -path '*/node_modules/*'`)
- [ ] `~/Documents`, `~/Downloads`, `~/Pictures`, `~/Videos`, `~/Desktop`, `~/.factorio`, `~/.wine`, `~/.fonts`
- [ ] `~/.claude/` (settings, hooks, skills) and `~/.codex/config.toml` + `~/.codex/AGENTS.md`
- [ ] `~/.cache/yay/openai-codex-desktop/PKGBUILD`: the package has been removed from the AUR, so this is the only copy
- [ ] Docker volumes with data you care about (`docker volume ls`), e.g. dump `app_db` and `foundry_db-data`
- [ ] Browser profiles (or make sure sync is on): Brave, Chrome, Firefox
- [ ] Note the samba password, you'll need to re-run `sudo smbpasswd -a nathan`

### 3. Boot into Windows one last time

- [ ] Update BIOS/UEFI, embedded controller, Thunderbolt and SSD firmware with Lenovo Vantage. Windows drivers
      don't matter once Windows is gone, firmware does. Afterwards `fwupdmgr update` can handle most updates
      from Linux.

### 4. Reinstall

- [ ] Follow [Setup from scratch](#setup-from-scratch)
- [ ] Restore backups, then `make rcup`
- [ ] Manual steps after provisioning:
    - sign in to 1Password and enable the SSH agent (`~/.ssh/config` uses `~/.1password/agent.sock`)
    - re-enrol `drata-agent`
    - [add pritunl profiles](https://client.pritunl.com/)
    - install Claude Code (`curl -fsSL https://claude.ai/install.sh | bash`) and the node versions you need with `nvm`
    - `sudo smbpasswd -a nathan`
    - `sudo sensors-detect`
- [ ] Check early KMS worked: `lsinitcpio /boot/initramfs-linux.img | grep nvidia`

## TODO:
- check other laptop things https://wiki.archlinux.org/index.php/Laptop
- check power management https://wiki.archlinux.org/index.php/Power_management
- Configure tmux [example 1](https://github.com/gpakosz/.tmux), [example 2](https://peterforgacs.github.io/2017/04/25/Tmux/)
- figure out why dockd isn't working

## Update scripts
- update /etc/mkinitcpio.conf to add `keyboard keymap consolefont` after `autodetect`
- Install dkms linux-headers nvtop mesa-utils iotop nvidia-prime nvidia-settings vulkan-tools vulkan-intel xfce4-sensors-plugin
- Ensure tpacpi-bat is removed
- Get nvidia udev rules for PRIME render offload: <https://wiki.archlinux.org/title/PRIME#PRIME_render_offload>
- run sensors-detect
- install bolt acpid dockd
- start/enable acpid
- configure dockd <https://wiki.archlinux.org/title/ThinkPad_docks>

## Nvidia early KMS

The `arch` role adds `i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm` to `MODULES` in
`/etc/mkinitcpio.conf`, removes the `kms` hook (so nouveau isn't added to the initramfs), and installs a
pacman hook to rebuild the initramfs when `nvidia-open` is upgraded. It's skipped if `/boot` is smaller than
1 GiB, because the nvidia firmware won't fit.

## Secret files to put in syncret

- ~/.docker/config.json
- ~/.ssh
- ~/.wakatime.cfg

## Handling disk usage

These run automatically:

- `paccache.timer` (weekly) keeps the last 3 versions of each package in the pacman cache
- journald is capped at 500M and coredumps at 1G
- docker container logs are rotated (10M x 3 per container)
- the `cleanup-caches.timer` user timer weekly prunes docker images older than a week, stopped containers,
  old yay build dirs and Codex's leftover marketplace staging dirs

These still need a manual run every now and then:

- `paccache -rk1` / `paccache -ruk0` to clear more of the pacman cache
- `pip cache purge`, `npm cache clean --force`, `yarn cache clean`
- delete old IDE versions from `~/.cache/JetBrains` and `~/.local/share/JetBrains` after a major upgrade
- `npx npkill` to delete `node_modules` in inactive projects, and `rm -rf .terraform` in inactive infra repos
- use `ncdu /` or `baobab` to see what's using the space
