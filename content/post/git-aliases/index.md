---
title: The Git Commands You Wish You Always Had
date: 2022-02-28T13:15:29+01:00
draft: true
---

I am a big fan of Git.
Yes, it is complex, and yes, it is hard to learn when you start using it the first time.
But the benefits you reap far exceed the pain of learning!
Git does many things very well and reliably, and when you learn it you get a tremendously powerful tool at your disposal.
(That's probably also why I use (Neo)Vim - same learning difficulty and same massive gains!)

One very helpful thing I recently learned is that you can define **aliases** in Git.

Many articles about Git aliases explain only the **shortcut side**, e.g. how you can abbreviate `git checkout` to `git co` by running `git config --global alias.co checkout`.
Alternatively to the command, you can add this section to your `~/.gitconfig` file:

```ini
[alias]
  co = checkout
```

Nowadays, with the [Git plugin of oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git) I don't feel there is a lot of need for such shortcuts.
Let's instead talk about **custom commands**:

## With Parameters

If you use an *exclamation mark* before your command, you can run (almost) any Shell command you want, even with parameters.
The following example will let you do e.g. `git cat 2eea778 package.json` to get the file contents of a file at a certain revision:

```ini
[alias]
  ; Output file contents from any revision
  ; See https://stackoverflow.com/a/54819889/6435726
  cat = !git show "$1:$2"
```

## You Can Pipe

Piping output into other commands is available out of the box.

You may want to break your command into *multiple lines*:
Wrap your command into quotes and prepend every newline with a backslash:

```ini
  ; What is the default branch of this repo?
  default-branch = "!git remote set-head origin -a > /dev/null \
    && git rev-parse --abbrev-ref origin/HEAD | sed 's#origin/##'"
```

You can also use *subshells*:

```ini
  ; Switch to the default branch.
  switch-default = !git switch $(git default-branch)
```

## Escaping is tricky

If you want to have a *literal backslash* in the resulting Shell command, you have to escape it.
Pay attention to the second `grep` call of the following alias:

```ini
  ; Which local branches are not present on the remote?
  local-branches-without-remote = "!git branch -vv \
    | grep ': gone]' \
    | grep -v '\\*' \
    | awk '{print $1;}'"
```

These are the dangers of every templating language:
You have to account for special characters.
And if these special characters happen to be special in someone else's language, things can become unexpectedly complicated sometimes.
(Think about Makefiles and `$(variables)` vs. `$$variables` in rules.)

## Debugging

If you encounter an error message, you can increase the verbosity with this environment variable:

```sh
export GIT_TRACE=1
```

Deactivate it afterwards by closing your terminal session or with `unset GIT_TRACE`.

## Taking It Further: Multiple Repositories

TODO: git-xargs
