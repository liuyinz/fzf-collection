#!/usr/bin/env bash

pipf-install() {
  local inst

  inst=$(
    curl -s "$(pip3 config get global.index-url)/" \
      | grep '</a>' \
      | sed 's/^.*">//g' \
      | sed 's/<.*$//g' \
      | _fzf_multi_header
  )

  if [ -n "$inst" ]; then
    for f in $(echo "$inst"); do
      pip3 install --user "$f"
    done
  else
    return 0
  fi

}

pipf-uninstall() {
  local inst

  inst=$(
    pip3 list \
      | tail -n +3 \
      | _fzf_multi_header \
      | awk '{print $1}'
  )

  if [ -n "$inst" ]; then
    for f in $(echo "$inst"); do
      pip3 uninstall --yes "$f"
    done
  else
    return 0
  fi

}

pipf-upgrade() {
  local inst

  inst=$(
    pip3 list --outdated \
      | tail -n +3 \
      | _fzf_multi_header \
      | awk '{print $1}'
  )

  if [ -n "$inst" ]; then
    for f in $(echo "$inst"); do
      pip3 install --user --upgrade "$f"
    done
  else
    return 0
  fi

}

pipf() {
  local cmd select

  cmd=("upgrade" "install" "uninstall")
  select=$(
    echo "${cmd[@]}" \
      | tr ' ' '\n' \
      | _fzf_single_header
  )

  if [ -n "$select" ]; then
    case $select in
      upgrade) pipf-upgrade ;;
      install) pipf-install ;;
      uninstall) pipf-uninstall ;;
    esac
  else
    return 0
  fi

}
