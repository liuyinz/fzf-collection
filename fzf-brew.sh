#!/usr/bin/env sh

#  SEE https://gist.github.com/steakknife/8294792

_brewf_switch() {
  subcmd=$(echo "${@:2}" | tr ' ' '\n' | fzf "${fzf_opts[@]}")

  if [ -n "$subcmd" ]; then
    for f in $(echo "$1"); do
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
        upgrade | uninstall | untap)
          brew "$subcmd" "$f"
          #  SEE https://stackoverflow.com/questions/5410757/how-to-delete-from-a-text-file-all-lines-that-contain-a-specific-string
          #  SEE https://stackoverflow.com/a/17273270 , escape '/' in path
          #  SEE https://unix.stackexchange.com/a/33005
          sed -i "/^$(sed 's/\//\\&/g' <<<"$f")$/d" "$tmpfile"
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
  _brew_switch "$@"
}

brewf-search() {
  local inst opt
  inst=$(
    {
      brew formulae
      brew casks
    } | fzf "${fzf_opts[@]}" --header='[Brew Search: ]'
  )

  opt=("install" "options" "info" "deps" "edit" "cat"
    "home" "uninstall" "link" "unlink" "pin" "unpin")
  if [ -n "$inst" ]; then
    _brew_switch "$inst" "${opt[@]}"
  else
    return 0
  fi
  bsf
}

brewf-manage() {
  local tmpfile inst opt
  tmpfile=/tmp/bmf
  if [ ! -e $tmpfile ]; then
    touch $tmpfile
    inst=$(
      {
        brew leaves
        brew list --cask
      } | tee $tmpfile \
        | fzf "${fzf_opts[@]}" --header='[Brew Manage: ]'
    )
  else
    inst=$(
      cat <$tmpfile | fzf "${fzf_opts[@]}" --header='[Brew Manage: ]'
    )
  fi

  opt=("uninstall" "link" "unlink" "pin" "unpin"
    "options" "info" "deps" "edit" "cat" "home")

  if [ -n "$inst" ]; then
    _brew_switch "$inst" "${opt[@]}"
  else
    rm -f $tmpfile && return 0
  fi
  bmf
}

brewf-upgrade() {
  local tmpfile inst opt
  tmpfile=/tmp/bgf
  if [ ! -e $tmpfile ]; then
    touch $tmpfile
    brew update
    inst=$(brew outdated --greedy \
      | tee $tmpfile \
      | fzf "${fzf_opts[@]}" --header='[Brew Upgrade: ]')
  else
    inst=$(cat <$tmpfile \
      | fzf "${fzf_opts[@]}" --header='[Brew Upgrade: ]')
  fi

  opt=("upgrade" "link" "unlink" "pin" "unpin"
    "uninstall" "options" "info" "deps" "edit" "cat" "home")

  if [ -n "$inst" ]; then
    _brew_switch "$inst" "${opt[@]}"
  else
    rm -f $tmpfile && return 0
  fi
  bgf
}

brewf-tap() {
  local tmpfile inst opt
  tmpfile=/tmp/btf
  if [ ! -e $tmpfile ]; then
    touch $tmpfile
    inst=$(brew tap \
      | tee $tmpfile \
      | fzf "${fzf_opts[@]}" --header='[Brew Tap: ]')
  else
    inst=$(cat <$tmpfile | fzf "${fzf_opts[@]}" --header='[Brew Tap: ]')
  fi

  opt=("untap" "tap-info")
  if [ -n "$inst" ]; then
    _brew_switch "$inst" "${opt[@]}"
  else
    rm -f $tmpfile && return 0
  fi
  btf
}

brewf() {
  local cmd select
  cmd=("search" "manage" "upgrade" "tap")
  select=$(echo "${cmd[@]}" | tr ' ' '\n' | fzf "${fzf_opts[@]}")
  if [ -n "$select" ]; then
    case $select in
      search) brewf-search ;;
      manage) brewf-manage ;;
      upgrade) brewf-upgrade ;;
      tap) brewf-tap ;;
    esac
  fi
}
