ANSIBLE = /usr/bin/ansible
ANSIBLE_ARGS =

ifdef tags
ANSIBLE_ARGS += --tags $(tags)
endif

ifdef skip-tags
ANSIBLE_ARGS += --skip-tags $(skip-tags)
endif

PLAYBOOK = ansible-playbook --ask-become-pass -i hosts playbook.yml $(ANSIBLE_ARGS)

.DEFAULT_GOAL := help

# Self-documenting: targets with a `## description` and `##@ Section` headings are listed by `make help`
# @see https://www.thapaliya.com/en/writings/well-documented-makefiles/
.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\n\033[1mUsage:\033[0m\n  make \033[36m<target>\033[0m [tags=a,b] [skip-tags=c]\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@printf "\n\033[1mTypical use:\033[0m\n  make \033[36mdry-run\033[0m, read the diff, then make \033[36mapply\033[0m\n\n"

##@ Provisioning

.PHONY: dry-run
dry-run: $(ANSIBLE) .imported_roles ## Show what would change, with diffs. Changes nothing
	$(PLAYBOOK) --check --diff

.PHONY: apply
apply: $(ANSIBLE) .imported_roles ## Provision this machine for real
	$(PLAYBOOK) -vv

##@ Setup

.PHONY: rcup
rcup: ## Link the dotfiles into ~ (rcm)
	rcup

.PHONY: git-remote
git-remote: ## Switch this repo's origin from https to ssh
	git remote set-url origin git@github.com:ndench/provision-local.git

.imported_roles: $(ANSIBLE) requirements.yml
	ansible-galaxy install -r requirements.yml --force
	touch .imported_roles

$(ANSIBLE):
	sudo pacman -S ansible --needed --noconfirm
