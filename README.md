# provision-local
Scripts to provision my PCs in the "one true way".

## Setup from scratch

Run the following one liner on a newly installed [ArchLabs Linux](https://archlabslinux.com/):

```sh
$ bash <( curl -s https://raw.githubusercontent.com/ndench/provision-local/master/bootstrap.sh )
```

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

## TODO:
- check other laptop things https://wiki.archlinux.org/index.php/Laptop
- check power management https://wiki.archlinux.org/index.php/Power_management
- Configure tmux [example 1](https://github.com/gpakosz/.tmux), [example 2](https://peterforgacs.github.io/2017/04/25/Tmux/)
- check ~/.config/mimeapps.list
- figure out why dockd isn't working
- [Add pritunl keys](https://client.pritunl.com/)

## Update scripts
- update /etc/mkinitcpio.conf to add `keyboard keymap consolefont` after `autodetect`
- update /etc/mkinitcpio.conf to add `nvidia nvidia_modeset nvidia_uvm nvidia_drm i915` to MODULES
- update /etc/default/grub to set GRUB_TIMEOUT=1
- update /etc/default/grub to add nvidia-drm.modeset=1 kernel parameter
- need to run `sudo rm /usr/share/fonts/TTF/AL\ *` before installing archlabs-fonts
- Install dkms linux-headers nvidia nvtop mesa-utils iotop nvidia-prime nvidia-utils nvidia-settings vulkan-tools vulkan-intel xfce4-sensors-plugin
- Ensure tpacpi-bat is removed
- Get nvidia udev rules for PRIME render offload: <https://wiki.archlinux.org/title/PRIME#PRIME_render_offload>
- Add nvidia pacman hook
- run sensors-detect
- install bolt acpid dockd
- start/enable acpid
- configure dockd <https://wiki.archlinux.org/title/ThinkPad_docks>


## Secret files to put in syncret

- ~/.docker/config.json
- ~/.ssh
- ~/.wakatime.cfg


## Things archlabs does
- reflector --score 100 -l 50 -f 5 --sort rate --verbose
- packages: 
    - i3-gaps
    - i3status
    - perl-anyevent-i3
    - archlabs-skel-i3-gaps
    - rofi
    - archlabs-polybar
    - lightdm
    - lightdb-gtk-greeter
    - lightdm-gtk-greeter-settings
    - accountservice

