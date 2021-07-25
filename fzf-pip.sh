#!/usr/bin/env bash

# PIP
# -----------------------
# [P]ip [I]nstall
ppi() {
  local inst
  inst=$(curl -s "$(pip3 config get global.index-url)/" |
    grep '</a>' | gsed 's/^.*">//g' | gsed 's/<.*$//g' |
    eval "fzf ${FZF_COLLECTION_OPTS} --header='[pip:install]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      pip3 install --user "$prog"
    done
  fi
}

# [P]ip up[G]rade
ppg() {
  local inst
  inst=$(pip3 list --outdated | tail -n +3 | awk '{print $1}' |
    eval "fzf ${FZF_COLLECTION_OPTS} --header='[pip:upgrade]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      pip3 install --user --upgrade "$prog"
    done
  fi
}

# [P]ip [U]ninstall
ppu() {
  local inst
  inst=$(pip3 list | tail -n +3 | awk '{print $1}' |
    eval "fzf ${FZF_COLLECTION_OPTS} --header='[pip:uninstall]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      pip3 uninstall --yes "$prog"
    done
  fi
}
