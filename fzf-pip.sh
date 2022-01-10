#!/usr/bin/env bash

_pipf_list_format() {
  local input pkg

  input="$([[ -p /dev/stdin ]] && cat - || return)"

  if [[ -n "$input" ]]; then
    pkg=$(pip3 list --not-required | tail -n +3 | perl -lane 'print $F[0]')

    echo "$input" \
      | perl -slane '
$sign = ($i =~ /$F[0]/ ? "\x1b[33minstall" : "\x1b[31mdepend");
printf "%s \x1b[34m%s %s\x1b[0m\n", $F[0], join" ",@F[1 .. $#F], $sign;' -- -i="$pkg" \
      | column -s ' ' -t
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
      | perl -lne '/">(.*?)<\/a>/ && print $1' \
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
      | perl -pe 's/ /\n/g' \
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
