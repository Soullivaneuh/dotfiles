# Source: https://github.com/b4b4r07/dotfiles/blob/master/Makefile

DOTPATH    := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
CANDIDATES := $(wildcard .??*)
EXCLUSIONS := .DS_Store .editorconfig .git .gitmodules .gitignore .idea
DOTFILES   := $(filter-out $(EXCLUSIONS), $(CANDIDATES))

.DEFAULT_GOAL := help

all:

list: ## Show dot files in this repo
	@$(foreach val, $(DOTFILES), /bin/ls -dF $(val);)

deploy: ## Create symlink to home directory
	@echo '==> Start to deploy dotfiles to home directory.'
	@echo ''
	@$(foreach val, $(DOTFILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	cat `grep '#include' .Xresources | cut -d' ' -f2 | tr -d '"'` > $(HOME)/.Xdefaults
	grep -v '#include' .Xresources >> $(HOME)/.Xdefaults

init: ## Setup environment settings
	@DOTPATH=$(DOTPATH) sh $(DOTPATH)/init.sh

update: ## Fetch changes for this repo
	git diff --exit-code
	git pull --rebase
	git submodule init
	git submodule update
	git submodule foreach git pull origin master

install: update deploy init ## Run make update, deploy, init
	@exec $$SHELL

clean: ## Remove the installed dot files
	@echo 'Remove dot files from your home directory...'
	@-$(foreach val, $(DOTFILES), rm -vrf $(HOME)/$(val);)

help: ## Self-documented Makefile
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| sort \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
