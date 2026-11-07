ANSIBLE = /usr/bin/ansible
ANSIBLE_ARGS =

ifdef tags
ANSIBLE_ARGS += --tags $(tags)
endif

ifdef skip-tags
ANSIBLE_ARGS += --skip-tags $(skip-tags)
endif

.PHONY: install
install: $(ANSIBLE) .imported_roles
	ansible-playbook --ask-become-pass -i hosts playbook.yml -vv $(ANSIBLE_ARGS)

.imported_roles: $(ANSIBLE) requirements.yml
	ansible-galaxy install -r requirements.yml --force
	touch .imported_roles

$(ANSIBLE):
	sudo pacman -S ansible --needed --noconfirm

.PHONY: git-remote
git-remote:
	git remote set-url origin git@github.com:ndench/provision-local.git

.PHONY: rcup
rcup:
	rcup
