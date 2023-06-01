### Taken and adapted from https://github.com/upbound/build/blob/master/makelib/common.mk

# Remove default suffixes as we dont use them
.SUFFIXES:

# Set the shell to bash always
SHELL := /bin/bash

.PHONY: all
all: install help

# Auto-generate help texts from end-of-line comments.
# See https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
USAGE_TEXT := Usage: make [make-options] <target> [options]
HELPTEXT_HEADING := Common Targets:
help: ## Show this help info.
	@printf "$(USAGE_TEXT)\n"
	@for makefile in $(MAKEFILE_LIST); do \
		echo; \
		grep '^HELPTEXT_HEADING := ' "$$makefile" | sed -E 's#.* := (.*)#\1#'; \
		grep -E '^[a-zA-Z_\.-]+:.*?## .*$$' "$$makefile" | sort | \
			awk 'BEGIN {FS = ":.*?## "}; {printf "  %-27s %s\n", $$1, $$2}'; \
	done

.PHONY: install
install: submodules ## Install dependencies. (Default target)
	@command -v hugo > /dev/null || brew install hugo

.PHONY: build
localhost_url = http://localhost:1313/
build: install ## Run hugo build process and start the local server.
	@echo "Opening $(localhost_url) in your browser ..."
	@python3 -m webbrowser $(localhost_url) > /dev/null
	@hugo server --buildDrafts

.PHONY: post
post: ## Create a new post. Expects parameter slug.
	@if [ ! -z "$(slug)" ]; then hugo new post/$(slug)/index.md; fi

.PHONY: submodules
.git/modules/%:
	@git submodule sync
	@git submodule update --init --recursive
submodules: .git/modules/ ## Initialize the Git submodules.
.PHONY: submodules.update
submodules.update: ## Pull the latest changes in the Git submodules & commit.
	@git submodule update --remote
	@git add themes
	@git commit -m "chore(make): update submodule"

.PHONY: clean
clean: ## Remove all generated resources.
	rm -rf resources/ || true
