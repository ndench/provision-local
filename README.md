# provision-local
Scripts to provision my PCs in the "one true way".

```sh
bash <( curl -s https://raw.githubusercontent.com/ndench/provision-local/master/bootstrap.sh )
```

## TODO:
- add -j2 to MAKEFLAGS in /etc/makeflags.conf


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
