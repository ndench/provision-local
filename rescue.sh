#!/bin/bash
# Get a broken install to the point where Claude Code can debug it from a text console.
# Run as your normal user (not root) from a TTY (Ctrl+Alt+F3) or an arch-chroot. Safe to re-run: it
# changes nothing about the system except installing Claude Code into ~/.local/bin.
#
#   bash ~/git/ndench/provision-local/rescue.sh
#   claude

set -u

diag=~/rescue-diag
repo=~/git/ndench/provision-local

step() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }

step "Checking the network"
if ! curl -fsS --max-time 10 -o /dev/null https://claude.ai; then
  echo "No internet. Connect first, then re-run this script:"
  echo "  nmcli device wifi list"
  echo "  nmcli device wifi connect '<SSID>' --ask"
  echo "(or run 'nmtui'). If NetworkManager isn't running: sudo systemctl enable --now NetworkManager"
  exit 1
fi
echo "ok"

step "Installing Claude Code"
if command -v claude >/dev/null || [[ -x ~/.local/bin/claude ]]; then
  echo "already installed"
else
  curl -fsSL https://claude.ai/install.sh | bash
fi
export PATH="$HOME/.local/bin:$PATH"

step "Collecting diagnostics into $diag (so Claude reads facts, not guesses)"
mkdir -p "$diag"
{
  # current and previous boot: a black screen usually means the useful errors are in the boot you gave up on
  journalctl -b 0 -p warning --no-pager > "$diag/journal-this-boot-warnings.txt" 2>&1
  journalctl -b -1 --no-pager           > "$diag/journal-prev-boot.txt" 2>&1
  journalctl -b -1 -u lightdm --no-pager > "$diag/lightdm-prev-boot.txt" 2>&1
  journalctl --list-boots --no-pager     > "$diag/boots.txt" 2>&1
  systemctl --failed --no-pager          > "$diag/failed-units.txt" 2>&1
  sudo -n true 2>/dev/null && sudo cat /var/log/lightdm/*.log > "$diag/lightdm-logs.txt" 2>&1
  cat /var/log/Xorg.0.log ~/.local/share/xorg/Xorg.0.log > "$diag/xorg.txt" 2>/dev/null
  lsmod | grep -Ei 'nvidia|i915|nouveau' > "$diag/gpu-modules.txt" 2>&1
  lspci -k | grep -EiA3 'vga|3d|display' > "$diag/gpu-pci.txt" 2>&1
  cat /proc/cmdline > "$diag/cmdline.txt"
  grep -Ev '^\s*(#|$)' /etc/mkinitcpio.conf > "$diag/mkinitcpio.txt" 2>&1
  ls -la /boot > "$diag/boot-dir.txt" 2>&1; df -h /boot / >> "$diag/boot-dir.txt" 2>&1
  pacman -Q | grep -Ei 'nvidia|xorg-server|lightdm|linux ' > "$diag/packages.txt" 2>&1
  [[ -d $repo ]] && git -C "$repo" log --oneline -3 > "$diag/repo-state.txt" 2>&1
} || true
ls "$diag"

cat <<EOF

$(printf '\033[1;32mReady.\033[0m') Start Claude Code in the repo so it picks up CLAUDE.md:

  cd ${repo} 2>/dev/null || cd ~
  claude

It prints a login URL: open it on your phone, then paste the code back. Suggested first prompt:

  "I've just reinstalled using this repo's README. <describe the symptom>. Diagnostics are in
   ~/rescue-diag. Read them and the system logs before suggesting anything; don't guess."
EOF
