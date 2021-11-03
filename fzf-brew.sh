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
        downgrade)
          brewf-downgrade "$f"
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
    _brewf_switch "$inst" "${opt[@]}"
  else
    return 0
  fi
  brewf-search
}

brewf-manage() {
  local tmpfile inst opt
  tmpfile=/tmp/brewf-manage
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

  opt=("uninstall" "downgrade" "link" "unlink" "pin" "unpin"
    "options" "info" "deps" "edit" "cat" "home")

  if [ -n "$inst" ]; then
    _brewf_switch "$inst" "${opt[@]}"
  else
    rm -f $tmpfile && return 0
  fi
  brewf-manage
}

brewf-upgrade() {
  local tmpfile inst opt
  tmpfile=/tmp/brewf-upgrade
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
    _brewf_switch "$inst" "${opt[@]}"
  else
    rm -f $tmpfile && return 0
  fi
  brewf-upgrade
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
    _brewf_switch "$inst" "${opt[@]}"
  else
    rm -f $tmpfile && return 0
  fi
  brewf-tap
}

brewf-downgrade() {
  local f path hash
  f="$1".rb
  path=$(find "$(brew --repository)" -name "$f")
  hash=$(brew log "$1" \
    | fzf "${fzf_opts[@]}" --header='[Brew Downgrade: ]' \
    | awk '{ print $1 }')
  if [ -n "$hash" ] && [ -n "$path" ]; then
    dir=$(dirname "$path")
    git -C "$dir" checkout "$hash" "$f"
    (HOMEBREW_NO_AUTO_UPDATE=1 && brew reinstall "$1")
    git -C "$dir" checkout HEAD "$f"
  else
    return 0
  fi
}

brewf() {
  local cmd select
  cmd=("upgrade" "search" "manage" "tap")
  select=$(echo "${cmd[@]}" | tr ' ' '\n' | fzf "${fzf_opts[@]}")
  if [ -n "$select" ]; then
    case $select in
      upgrade) brewf-upgrade ;;
      search) brewf-search ;;
      manage) brewf-manage ;;
      tap) brewf-tap ;;
    esac
  fi
}
