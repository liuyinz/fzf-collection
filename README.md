# fzf-collection

[![GitHub license](https://img.shields.io/github/license/eki3z/fzf-collection)](https://github.com/eki3z/fzf-collection/blob/master/LICENSE)

A collection of commands to enhance commandline with [FZF](https://github.com/junegunn/fzf)

<!-- markdown-toc start -->

## Contents

- [fzf-collection](#fzf-collection)
  - [Install](#install)
    - [Manual](#manual)
    - [Oh-My-Zsh](#oh-my-zsh)
  - [Commands](#commands)
    - [fzf-brew](#fzf-brew)
    - [fzf-pip](#fzf-pip)
    - [fzf-uv](#fzf-uv)
    - [fzf-npm](#fzf-npm)
    - [fzf-pnpm](#fzf-pnpm)
    - [fzf-gh](#fzf-gh)
    - [fzf-other](#fzf-other)
  - [Environment](#environment)
    - [FZF_COLLECTION_MODULES](#fzf_collection_modules)
    - [FZF_COLLECTION_OPTS](#fzf_collection_opts)
    - [Todo](#todo)

<!-- markdown-toc end -->

## Install

### Manual

First, clone this repository.

```sh
git clone https://github.com/liuyinz/fzf-collection.git
```

Then add the following line to your `~/.zshrc` .

```sh
source /path/to/fzf-collection.plugin.zsh
```

### Oh-My-Zsh

Clone this repository to custom plugin directory

```sh
git clone https://github.com/liuyinz/fzf-collection.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-collection
```

To start using it, add the fzf-collection plugin to your plugins array in `~/.zshrc`:

```diff
- plugins=(...)
+ plugins=(... fzf-collection)
```

## Commands

### fzf-brew

- `brewf`: `outdated` `search` `manage` `tap`

### fzf-pip

```sh
# dependency
brew install grep coreutils
```

- `pipf`: `outdated` `search` `manage`

### fzf-uv

- `uvf`: `outdated` `manage`

### fzf-npm

- `npmf`: `manage` `outdated` `search` `registry`

### fzf-pnpm

- `pnpmf`: `manage` `outdated` `search` `registry`

### fzf-gh

```sh
brew install gh jq
```

- `ghf`: manage user/repos

### fzf-other

- `fp`: find `$PATH`
- `ffp`: find `$FPATH`

## Environment

### FZF_COLLECTION_MODULES

Setting `FZF_COLLECTION_MODULES` to load modules. By default, all modules are loaded.

```sh
FZF_COLLECTION_MODULES=(
  brew
  pip
  uv
  gh
  other
  )
```

### FZF_COLLECTION_OPTS

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