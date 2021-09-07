---
title: The Story of My First Makefile — Half-Versioned Secrets Management
date: 2021-09-06T13:38:15+02:00
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

But once you start managing an increasing number of tasks with your scripts, you start to face another problem:
How do you *manage your scripts*?

Personally, I have always loved being able to enter some new place where **conventions** were already in place.
It takes away so much work and mental effort at the beginning, and you can just get to work quickly.
(That might explain why I fell in love with ❤️ [Ruby on Rails](https://rubyonrails.org/doctrine/#convention-over-configuration) before I dug into 💎 Ruby.)

Shell scripts by their very nature do not pose any restrictions regarding e.g. naming patterns or directory structures.
Honestly, I think there never will be, and that is ok.
But what I have come to appreciate a lot recently is **[Make](https://www.gnu.org/software/make/)** as a **companion** for my Shell scripts.

## 🏗 Make vs. 🐚 Shell in a 🥜 Nutshell

* Purpose: Make is good at **creating files**, Shell is good at **executing scripts**.
* Portability: If your system has Bash, chances are pretty high that Make is also available.
* Developer API: Make has a **clear entrypoint** (namely `make`), Shell can be everything you want it to be.

Make is a tool that has its origin in the world of compiled languages, especially C.
Compiling source code into binary artifacts (and doing so 🏎 *economically*) is what Make was originally designed for.
I mean, the name of a tool should make its use clear, but let me just state this again for my future self:
Make is meant to 🏗 make (create) files.

**It's all about target files.**
That's why it makes sense to approach a Makefile with a mindset of "What do I want to create/build?" instead of "What do I want to perform?"
To me this sounds very reminiscent of the distinction between *declarative and imperative* programming.

## Safely Versioned Secrets Management

My concrete entrypoint into Make was the following use case I had lately, and it hopefully helps to illustrate the point of target files:

* ☸️ You have 2 AWS accounts with 1 **Kubernetes** cluster each.
(One is for running a dev and a staging environment, the other one is running the production environment.)
* 🔑 Secrets are stored in AWS **Secrets Manager** and synced into the cluster via [ExternalSecrets](https://github.com/external-secrets/kubernetes-external-secrets).
* ⛔️ You are **not allowed** to store secrets in Git, not even in encrypted form.
* 🪣 The secrets are JSON files and the **key names** are important, so you want to store them in Git.

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

I put the keys I needed into the sample files and as a value a description of what to put in (or e.g. from which Password Service to fetch the value from).
The file `service2.sample.json` would e.g. look like this.

```json
{
  "EXTERNAL_API_KEY": "API Key of EXTERNAL_SERVICE",
  "CLOUD_SERVICE_CLIENT_SECRET": "client secret for accessing CLOUD_SERVICE",
  "CLOUD_SERVICE_PASSWORD": "password for accessing CLOUD_SERVICE",
  "BASIC_AUTH_PASSWORD": "password for sending via Basic Auth"
}
```

The target structure I wanted to achieve was this:

```
secrets
├── dev
│   ├── config1.json        # This file contains the *keys* of
│   │                       # secrets/config1.sample.json
│   │                       # and the actual secret *values*!
│   ├── service2.json
│   ├── service3.json
│   └── .keep
├── staging
│   ├── config1.json        # Contains key of sample file and
│   │                       # values for staging environment.
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

### Copying the Samples

Now how do you copy the files to all environment's directories?
And how do you make sure you copy them *exactly once* (so you don't lose the secrets you already entered)?

You could create a script with the following logic:

```sh
# For each environment directory:
## For each sample file:
### Extract the service name
### Check if target secret file already exists
### If not, copy sample to target file
```

But now, 🏗 Make to the rescue:

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
I think the result is already impressive, especially if you consider the following:

* ☝️ You don't even have to call the job explicitly to run it.
As long as `secrets.copy-templates` is the first build defined in the Makefile, you can even execute just `make` *without any parameters*.
* 👨‍💻 Onboarding a new colleague to your repository now sounds a lot more like:
"Yes, do read the README, but above all execute `make`."
    * ⛑ This is especially true if your Makefile contains **[good help texts](https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html)** for every rule.

#### How Not To Shoot Yourself in the Foot

Make was made primarily for building binaries from source code.
The fact that we are able to use it in the way described above comes with a warning:
If you do the following, you will lose the secret data you already entered into the secret files:

1. Execute `make secrets.copy-templates`.
1. Edit a **sample file**.
1. Execute `make secrets.copy-templates`.
1. 💥 Make will **copy and overwrite** the edited sample file to all environment secret files.

Why?
Make compares timestamps, and when the source has a newer last-modified timestamp than the destination it will execute the rule

Can we circumvent this?
We sure can.
You can either make sure that you edit each environment file after editing the sample file.
Or you change the last-modified timestamp **via a build** in the Makefile 😉:

```make
secrets.ensure-copy-once:
	for f in $(all_secrets); do [ -f $$f ] && touch $$f; done
```

Now whenever you edit a sample file *after the initial secrets.copy-templates* you run this build via `make secrets.ensure-copy-once` and 🛡 your secrets will not be deleted.

### Extension: Environment-specific Sample Files

One implicit assumption in my structure was that the secrets in service2 will always have the same schema **in every environment**.
One day it so happened that service2 needed to have additional keys on prod, but they **should not be present** on dev or staging.

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
	if [ -f "$(ENVIRONMENT_SAMPLE_FILE)" ]; then cp $(ENVIRONMENT_SAMPLE_FILE) $(2); fi
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

### 🍣 Perfect Symphony: Calling Scripts From Make

It's all good and nice to have your secrets created, but how do you deploy them to AWS Secrets Manager?
Of course you write a thin wrapper around the wonderfully verbose AWS CLI:

```sh
#!/usr/bin/env bash
set -euo pipefail
# set -x # DEBUG

secret_name="$1"
# Use second argument or read stdin
secret_value="${2:-$(cat -)}"

echo "$secret_value" # DEBUG

# Create secret in idempotent way, avoid script from failing
set +e
aws secretsmanager create-secret --name "$secret_name" &> /dev/null
set -e

# Put secret value and output response to stdout
aws secretsmanager put-secret-value --secret-id "$secret_name" \
  --secret-string "$secret_value" | cat
```

In your terminal you would call it e.g. like this:  
`./helpers/deploy-secret.sh envs/dev/config1-secrets < secrets/dev/config1.json`

Let's make a generic rule in Make to execute this script:

```make
# The dependency on $(all_secrets) is to make sure that the secrets files exist
# before deploying them.
secret.deploy: $(all_secrets)
	./helpers/deploy-secret.sh $(name) < secrets/$(environment)/$(filename)
```

The call to the script that you executed above would become this:  
`make secret.deploy name=envs/dev/config1-secrets environment=dev filename=config1`

As we have multiple services, let's add one rule per service:

```make
# The secret values in this one are the same across all environments
secret.deploy.config1:
	$(MAKE) secret.deploy name=envs/config1-secrets filename=config1.json
# service2 has different secret values on the different environments
secret.deploy.service2:
	$(MAKE) secret.deploy name=envs/$(environment)/service2-secrets filename=service2.json
# service 3 also has environment-specific secret values
secret.deploy.service3:
	$(MAKE) secret.deploy name=envs/$(environment)/service3-secrets filename=service3.json
```

Now we can tie these together into one rule for a whole environment:

```make
# Deploy all secrets for one environment
secrets.deploy.all:
	$(MAKE) secret.deploy.config1
	$(MAKE) secret.deploy.service2
	$(MAKE) secret.deploy.service3
# Deploy all secrets for the dev cluster
secrets.deploy.dev:
	$(MAKE) secrets.deploy.all environment=dev
	$(MAKE) secrets.deploy.all environment=staging
# Deploy all secrets for the prod cluster
secrets.deploy.prod:
	$(MAKE) secrets.deploy.all environment=prod
```

✅ Once you are authenticated to the corresponding AWS account, you can deploy your secrets with either `make secrets.deploy.dev` or `make secrets.deploy.prod`.

## Summarizing

* Make gives you a consistent and clean Developer API.
* Make is almost universally installed everywhere.
* Don't decide between either Make **or** Shell - use both together.
Refactor more complex logic into separate Shell scripts (like isolated functions) which are called from within Make.

You can check out the entire Makefile (including the secrets structure and scripts) in this [Git repo](https://github.com/jscheytt/jscheytt.github.io.hugo/tree/main/content/post/story-first-makefile).

## Credits

I am indebted to the following parties in making my start into the world of Make a lot smoother than I expected:

* Isaac Z. Schlueter for his [interactive Gist](https://gist.github.com/isaacs/62a2d1825d04437c6f08)
* The guys at [Upbound](https://www.upbound.io/) for creating [Crossplane](https://crossplane.io/) where they use Make in [their providers](https://github.com/crossplane/provider-aws) and even distribute [common functionality](https://github.com/upbound/build) as a Git submodule
