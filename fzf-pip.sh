#!/usr/bin/env bash

_pipf_list_format() {
  local input

  input="$([[ -p /dev/stdin ]] && cat - || return)"

  if [[ -n "$input" ]]; then
    export install=$(pip3 list --not-required | tail -n +3 | awk '{print $1}')

    echo "$input" \
      | perl -lane '
$sign = ($ENV{install}=~ /$F[0]/ ? "\x1b[33minstall" : "\x1b[31mdepend");
printf "%s \x1b[34m%s %s\x1b[0m\n", $F[0], join" ",@F[1 .. $#F], $sign;' \
      | column -s ' ' -t

    export install=
  fi
}

_pipf_list() {
  pip3 list --version "$@" | tail -n +3
}

pipf-install() {
  local inst header

  header="Pip Install"
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
  local inst header

  header="Pip Uninstall"
  inst=$(
    _pipf_list \
      | perl -lane 'print join" ",@F[0..$#F]' \
      | _pipf_list_format \
      | _fzf_multi_header \
      | perl -lane 'print $F[0]'
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
  local inst header

  header="Pip Upgrade"
  inst=$(
    _pipf_list --outdated \
      | perl -lane 'printf "%s %s -> %s\n", $F[0], $F[1], $F[2]' \
      | _pipf_list_format \
      | _fzf_multi_header \
      | perl -lane 'print $F[0]'
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
  local cmd select header

  header="Pip Fzf"
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
