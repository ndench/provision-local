# provision-local
Scripts to provision my PCs in the "one true way".

## Setup from scratch

[ArchLabs Linux](https://en.wikipedia.org/wiki/ArchLabs) is discontinued (last release June 2023), so
install plain Arch with the official guided installer instead:

1. Boot the [Arch ISO](https://archlinux.org/download/) and run `loadkeys dvorak`. Without a network cable,
   connect to Wi-Fi with `iwctl` (`station wlan0 connect <SSID>`). Then run `archinstall`
2. Choose:
    - **Keyboard layout**: `dvorak`. This repo sets the console keymap to dvorak and rebuilds the initramfs,
      so the LUKS prompt switches to dvorak on the next boot. A passphrase set with the US layout would no
      longer unlock the disk
    - **Locale**: `en_AU.UTF-8`, **Timezone**: `Australia/Brisbane` (this repo doesn't manage either)
    - **Hostname**: `sigbus`. The bootstrap uploads the new SSH key to GitHub under the hostname, so keeping
      it replaces the old key instead of adding another
    - **Disk layout**: wipe the disk, ext4 root, and a **2 GiB** `/boot` (EFI) partition so there's room
      for a fallback initramfs and extra kernels
    - **Disk encryption**: LUKS on the root partition
    - **Bootloader**: systemd-boot
    - **Profile**: Desktop → i3 (pulls in xorg, lightdm and lightdm-gtk-greeter), graphics driver: nvidia (open kernel modules)
    - **Network**: NetworkManager
    - **Audio**: pipewire
    - **User**: `nathan` with sudo
3. Reboot into the new install, connect to Wi-Fi with `nmtui` if needed, and run the bootstrap one liner. It
   asks for the vault password (`.ansible_vault.pass`, kept in 1Password):

```sh
$ bash <( curl -s https://raw.githubusercontent.com/ndench/provision-local/master/bootstrap.sh )
```

4. ext4 reserves 5% of the root filesystem for root, and archinstall can't change it. Drop it to 1%:

```sh
$ sudo tune2fs -m 1 "$(findmnt -no SOURCE /)"
```

## Running on an existing machine

Run `make` to list the commands. Preview what would change (a dry run with diffs; nothing is modified):

```sh
$ make dry-run
```

Then apply it:

```sh
$ make apply
```

You can speed up ansible execution by passing in `tags` and `skip-tags`

```sh
$ make apply tags=foo,bar skip-tags=baz
# Will pass --tags foo,bar --skip-tags baz to ansible-playbook
```

## Merging .pacnew files

When a package ships a new default for a config file you've changed, pacman leaves it next to yours as
`<file>.pacnew` instead of overwriting. These contain real upstream changes (new options, security
defaults), so merge them. You'll get a desktop notification each day while any exist (`pacnew-check.timer`),
and `make apply` lists them at the end of the run.

```sh
$ sudo DIFFPROG='nvim -d' pacdiff
```

For each file pacdiff lets you (v)iew the diff, (m)erge it in the diff tool, (r)emove the pacnew to keep
your version, or (o)verwrite yours with the pacnew.

Check whether this repo manages the file first:

- **Copied whole** (from `roles/*/files/etc/`), eg. `pacman.conf`, `nsswitch.conf`, `samba/smb.conf`: merge the
  pacnew into the repo copy, run `make apply`, then remove the pacnew. Merging only into `/etc` gets overwritten
  on the next run.
- **Edited line by line** (`lineinfile` tasks), eg. `mkinitcpio.conf`, `makepkg.conf`, `lightdm/lightdm.conf`,
  `hosts`: overwrite with the pacnew, then run `make apply` to re-apply the edits.
- **`sudoers`**: keep it stock and take the pacnew. Sudo rules live in `/etc/sudoers.d/ansible` (`sudo_users`
  in `group_vars/dev/vars.yml`).
- **Not managed here**: merge in place.

## Reinstall plan (Oct 2026)

Goal: remove the Windows partitions, give Linux the whole disk, and grow `/boot` from 260M to 2G for
headroom. (Nvidia early KMS doesn't need the bigger `/boot`, see [Nvidia early KMS](#nvidia-early-kms).)

### 1. Make sure this repo reproduces the current machine

The packages, services, `/etc` config and cleanup timers that had been set up by hand are now in this
repo. Things that can't live here:

- [x] Copy drifted/unmanaged configs into the dotfiles repo (gtk, mimeapps, nitrogen, zshenv/profile,
      i3status, htop, zed, herdr, git ignore, alacritty, autostart entries). Not tracked on purpose:
      `~/.local/share/applications/` and `~/.config/autostart/electron.desktop` are written by apps
      themselves, and `archlabs.rasi` is unused (rofi uses the built-in `arthur` theme)
- [x] Replace ArchLabs-only bits: Adwaita-dark instead of the ArchLabs theme/icons, `i3-msg exit` instead of
      `session-logout`, dropped `al-info` and `xfsettingsd`. The `archlabs-*` packages are now removed by the
      `arch` role
- [x] Move the `~/.local/bin` PATH line from `/etc/profile` into the dotfiles (`zshenv` and `profile`)
- [ ] After reinstalling, pick a wallpaper with nitrogen (the old one came from `archlabs-wallpapers`)

### 2. Back up everything that only exists on this machine

Reviewed on 8 Nov 2026. Everything not listed here was deliberately left behind.

- [x] Git work. Unpushed commits are either on branches already squash-merged on GitHub or old spikes; not
      kept. Gitignored files were checked too (`git status --ignored`), since `git status` hides them, e.g.
      project-datum's `Data/`
- [x] `~/Documents`: only `Biodiversity Offset Walaroi`, `Sandbox Test Project Drawings` and
      `mcconaghy-dump-final` are kept, copied to a USB stick
- [x] Not kept: other home folders, `~/bin`, `~/.claude`, `~/.codex`, Docker volumes, browser profiles
- [x] `pkgbuilds/` matches the newest PKGBUILDs in `~/pkgs`
- [ ] Check 1Password has:
    - `.ansible_vault.pass` (this repo, gitignored; the bootstrap asks for it and nothing in the vault can
      be decrypted without it)
    - `~/.ssh/` keys (`id_rsa` and the `.pem` jump host keys)
    - gitignored `.env*`, `.Halite.key`, `terraform.tfvars` and certs across `~/git`
      (`find ~/git \( -name '.env*' -o -name '*.tfvars' -o -name '*.key' -o -name '*.pem' \) -not -path '*/node_modules/*'`)
    - the samba password, for `sudo smbpasswd -a nathan`
- [x] The vault's GitHub token (used by the bootstrap to upload the SSH key) is valid until 2027-11-06

### 3. Boot into Windows one last time

- [x] Update BIOS/UEFI, embedded controller, Thunderbolt and SSD firmware with Lenovo Vantage. Windows drivers
      don't matter once Windows is gone, firmware does. Afterwards `fwupdmgr update` can handle most updates
      from Linux.

### 4. Reinstall

- [ ] Follow [Setup from scratch](#setup-from-scratch)
- [ ] Restore the Documents backup (the bootstrap already ran `make rcup`)
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
- `tpacpi-bat` (in `aur_packages`) is unused: TLP sets the charge thresholds through natacpi
  (`TPACPI_ENABLE=0`). Remove it, or switch TLP to it if natacpi stops working

## Nvidia early KMS

The `arch` role adds `i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm` to `MODULES` in
`/etc/mkinitcpio.conf`, removes the `kms` hook (so nouveau isn't added to the initramfs), and installs a
pacman hook to rebuild the initramfs when `nvidia-open` is upgraded.

This is required, not an optimisation. Without it `nvidia-drm` loads after the root fs is mounted and races
lightdm. If Xorg starts first it only sees the intel GPU, `display_setup.sh` can't find `NVIDIA-0`, and you get
a black screen after the LUKS prompt. Dock monitors (wired to the nvidia GPU) also stay off, because nvidia
takes longer to initialise when the dock is connected.

It fits on the old 260M `/boot`. The `kms` hook pulls in nouveau and all of `linux-firmware-nvidia`, so
swapping it for the nvidia modules shrinks the initramfs (134M → 108M).

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
