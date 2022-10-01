ANSIBLE = /usr/bin/ansible
AUR_HELPER = /usr/share/ansible/plugins/modules/aur.py
ANSIBLE_ARGS =

ifdef tags
ANSIBLE_ARGS += --tags $(tags)
endif

ifdef skip-tags
ANSIBLE_ARGS += --skip-tags $(skip-tags)
endif

.PHONY: install
install: $(ANSIBLE) $(AUR_HELPER) .imported_roles
	ansible-playbook --ask-become-pass -i hosts playbook.yml -vv $(ANSIBLE_ARGS)

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

.PHONY: git-remote
git-remote:
	git remote set-url origin git@github.com:ndench/provision-local.git
