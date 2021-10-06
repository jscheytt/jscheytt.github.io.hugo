### Taken and adapted from https://github.com/upbound/build/blob/master/makelib/common.mk

# Remove default suffixes as we dont use them
.SUFFIXES:

# Set the shell to bash always
SHELL := /bin/bash

define HELPTEXT
Usage: make [make-options] <target> [options]

Common Targets:
    build        Run hugo build process and start the local server.
    help         Show this help info.
    post         Create a new post. Expects parameter slug.
endef
export HELPTEXT

.PHONY: help
help:
	@echo "$$HELPTEXT"

.PHONY: build
build:
	hugo server

post:
	@if [ ! -z "$(slug)" ]; then hugo new post/$(slug)/index.md; fi
