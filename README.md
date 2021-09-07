# fzf-collection

[![GitHub license](https://img.shields.io/github/license/liuyinz/fzf-collection)](https://github.com/liuyinz/fzf-collection/blob/master/LICENSE)

A collection of functions to enhance cmdline with [FZF](https://github.com/junegunn/fzf)

<!-- markdown-toc start -->

**目录**

- [fzf-collection](#fzf-collection)
- [Install](#install)
  - [Manual](#manual)
  - [Oh-My-Zsh](#oh-my-zsh)
- [Commands](#commands)
  - [fzf-default](#fzf-default)
  - [fzf-browser](#fzf-browser)
  - [fzf-brew](#fzf-brew)
  - [fzf-pip](#fzf-pip)
  - [fzf-git](#fzf-git)
  - [fzf-gh](#fzf-gh)
- [Envrionment](#envrionment)
  - [FZF_COLLECTION_OPTS](#fzf_collection_opts)
  - [FZF_COLLECTION_MODULES](#fzf_collection_modules)
  - [FZF_COLLECTION_BROWSER](#fzf_collection_browser)

<!-- markdown-toc end -->

# Install

## Manual

First, clone this repository.

```sh
git clone https://github.com/liuyinz/fzf-collection.git
```

Then add the following line to your `~/.zshrc` .

```sh
source /path/to/fzf-collection.plugin.zsh
```

## Oh-My-Zsh

Clone this repository to custom plugin directory

```sh
git clone https://github.com/liuyinz/fzf-collection.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-collection
```

To start using it, add the fzf-collection plugin to your plugins array in `~/.zshrc`:

```diff
- plugins=(...)
+ plugins=(... fzf-collection)
```

# Commands

## fzf-default

- `fp` : find `$PATH`
- `ffp` : find `$FPATH`
- `kp` : kill process

## fzf-browser

```sh
# dependency
brew install sqlite3 coreutils diffutils gnu-sed gawk jq python-yq
```

- `bhf` : history search for `Google Chrome` `Microsoft Edge` `Mozilla Firefox` `MacOs Safari`
- `bbf` : bookmark search for `Google Chrome` `Microsoft Edge` `Mozilla Firefox`

## fzf-brew

- `bsf` : brew search
- `bmf` : brew manage
- `bgf` : brew upgrade
- `btf` : brew tap

## fzf-pip

```sh
# dependency
brew install grep gnu-sed gawk coreutils
```

- `ppi` : pip3 install [package]
- `ppc` : pip3 uninstall [package]
- `ppg` : pip3 upgrade [package]

## fzf-git

```sh
# dependency
brew install git-extras coreutils gnu-sed gh
```

- `gsha` : return commits
- `gck` : git checkout [commits]
- `gwf` : git checkout [branch or tag]
- `gef` : git restore
- `ges` : git restore --staged
- `gea` : git resore --staged --worktree
- `gsmi` : git submodule INTERACTIVE
- `gsti` : git stash INTERACTIVE
- `gif` : git ignore-io --append

## fzf-gh

```sh
brew install gh jq
```

- `ghf` : manage user/repos

# Envrionment

## FZF_COLLECTION_OPTS

Usually, `FZF_DEFAULT_OPTS` is applied if be settled.
Another env `FZF_COLLECTION_OPTS` is provided for users to customize.

```sh
# set options if needed, default value is as below :
FZF_COLLECTION_OPTS=" \
    --reverse \
    --cycle \
    --multi \
    --sort \
    --exact \
    --info=inline"
```

## FZF_COLLECTION_MODULES

Settng `FZF_COLLECTION_MODULES` to load modules.
By default, all modules are loaded.

```sh
FZF_COLLECTION_MODULES=(
  fzf-default
  fzf-browser
  fzf-brew
  fzf-git
  fzf-pip)
```

## FZF_COLLECTION_BROWSER

Settng `FZF_COLLECTION_BROWSER` to open url, use default browser if not set.

```sh
# choose from "chorme" "edgemac" "firefox" "safari"
FZF_COLLECTION_BROWSER="chrome"
```



