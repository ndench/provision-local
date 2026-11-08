#!/bin/sh
# Run by lightdm as root once X is up. lightdm stops the seat (and systemd restarts it in a loop)
# if this exits non-zero, so nothing here may fail the script: always exit 0.
exec >/var/log/lightdm/display_setup.log 2>&1
set -x

xrandr --listproviders

# With nvidia as PrimaryGPU the laptop panel hangs off the intel GPU, which has to be made an output sink
xrandr --setprovideroutputsource modesetting NVIDIA-0

# The panel is eDP-1-1 when it's on the intel sink and eDP-1 when intel is primary
edp=$(xrandr | awk '/^eDP/ {print $1; exit}')
[ -n "$edp" ] && xrandr --output "$edp" --auto

exit 0
