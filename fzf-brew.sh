#!/usr/bin/env bash

# BREW
# ------------------

# [B]rew [I]nstall [F]zf
bif() {
  local inst
  inst=$(
    (
      brew formulae
      brew casks
    ) | eval "fzf ${FZF_COLLECTION_OPTS} --header='[brew install: ]'"
  )

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      if brew ls --versions "$prog" &>/dev/null ||
        brew ls --casks --versions "$prog" &>/dev/null; then
        echo "$prog already installed."
      else
        brew install "$prog"
      fi
    done
  fi
}

# [B]rew [U]ninstal [F]zf
buf() {
  local uninst
  uninst=$(
    (
      brew leaves
      brew list --cask
    ) | eval "fzf ${FZF_COLLECTION_OPTS} --header='[brew uninstall: ]'"
  )

  if [[ $uninst ]]; then
    for prog in $(echo "$uninst"); do
      brew uninstall "$prog"
    done
  fi
}

# [B]rew up[G]rade [F]zf
bgf() {
  brew update
  local upd
  upd=$(brew outdated --greedy | eval "fzf ${FZF_COLLECTION_OPTS} \
    --header='[brew update: ]'")

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
