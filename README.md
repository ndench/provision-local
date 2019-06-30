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
- check the following files:
    - /etc/default/keyboard
    - /etc/vconsole.conf
    - /etc/locale.conf
    - /etc/default/locale
    - /etc/pacman.conf
    - ~/.zprofile
    - /etc/lightdm/lightdm.conf
    - /etc/lightdm/lightdm-gtk-greeter.conf
    - files in /etc/X11/xorg.conf.d
    - /etc/resolv.conf
    - /etc/NetworkManager/system-connections
    - files in /etc/pacman.d/hooks
    - /boot/syslinux/syslinux.cfg
    - files in /boot


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
