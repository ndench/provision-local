.PHONY: galaxy-install
galaxy-install:
	ansible-galaxy install -r requirements.yml

.PHONY: install
install: galaxy-install
	ansible-playbook --ask-become-pass -i hosts playbook.yml -vv
