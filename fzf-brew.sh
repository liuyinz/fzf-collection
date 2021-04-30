#!/usr/bin/env bash

# BREW
# ------------------

# [B]rew [I]nstall [F]ormulae
bif() {
  local inst
  inst=$(brew formulae | eval "fzf ${FZF_COLLECTION_OPTS} \
    --header='[brew install: formulae]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      if brew ls --versions $prog &>/dev/null; then
        echo "$prog already installed."
      else
        brew install $prog
      fi
    done
  fi
}

# [B]rew [I]nstall [C]ask
bic() {
  local inst
  inst=$(brew casks | eval "fzf ${FZF_COLLECTION_OPTS} \
    --header='[brew install: cask]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      if brew ls --cask --versions $prog &>/dev/null; then
        echo "$prog already installed."
      else
        brew install $prog
      fi
    done
  fi
}

# [B]rew [U]ninstal [F]ormulae
buf() {
  local uninst
  uninst=$(brew leaves | eval "fzf ${FZF_COLLECTION_OPTS} \
    --header='[brew uninstall: formulae]'")

  if [[ $uninst ]]; then
    for prog in $(echo "$uninst"); do
      brew uninstall "$prog"
    done
  fi
}

# [B]rew [U]ninstall [C]ask
buc() {
  local uninst
  uninst=$(brew list --cask | eval "fzf ${FZF_COLLECTION_OPTS} \
    --header='[brew uninstall: cask]'")

  if [[ $uninst ]]; then
    for prog in $(echo "$uninst"); do
      brew uninstall --cask "$prog"
    done
  fi
}

# [B]rew up[G]rade [F]ormulae
bgf() {
  brew update
  local upd
  upd=$(brew outdated --greedy | eval "fzf ${FZF_COLLECTION_OPTS} \
    --header='[brew update: both]'")

  if [[ $upd ]]; then
    for prog in $(echo "$upd"); do
      brew upgrade --greedy "$prog"
    done
  fi
}

# [B]rew [U]n[T]ap
but() {
  local upd
  upd=$(brew tap | eval "fzf ${FZF_COLLECTION_OPTS} \
    --header='[brew untap:]'")

  if [[ $upd ]]; then
    for prog in $(echo "$upd"); do
      brew untap "$prog"
    done
  fi
}
