#!/usr/bin/env bash

# BREW
# ------------------

# [B]rew [I]nstall [F]ormulae
bif() {
  local inst
  inst=$(brew formulae | eval "fzf ${FZF_DEFAULT_OPTS} \
    --exact --header='[brew install: formulae]'")

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
  inst=$(brew casks | eval "fzf ${FZF_DEFAULT_OPTS} \
    --exact --header='[brew install: cask]'")

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

# [B]rew [C]lean [F]ormulae
bcf() {
  local uninst
  uninst=$(brew leaves | eval "fzf ${FZF_DEFAULT_OPTS} \
    --header='[brew uninstall: formulae]'")

  if [[ $uninst ]]; then
    for prog in $(echo "$uninst"); do
      brew uninstall "$pro"
    done
  fi
}

# [B]rew [C]lean [C]ask
bcc() {
  local uninst
  uninst=$(brew list --cask | eval "fzf ${FZF_DEFAULT_OPTS} \
    --header='[brew uninstall: cask]'")

  if [[ $uninst ]]; then
    for prog in $(echo "$uninst"); do
      brew uninstall --cask "$prog"
    done
  fi
}

# [B]rew [U]pdate [P]lugin
bup() {
  brew update
  local upd
  upd=$(brew outdated --greedy | eval "fzf ${FZF_DEFAULT_OPTS} \
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
  upd=$(brew tap | eval "fzf ${FZF_DEFAULT_OPTS} \
    --header='[brew untap:]'")

  if [[ $upd ]]; then
    for prog in $(echo "$upd"); do
      brew untap "$prog"
    done
  fi
}

# brew remove useless dependence
# -------------------
# [B]rew [R]emove [D]ependence
brd() {
  export HOMEBREW_NO_AUTO_UPDATE=1
  brew bundle dump -q -f --file="/tmp/Brewfile"
  brew bundle -f --cleanup --file="/tmp/Brewfile"
  rm /tmp/Brewfile
}

# [B]rew [I]nstall [O]lder Version Formula
# -------------------
bio() {
  local pwd
  pwd=$(pwd)
  cd $HOMEBREW_FORMULA || return
  if git cat-file -e $2 2>/dev/null; then
    if [ -e $1.rb ]; then
      echo "Installing..."
      git checkout $2 $1.rb
      HOMEBREW_NO_AUTO_UPDATE=1 brew install $1
    else
      echo "Error ! file $1.rb not exists."
    fi
  else
    echo "Error ! Commit $2 not exists."
  fi
  cd $pwd || exit
}
