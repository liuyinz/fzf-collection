#!/usr/bin/env sh

pipf-install() {
  local inst
  inst=$(curl -s "$(pip3 config get global.index-url)/" \
    | grep '</a>' \
    | sed 's/^.*">//g' \
    | sed 's/<.*$//g' \
    | fzf "${fzf_opts[@]}" --header='[pip:install]')

  if [ -n "$inst" ]; then
    for f in $(echo "$inst"); do
      pip3 install --user "$f"
    done
  fi
}

pipf-uninstall() {
  local inst
  inst=$(pip3 list \
    | tail -n +3 \
    | fzf "${fzf_opts[@]}" --header='[pip:uninstall]' \
    | awk '{print $1}')

  if [ -n "$inst" ]; then
    for f in $(echo "$inst"); do
      pip3 uninstall --yes "$f"
    done
  fi
}

pipf-upgrade() {
  local inst
  inst=$(pip3 list --outdated \
    | tail -n +3 \
    | fzf "${fzf_opts[@]}" --header='[pip:upgrade]' \
    | awk '{print $1}')

  if [ -n "$inst" ]; then
    for f in $(echo "$inst"); do
      pip3 install --user --upgrade "$f"
    done
  fi
}

pipf() {
  local cmd select
  cmd=("upgrade" "install" "uninstall")
  select=$(echo "${cmd[@]}" | tr ' ' '\n' | fzf "${fzf_opts[@]}")
  if [ -n "$select" ]; then
    case $select in
      upgrade) pipf-upgrade ;;
      install) pipf-install ;;
      uninstall) pipf-uninstall ;;
    esac
  fi
}
