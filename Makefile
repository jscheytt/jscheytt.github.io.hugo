# Remove default suffixes as we dont use them
.SUFFIXES:

# Set the shell to bash always
SHELL := /bin/bash

.PHONY: all
all: build

.PHONY: build
build:
	hugo server
