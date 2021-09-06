---
title: The Beauty of Makefiles
date: 2021-09-06T13:38:15+02:00
draft: true
tags:
    - automating
    - cloudops
    - make
    - shell
---

As a CloudOps Engineer one key skill is **automating repetitive tasks**.
What most people grab for intuitively is writing Shell scripts (be it Bash, zsh, fish or whichever flavor you prefer).
And there are a lot many good reasons to do so:

1. It is closest to typing commands directly in the terminal.
1. You don't have to learn a dedicated programming language.
1. It is very portable to other platforms like e.g. a CI server.

But once you start managing a rising number of tasks with your scripts, you start to face another problem:
How do you **manage your scripts**?

Personally, I have always loved being able to enter some new place where **conventions** were already in place.
It takes away so much work and mental effort at the beginning, and you can just get to work quickly.
(That might explain why I fell in love with ❤️ [Ruby on Rails](https://rubyonrails.org/doctrine/#convention-over-configuration) before I dug into 💎 Ruby.)

Shell scripts by their very nature do not pose any restrictions regarding e.g. naming patterns or directory structures.
Honestly, I think there never will be, and that is ok.
But what I have come to appreciate a lot recently is **[Make](https://www.gnu.org/software/make/)** as a **companion** for my Shell scripts.

# Make vs. Shell

* Purpose: Make is good at **creating files**, Shell is good at **executing scripts**.
* Portability: If your system has Bash, chances are pretty high that Make is also available.
* Developer API: Make has a **clear entrypoint** (namely `make`), Shell can be everything you want it to be.

Make is a tool that has its origin in the world of compiled languages, especially C.
Compiling source code into binary artifacts (and doing so 🏎 *economically*) is what Make was originally designed for.
**It's all about target files.**

My concrete entrypoint into Make was the following use case I had lately, and it hopefully helps to illustrate the point of target files:

# Example: Half-Versioned Secrets Management

Imagine the following situation:

* ☸️ You have a **Kubernetes** cluster.
* 🔑 Secrets are stored in AWS **Secrets Manager** and synced into the cluster via [ExternalSecrets](https://github.com/external-secrets/kubernetes-external-secrets).
* 🪣 A corporate guideline **prohibits** the storing of secrets (even encrypted) in Git repositories and allows storing only in a password safe service.
* 💾 The secrets are JSON files and the **key names** are important, so you want to store them in Git.

What I did as a first step was to create sample secrets files that contained the keys but no valid data (kind of the *schema* of the secrets):

```
secrets
├── dev                     # One directory per target environment
│   └── .keep
├── staging
│   └── .keep
├── prod
│   └── .keep
├── config1.sample.json     # One sample file per secret
├── service2.sample.json
└── service3.sample.json
```

`service2.sample.json` would e.g. look like this (*verbatim*):

```json
{
  "EXTERNAL_API_KEY": "API Key of EXTERNAL_SERVICE",
  "CLOUD_SERVICE_CLIENT_SECRET": "client secret for accessing CLOUD_SERVICE",
  "CLOUD_SERVICE_PASSWORD": "password for accessing CLOUD_SERVICE",
  "BASIC_AUTH_PASSWORD": "password for sending via Basic AUth"
}
```

The target structure I wanted to get was this:

```
secrets
├── dev
│   ├── config1.json        # This file contains the *keys* of secrets/config1.sample.json
│                           # and the actual secret *values*!
│   ├── service2.json
│   ├── service3.json
│   └── .keep
├── staging
│   ├── config1.json
│   ├── service2.json
│   ├── service3.json
│   └── .keep
├── prod
│   ├── config1.json
│   ├── service2.json
│   ├── service3.json
│   └── .keep
├── config1.sample.json
├── service2.sample.json
└── service3.sample.json
```

In order to not commit any actual secrets into version control, I added the following entries to my **.gitignore**:

```sh
# Ignore secret data ...
secrets/**/*.json
# ... but keep the samples
!secrets/*.sample.json
```

Now how do you copy the files to all environment's directories?
And how do you make sure you copy them exactly once (so you don't lose the secrets you already entered)?

You could create a script with the following logic:

```sh
# For each environment directory:
## For each sample file:
### Extract the service name
### Check if target secret file already exists
### If not, copy sample to target file
```

But now, Make to the rescue:

```make
### Variables

# Fetch all sample files.
secrets_samples := $(wildcard secrets/*.sample.json)
# Construct the paths for all dev secrets destinations.
dev_secrets := $(patsubst secrets/%.sample.json,secrets/dev/%.json,$(secrets_samples))
# Construct the paths for all staging secrets destinations.
staging_secrets := $(patsubst secrets/dev/%,secrets/staging/%,$(dev_secrets))
# Construct the paths for all staging secrets destinations.
prod_secrets := $(patsubst secrets/dev/%,secrets/prod/%,$(dev_secrets))
# Gather the paths of all secrets' destinations.
all_secrets := $(dev_secrets) $(staging_secrets) $(prod_secrets)

### Rules

# 🎯 Purpose: "Copy all samples to their destinations."
# 🤓 What Make sees: "When you build the file secrets.copy-templates,
#    make sure that all files in $(all_secrets) have been built first."
# 👩‍🏫 Explanation: A rule can be empty, and a rule can have prerequisites
#    on the first line. I like to think of such a rule as a kind of shortcut.
secrets.copy-templates: $(all_secrets)

# 🎯 Purpose: "Ensure that Make still runs the job 'secrets.copy-templates'
#    even if a file called 'secrets.copy-templates' is created."
# 🤓 What Make sees: "I am supposed to always build secrets.copy-templates
#    even if that file already exists."
.PHONY: secrets.copy-templates

# 🎯 Purpose: "Copy the file on the right to the file on the left."
# 🤓 What Make sees: "When a file matching the pattern secrets/dev/(.*).json
#    is built, execute this rule.
#    Also first make sure that the corresponding file secrets/$1.sample.json
#    has been built before.
#    And the rule is: Copy the source file on the right ($<) to the destination
#    file on the left ($@)."
# 👩‍🏫 Explanation: These 3 rules are applied when you call secrets.copy-templates
#    because it requires $(all_secrets) to be built.
secrets/dev/%.json: secrets/%.sample.json
	cp $< $@
secrets/staging/%.json: secrets/%.sample.json
	cp $< $@
secrets/prod/%.json: secrets/%.sample.json
	cp $< $@
```

If you now execute `make secrets.copy-templates`, the sample files will be copied to all environment directories.
And if you run that same command again, 🙊 **Make will not copy anything** because it intelligenty detected that the source files have not changed since the last execution.

The code above is certainly not optimal - I bet you could abstract away the environment names with bit of metaprogramming, but let's not optimize prematurely.

But the result is already impressive - especially if you consider the following:

* ☝️ You don't even have to call the job explicitly to run it.
As long as `secrets.copy-templates` is the first build defined in the Makefile, you can even execute just `make` *without any parameters*.
* 👨‍💻 Onboarding a new colleague to your repository now sounds a lot more like:
"Yes, do read the README, but above all execute `make`."
    * ⛑ This is especially true if your Makefile contains **[good help texts](https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html)** for every job.

## How Not To Shoot Yourself in the Foot

Make was made primarily for building binaries from source code.
The fact that we are able to use it in the way described above comes with a warning:
If you do the following, you will lose (local) secret data:

1. Execute `make secrets.copy-templates`.
1. Edit a sample file.
1. Execute `make secrets.copy-templates`.
1. 💥 Make will **copy and overwrite** the edited sample file to all environment directories.

Why?
Make compares timestamps.

Can we circumvent this?
We sure can.

You can either make sure that you edit each environment file after editing the sample file.
Or you change the last-modified timestamp **via a build** in the Makefile 😉:

```make
secrets.ensure-copy-once:
	for f in $(all_secrets); do [ -f $$f ] && touch $$f; done
```

Now whenever you edit a sample file *after the initial secrets.copy-templates* you run this build via `make secrets.ensure-copy-once` and 🛡 your secrets will not be deleted.

## Extension: Environment-specific Sample Files

One implicit assumption in my structure was that the secrets in service2 will always have the same schema **in every environment**.
One day it so happened that service2 needed to have different keys present on prod, but they **should not be present** on dev or staging.

I adjusted my desired structure like this:

```
secrets
├── dev
│   ├── config1.json
│   ├── service2.json           # Contains keys from service2.sample.json
│   ├── service3.json
│   └── .keep
├── staging
│   ├── config1.json
│   ├── service2.json           # Contains keys from service2.sample.json
│   ├── service3.json
│   └── .keep
├── prod
│   ├── config1.json
│   ├── service2.json           # Contains keys from service2.sample.prod.json
│   ├── service3.json
│   └── .keep
├── config1.sample.json
├── service2.sample.json        # Default sample file
├── service2.sample.prod.json   # Prod-specific sample file
└── service3.sample.json
```

And I wrote my first **Makefile function**:

```make
# A Make function can take in an arbitrary number of numbered parameters.
define copy_template
	cp $(1) $(2)
	@# Check if there is a more environment-specific sample file
	$(eval ENVIRONMENT := $(shell echo $(2) | sed -E 's#secrets/(.*)/.*#\1#'))
	$(eval ENVIRONMENT_SAMPLE_FILE := $(patsubst %.sample.json,%.sample.$(ENVIRONMENT).json,$(1)))
    @# If environment-specific file exists, copy it to destination
	[ -f $(ENVIRONMENT_SAMPLE_FILE) ] && cp $(ENVIRONMENT_SAMPLE_FILE) $(2)
endef

# Calling a Make function works by executing 'call'
#     with the function name and all its parameters as a list.
# My previous rules now became this:
secrets/dev/%.json: secrets/%.sample.json
	$(call copy_template,$<,$@)
secrets/staging/%.json: secrets/%.sample.json
	$(call copy_template,$<,$@)
secrets/prod/%.json: secrets/%.sample.json
	$(call copy_template,$<,$@)
```

The entire result is in this [Git repo](link to this directory).

# TODO

* Title: History of a Makefile / History of my first Makefile
* Deploy the secrets
* Get the IP addresses

# Parting Words

* Make gives you a consistent and clean Developer API.
* Make is basically installed everywhere.
* Don't decide between either Make **or** Shell - use both:
* Don't shove all functionality into a giant Make rule.
Instead refactor more complex logic into separate Shell scripts (like isolated functions) which are called from within Make.

# Helpful Resources

* A [Makefile gist](https://gist.github.com/isaacs/62a2d1825d04437c6f08) that you can use interactively.
* Upbound is using Make in their [Crossplane providers](https://github.com/crossplane/provider-aws), and they are distributing common functionality using a [submodule](https://github.com/upbound/build).
