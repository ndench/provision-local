ANSIBLE = /usr/bin/ansible
ANSIBLE_ARGS =

ifdef tags
ANSIBLE_ARGS += --tags $(tags)
endif

ifdef skip-tags
ANSIBLE_ARGS += --skip-tags $(skip-tags)
endif

PLAYBOOK = ansible-playbook --ask-become-pass -i hosts playbook.yml $(ANSIBLE_ARGS)

# Default: show what would change without changing anything
.PHONY: check
check: $(ANSIBLE) .imported_roles
	$(PLAYBOOK) --check --diff

.PHONY: apply
apply: $(ANSIBLE) .imported_roles
	$(PLAYBOOK) -vv

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
