---
title: You can Gitopsify your Ansible
date: 2022-03-01T08:34:20+01:00
categories:
    - today-i-learned
tags:
    - ansible
    - gitops
    - devops
---

I have a [dotfiles repository](https://github.com/jscheytt/dotfiles) for setting up my MacOS machine easily and reproducibly.
For this I am mostly using Ansible, just slightly wrapping it with Make and seasoning it with a pinch of Shell.

The core piece of this repository is a `Brewfile` and a collection of [Shell aliases](https://github.com/jscheytt/dotfiles/blob/main/files/dotfiles/.oh-my-zsh/custom/aliases.zsh) and [functions](https://github.com/jscheytt/dotfiles/blob/main/files/dotfiles/.oh-my-zsh/custom/functions.sh).
I don't regularly run the Ansible playbook itself because I created it for initially setting up a machine.
The only thing I run very frequently is the [upgrade](https://github.com/jscheytt/dotfiles/blob/main/files/dotfiles/.oh-my-zsh/custom/functions.sh#L107) command which includes persisting new Brew formulae to the `Brewfile`.

At the same time I have come to love applying [GitOps principles](https://opengitops.dev/) to everything I work with.
Just the other day I was [moving some commands](https://github.com/jscheytt/dotfiles/commit/c4278a0b8bbe1f4875efd56ceffc43459d919d1f) (in the vein of "global Git pull") out of said `upgrade` command into a cronjob.

And then it hit me:
If I create a cronjob for running my Ansible playbook *through the playbook itself*, I have GitOps-like reconciliation!

Let's do it in just a few lines of yaml:

```yaml
- name: Ensure dotfiles are applied
  cron:
    name: Ensure dotfiles are applied
    minute: "0"
    hour: "9"
    weekday: "1-5" # on workdays
    job: make -f "{{ ansible_env.PWD }}"/Makefile build
```
