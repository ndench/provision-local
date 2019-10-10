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
- install docd https://wiki.archlinux.org/index.php/ThinkPad_docks
- check other thinkpad things https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_T470
- check other laptop things https://wiki.archlinux.org/index.php/Laptop
- check power management https://wiki.archlinux.org/index.php/Power_management
- use nvm instead of nodejs https://wiki.archlinux.org/index.php/Node.js_
- Configure tmux [example 1](https://github.com/gpakosz/.tmux), [example 2](https://peterforgacs.github.io/2017/04/25/Tmux/)
- check ~/.config/mimeapps.list
- update /etc/mkinitcpio.conf to add `keyboard keymap consolefont` after `autodetect`
- need to run `sudo rm /usr/share/fonts/TTF/AL\ *` before installing archlabs-fonts


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

## Video driver problems

arch linux labs creates the following in `/etc/X11/xorg.conf.d/20-intel.conf`:
```
Section "Device"
    Identifier  "Intel Graphics"
    Driver      "intel"
    Option      "TearFree" "true"
EndSection
```

I've tried using `nouveau` instead of `intel` except nouveau is for nvidia and not intel :(.
Trying `modesetting` and `vesa` as well.
Also installed `intel-media-driver` and `vulkan-intel` as recommended by the [wiki](https://wiki.archlinux.org/index.php/Intel_graphics).
