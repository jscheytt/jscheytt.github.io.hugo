---
title: The Git Commands You Wish You Always Had
date: 2022-02-28T13:15:29+01:00
tags:
    - git
    - shell
---

Recently I wanted to do a bulk cleanup on some GitHub repositories I am responsible for, deleting old branches that have already been merged into the default branches.
I first considered performing it through the GitHub API, but then I decided to try doing it via Git itself.

After I had begun dabbling with a few wrapper scripts, I suddenly remembered something which massively simplified my strategy:
**Git Aliases**.
These are Git commands you can define yourself, either via CLI or in the Gitconfig file.

With this article, I want to introduce what I learned about Git aliases – and in the process, you get all the aliases I defined for my cleanup 😉

## Defining Shortcuts

Many articles about Git aliases explain only the **shortcut side**.
They show e.g. how you can abbreviate `git checkout` to `git co` by running `git config --global alias.co checkout`.
Alternatively to the CLI command, you can add this section to your `~/.gitconfig` file:

```ini
[alias]
  co = checkout
```

Nowadays, with the [Git plugin of oh-my-zsh](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git), I don't feel there is a great need for such shortcuts.
Let's instead talk about **actual custom commands**:

## With Parameters

If you use an *exclamation mark* before your command, you can run any Shell command you want, even with parameters.
The following example will let you do e.g. `git cat 2eea778 package.json` to get the file contents of a file at a certain revision:

```ini
[alias]
  ; Output file contents from any revision
  ; See https://stackoverflow.com/a/54819889/6435726
  cat = !git show "$1:$2"
```

## Pass It On

Piping output into other commands is available out of the box.
Executing multiple commands is just a `&&` away.

You may want to break your command into *multiple lines*:
Do so by wrapping your command into **quotes** and prepending every new line with a **backslash**.

```ini
  ; What is the default branch of this repo?
  ; The first command asks the remote if the default branch was changed.
  default-branch = "! \
    git remote set-head origin -a > /dev/null \
    && git rev-parse --abbrev-ref origin/HEAD \
    | sed 's#origin/##'"
```

You can also use *subshells*:

```ini
  ; Switch to the default branch.
  switch-default = !git switch $(git default-branch)
```

## Escaping Can Be Tricky

If you want to have a *literal backslash* in the resulting Shell command, you have to escape it.
Pay attention to the `grep` patterns in the following aliases:
Every double backslash of this pattern becomes a single backslash when Git passes the command to the Shell.

```ini
  ; Which branches have been merged into the default branch on the remote?
  ; For safety, manually add names of long-lived branches to the grep pattern.
  remotely-merged-branches = "! \
    git branch --all --merged $(git default-branch) \
    | { grep -vE '^\\*|(\\b($(git default-branch)|develop|main|master|quality)\\b)' || true; } \
    | sed 's#remotes/origin/##'"

  ; Which local branches are not present on the remote (but were once)?
  ; NOTE: `git remote prune origin` only deletes local snapshots
  ; of remote branches that were deleted on the remote.
  ; See https://stackoverflow.com/a/48820687/6435726
  ; It will not delete local branches where the remote branch is "gone".
  ; This command finds these local branches.
  local-branches-without-remote = "! \
    git remote prune origin && \
    git branch --list --format '%(if:equals=[gone])%(upstream:track)%(then)%(refname)%(end)' \
    | awk NF \
    | sed 's#refs/heads/##'"
```

I think these are the dangers of every templating language:
You have to account for special characters - but if these special characters happen to be special in someone else's language, things can become unexpectedly complicated.
(Think about Makefiles and `$(variables)` vs. `$$variables` in rules.)

## Parameters Pt. 2: Default Values

As with any other Shell function, you can not only have positional parameters but you can also give them default values.
The following alias has a *delete flag* that defaults to the safe behavior, but you can overwrite it with `git delete-local-branches-without-remote -D`:

```ini
  ; Delete local branches that are not present on the remote
  ; (safely, including warnings).
  ; You can ignore the warnings by passing "-D" as a parameter.
  ; NOTE: `git remote prune origin` only deletes local snapshots
  ; of remote branches that were deleted on the remote.
  ; It will not delete local branches where the remote branch is "gone".
  delete-local-branches-without-remote = "! \
    git local-branches-without-remote \
    | xargs -I {} git branch ${1:-'-d'} {}"
```

This last alias is what finally deletes the remote branches I wanted to target.
It also demonstrates nicely how you can use *xargs* to run every Shell command as if it was capable of handling `stdin` natively:

```ini
  ; Delete branches on the remote which were merged.
  push-delete-remotely-merged-branches = "! \
    git switch-default && \
    git remotely-merged-branches \
      | xargs -I {} git push origin --delete {}"
```

## Debugging

If you encounter an error message, you can increase the verbosity with this environment variable:

```sh
export GIT_TRACE=1
```

Deactivate it afterward by closing your terminal session or explicitly with `unset GIT_TRACE`.

## Bringing It All Together: Multiple Repositories

As a developer, chances are high you have *more than just one* Git repository on your machine.
For many everyday use cases (like keeping all your local clones up-to-date), I have been using [git-repo-updater](https://github.com/earwig/git-repo-updater) with a lot of success and ease.

But now I discovered I can use it to execute arbitrary commands (and also Git aliases 😉) in multiple Git repos.
With the following Shell function I am wrapping `gitup` for convenience:

```sh
# Execute a Git command on all Git repositories
# $1: Path with Git repositories in subdirectories
# Rest of parameters: Git command (e.g. "status")
function git-xargs() {
  local filepath="$1"
  # shellcheck disable=SC2116
  gitup --depth -1 "$filepath" --exec "git $(echo "${@:2}")"
}
```

And now I can finally clean up all branches with just one command (and quite pretty output):

```sh
git-xargs ~/Documents push-delete-remotely-merged-branches
git-xargs ~/Documents delete-local-branches-without-remote
```
