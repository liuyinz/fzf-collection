#!/usr/bin/env bash

# PIP
# -----------------------
# [P]ip [I]nstall
ppi() {
  local inst
  inst=$(curl -s "$(pip3 config get global.index-url)/" \
    | grep '</a>' \
    | sed 's/^.*">//g' \
    | sed 's/<.*$//g' \
    | fzf "${fzf_opts[@]}" --header='[pip:install]')

  if [[ $inst ]]; then
    for f in $(echo "$inst"); do
      pip3 install --user "$f"
    done
  fi
}

# [P]ip up[G]rade
ppg() {
  local inst
  inst=$(pip3 list --outdated \
    | tail -n +3 \
    | awk '{print $1}' \
    | fzf "${fzf_opts[@]}" --header='[pip:upgrade]')

  if [[ $inst ]]; then
    for f in $(echo "$inst"); do
      pip3 install --user --upgrade "$f"
    done
  fi
}

# [P]ip [U]ninstall
ppu() {
  local inst
  inst=$(pip3 list \
    | tail -n +3 \
    | awk '{print $1}' \
    | fzf "${fzf_opts[@]}" --header='[pip:uninstall]')

  if [[ $inst ]]; then
    for f in $(echo "$inst"); do
      pip3 uninstall --yes "$f"
    done
  fi
}
