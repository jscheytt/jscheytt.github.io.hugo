---
title: My default Makefile Boilerplate code
date: 2022-06-01T15:04:45+02:00
tags:
    - makefile
    - shell
---

Most of my Makefiles nowadays start with the following stuff at the top of `Makefile`:

```make
# Remove default suffixes as we don't use them
.SUFFIXES:

# Set the Shell to Bash always to avoid surprises
SHELL := /bin/bash

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

# Split out Make modules into `helpers/`
-include helpers/*.mk helpers/**/*.mk
```

Then I extend this either with targets directly in the `Makefile` or, mostly later on, with separate `.mk` files in the `helpers/` directory.

If I want to mark a target "public" or document its usage, I will just append ` ## Usage.` to the end of the target's line.
One example:

```make
bootstrap: cluster.local ## Bootstrap base resources. Required parameters: cluster_name.
```
