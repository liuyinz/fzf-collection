# fzf-collection
[![GitHub license](https://img.shields.io/github/license/liuyinz/fzf-collection)](https://github.com/liuyinz/fzf-collection/blob/master/LICENSE)

A collection of functions to enhance cmdline with [FZF](https://github.com/junegunn/fzf)

# Install

### Manual

First, clone this repository.

```zsh
git clone https://github.com/liuyinz/fzf-collection.git
```

Then add the following line to your `~/.zshrc` .

```zsh
source /path/to/fzf-collection.plugin.zsh
```

### Oh-My-Zsh

Clone this repository to custom plugin directory

```zsh
git clone https://github.com/liuyinz/fzf-collection.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-collection
```

To start using it, add the fzf-collection plugin to your plugins array in `~/.zshrc`:

```zsh
plugins=(... fzf-collection)
```

# Commands

### fzf-brew

- `bif` : brew install [formulae]
- `bic` : brew install [cask]
- `buf` : brew uninstall [formulae]
- `buc` : brew uninstall [cask]
- `bgf` : brew upgrade [both]
- `but` : brew untap
- `brd` : remove useless dependence
- `bio` : install older formulae

### fzf-pip

- `ppi` : pip3 install [package]
- `ppc` : pip3 uninstall [package]
- `ppg` : pip3 upgrade [package]

### fzf-default (MacOS)

- `b` : chrome bookmark
- `h` : chrome history
- `kp` : kill process
- `fp` : find $PATH
- `ffp` : find $FPATH
