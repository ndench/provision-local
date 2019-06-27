ANSIBLE = /usr/bin/ansible
AUR_HELPER = /usr/share/ansible/plugins/modules/aur.py

.PHONY: install
install: $(ANSIBLE) $(AUR_HELPER) .imported_roles
	ansible-playbook --ask-become-pass -i hosts playbook.yml -vv

.imported_roles: $(ANSIBLE) requirements.yml
	ansible-galaxy install -r requirements.yml

$(ANSIBLE):
	sudo pacman -S ansible --needed --noconfirm

.ONESHELL:
$(AUR_HELPER):
	cd "$(shell mktemp -d)"
	curl -sO https://aur.archlinux.org/cgit/aur.git/snapshot/ansible-aur-git.tar.gz
	tar -vxf ansible-aur-git.tar.gz
	cd ansible-aur-git
	makepkg -si --noconfirm
