# fzf-collection

[![GitHub license](https://img.shields.io/github/license/liuyinz/fzf-collection)](https://github.com/liuyinz/fzf-collection/blob/master/LICENSE)

A collection of functions to enhance cmdline with [FZF](https://github.com/junegunn/fzf)

<!-- markdown-toc start -->

**Table of Contents**

- [fzf-collection](#fzf-collection)
- [Install](#install)
  - [Manual](#manual)
  - [Oh-My-Zsh](#oh-my-zsh)
- [Commands](#commands)
  - [fzf-other](#fzf-other)
  - [fzf-browser](#fzf-browser)
  - [fzf-brew](#fzf-brew)
  - [fzf-pip](#fzf-pip)
  - [fzf-git](#fzf-git)
  - [fzf-gh](#fzf-gh)
- [Envrionment](#envrionment)
  - [FZF_COLLECTION_MODULES](#fzf_collection_modules)
  - [FZF_COLLECTION_OPTS](#fzf_collection_opts)
  - [FZF_COLLECTION_BROWSER](#fzf_collection_browser)
  - [todo](#todo)

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

## fzf-other

- `fp` : find `$PATH`
- `ffp` : find `$FPATH`
- `kp` : kill process

## fzf-browser

```sh
# dependency
brew install sqlite3 coreutils diffutils jq python-yq
```

- `bhf` : history search for `Google Chrome` `Microsoft Edge` `Mozilla Firefox` `MacOs Safari`
- `bbf` : bookmark search for `Google Chrome` `Microsoft Edge` `Mozilla Firefox`

## fzf-brew

- `brewf` : brew [package]

## fzf-pip

```sh
# dependency
brew install grep coreutils
```

- `pipf` : pip3 [package]

## fzf-git

```sh
# dependency
brew install git-extras coreutils gh
```

- `gitf` : git [package]

## fzf-gh

```sh
brew install gh jq
```

- `ghf` : manage user/repos

# Envrionment

## FZF_COLLECTION_MODULES

Settng `FZF_COLLECTION_MODULES` to load modules.
By default, all modules are loaded.

```sh
FZF_COLLECTION_MODULES=(
  default
  browser
  brew
  pip
  git
  gh)
```

## FZF_COLLECTION_OPTS

Setting `FZF_COLLECTION_OPTS` to customize fzf options.

```sh
# set options if needed, default value is as below :
  FZF_COLLECTION_OPTS="
  --header-first
  --ansi
  --reverse
  --cycle
  --no-multi
  --sort
  --exact
  --info=inline
  --bind=change:first,btab:up+toggle,ctrl-n:down,ctrl-p:up
  --bind=ctrl-u:cancel,ctrl-l:jump,ctrl-t:toggle-all,ctrl-v:clear-selection"
```

## FZF_COLLECTION_BROWSER

Settng `FZF_COLLECTION_BROWSER` to open url, use default browser if not set.

```sh
# choose from "chorme" "edgemac" "firefox" "safari"
FZF_COLLECTION_BROWSER="chrome"
```

## todo

- [x] brew sign: formulae or cask brew info --formula/--cask
- [x] brewf-rollback: inhibit reinstall same commit
- [ ] fzf: proxy gem npm cargo cpan
- [ ] remove sed,tr,awk dependecies with perl
