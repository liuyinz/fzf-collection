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
  - [fzf-brew](#fzf-brew)
  - [fzf-pip](#fzf-pip)
  - [fzf-git](#fzf-git)
- [Envrionment](#envrionment)
  - [FZF_COLLECTION_OPTS](#fzf_collection_opts)

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

```sh
# dependency
brew install coreutils gnu-sed gawk jq ripgrep
```

- `b` : chrome bookmark
- `h` : chrome history
- `kp` : kill process
- `fp` : find $PATH
- `ffp` : find $FPATH

## fzf-brew

- `bif` : brew install
- `buf` : brew uninstall
- `bgf` : brew upgrade
- `but` : brew untap

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
brew install git-extras coreutils gnu-sed 
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

# Envrionment

## FZF_COLLECTION_OPTS

Usually, `FZF_DEFAULT_OPTS` is applied if be settled. 
Another env `FZF_COLLECTION_OPTS` is provided for users to customize. 

```sh
# set options if needed, default value is as below :
export FZF_COLLECTION_OPTS=" \
    --reverse \
    --cycle \
    --multi \
    --sort \
    --exact \
    --info=inline"
```

