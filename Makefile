VC=v

define help_banner
Nvenv - Neovim Version Manager
==============================

Usage:
    make [target]

Targets:

endef
export help_banner

all: fmt linux macos

help: ## Shows this message
	@printf "$$help_banner"
	@egrep '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "    \033[36m%-20s\033[0m %s\n", $$1, $$2}'


linux: fmt ## Build Nvenv for production (Linux)
	$(VC) -prod -os linux -m64 -o ./bin/nvenv_linux nvenv.v


macos: fmt ## Build Nvenv for production (MacOS)
	$(VC) -prod -os macos -m64 -o ./bin/nvenv_osx nvenv.v


dev: ## Build Nvenv for development (without optimization)
	$(VC) nvenv.v


fmt: ## Format all V files
	find . -type f -name '*.v' | xargs -n1 $(VC) fmt -w


.SILENT: linux macos dev fmt

.PHONY: dev fmt

.DEFAULT_GOAL := all
