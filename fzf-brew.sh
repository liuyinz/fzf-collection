#!/usr/bin/env bash

#  SEE https://gist.github.com/steakknife/8294792

_brewf_switch() {

  subcmd=$(echo "${@:3}" | tr ' ' '\n' | _fzf_single --header "$1")

  if [ -n "$subcmd" ]; then
    for f in $(echo "$2"); do
      case $subcmd in
        cat)
          bat "$(brew formula "$f")"
          ;;
        edit)
          $EDITOR "$(brew formula "$f")"
          ;;
        install)
          brew "$subcmd" "$f"
          ;;
        rollback)
          brewf-rollback "$f"
          ;;
        upgrade | uninstall | untap)
          if brew "$subcmd" "$f"; then
            #  SEE https://stackoverflow.com/questions/5410757/how-to-delete-from-a-text-file-all-lines-that-contain-a-specific-string
            #  SEE https://stackoverflow.com/a/17273270 , escape '/' in path
            #  SEE https://unix.stackexchange.com/a/33005
            sed -i "/^$(sed 's/\//\\&/g' <<<"$f")$/d" "$tmpfile"
          fi
          ;;
        *) brew "$subcmd" "$f" ;;
      esac
      echo ""
    done
    case $subcmd in
      #  SEE https://stackoverflow.com/a/4827707
      install | untap) set -- "$1" "${@:3}" ;;
      upgrade | uninstall) set -- "$1" "${@:7}" ;;
    esac
  else
    return 0
  fi

  _brewf_switch "$@"

}

brewf-rollback() {
  local f dir hash

  f="$1.rb"
  dir=$(dirname "$(find "$(brew --repository)" -name "$f")")
  hash=$(
    git -C "$dir" log --color=always -- "$f" \
      | _fzf_multi_header --ansi \
      | awk '{ print $1 }'
  )

  if [ -n "$hash" ] && [ -n "$dir" ]; then
    git -C "$dir" checkout "$hash" "$f"
    (HOMEBREW_NO_AUTO_UPDATE=1 && brew reinstall "$1")
    git -C "$dir" checkout HEAD "$f"
  else
    return 0
  fi

}

brewf-search() {
  local inst opt

  inst=$(
    {
      brew formulae
      brew casks
    } | _fzf_multi_header
  )

  opt=("install" "rollback" "options" "info" "deps" "edit" "cat"
    "home" "uninstall" "link" "unlink" "pin" "unpin")

  if [ -n "$inst" ]; then
    _brewf_switch "$(_headerf)" "$inst" "${opt[@]}"
  else
    return 0
  fi

  brewf-search

}

brewf-manage() {
  local tmpfile inst opt

  tmpfile=/tmp/brewf-manage

  opt=("uninstall" "rollback" "link" "unlink" "pin" "unpin"
    "options" "info" "deps" "edit" "cat" "home")

  if [ ! -e $tmpfile ]; then
    touch $tmpfile
    inst=$(brew list -1t | tee $tmpfile | _fzf_multi_header)
  else
    inst=$(cat <$tmpfile | _fzf_multi_header)
  fi

  if [ -n "$inst" ]; then
    _brewf_switch "$(_headerf)" "$inst" "${opt[@]}"
  else
    rm -f $tmpfile && return 0
  fi

  brewf-manage

}

brewf-upgrade() {
  local tmpfile inst opt

  tmpfile=/tmp/brewf-upgrade

  opt=("upgrade" "link" "unlink" "pin" "unpin"
    "uninstall" "options" "info" "deps" "edit" "cat" "home")

  if [ ! -e $tmpfile ]; then
    touch $tmpfile
    brew update
    inst=$(brew outdated | tee $tmpfile | _fzf_multi_header)
  else
    inst=$(cat <$tmpfile | _fzf_multi_header)
  fi

  if [ -n "$inst" ]; then
    _brewf_switch "$(_headerf)" "$inst" "${opt[@]}"
  else
    rm -f $tmpfile && return 0
  fi

  brewf-upgrade

}

brewf-tap() {
  local tmpfile inst opt

  tmpfile=/tmp/btf

  opt=("untap" "tap-info")

  if [ ! -e $tmpfile ]; then
    touch $tmpfile
    inst=$(brew tap | tee $tmpfile | _fzf_multi_header)
  else
    inst=$(cat <$tmpfile | _fzf_multi_header)
  fi

  if [ -n "$inst" ]; then
    _brewf_switch "$(_headerf)" "$inst" "${opt[@]}"
  else
    rm -f $tmpfile && return 0
  fi

  brewf-tap

}

brewf() {
  local cmd select

  cmd=("upgrade" "search" "manage" "tap")
  select=$(
    echo "${cmd[@]}" \
      | tr ' ' '\n' \
      | _fzf_single --header "$(_headerf "Brewf Fzf")"
  )

  if [ -n "$select" ]; then
    case $select in
      upgrade) brewf-upgrade ;;
      search) brewf-search ;;
      manage) brewf-manage ;;
      tap) brewf-tap ;;
    esac
  fi

}
