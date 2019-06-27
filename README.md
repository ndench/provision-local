# provision-local
Scripts to provision my PCs in the "one true way".

```sh
bash <( curl -s https://raw.githubusercontent.com/ndench/provision-local/master/bootstrap.sh )
```

## TODO:
- add -j2 to MAKEFLAGS in /etc/makeflags.conf
- pass ansible tags flags through make
- check config https://github.com/teleshoes/tpacpi-bat
- install docd https://wiki.archlinux.org/index.php/ThinkPad_docks
- check other thinkpad things https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_T470
- check other laptop things https://wiki.archlinux.org/index.php/Laptop
- check power management https://wiki.archlinux.org/index.php/Power_management


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
