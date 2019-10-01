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

## Video drivers that were installed
```
└> % pacman -Ss xf86-video                                                                                                                                                                                 11:35:38
extra/xf86-video-amdgpu 19.0.1-1 (xorg-drivers) [installed]
    X.org amdgpu video driver
extra/xf86-video-ati 1:19.0.1-1 (xorg-drivers) [installed]
    X.org ati video driver
extra/xf86-video-dummy 0.3.8-3 (xorg-drivers) [installed]
    X.org dummy video driver
extra/xf86-video-fbdev 0.5.0-1 (xorg-drivers) [installed]
    X.org framebuffer video driver
extra/xf86-video-intel 1:2.99.917+870+g6f4972d5-1 (xorg-drivers) [installed]
    X.org Intel i810/i830/i915/945G/G965+ video drivers
extra/xf86-video-nouveau 1.0.16-1 (xorg-drivers) [installed]
    Open Source 3D acceleration driver for nVidia cards
extra/xf86-video-openchrome 0.6.0-3 (xorg-drivers) [installed]
    X.Org Openchrome drivers
extra/xf86-video-sisusb 0.9.7-2
    X.org SiS USB video driver
extra/xf86-video-vesa 2.4.0-2 (xorg-drivers xorg) [installed]
    X.org vesa video driver
extra/xf86-video-vmware 13.3.0-1 (xorg-drivers) [installed]
    X.org vmware video driver
extra/xf86-video-voodoo 1.2.5-10 (xorg-drivers) [installed]
    X.org 3dfx Voodoo1/Voodoo2 2D video driver
community/xf86-video-qxl 0.1.5-7 (xorg-drivers) [installed]
    Xorg X11 qxl video driver
```
