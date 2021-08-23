#!/usr/bin/env bash

#  SEE https://gist.github.com/steakknife/8294792

# BREW
# ------------------

brew_switch() {
  subcmd=$(echo "${@:2}" | tr ' ' '\n' | fzf "${fzf_opts[@]}")

  if [[ $subcmd ]]; then
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
          set -- "$1" "${@:3}"
          ;;
        upgrade | uninstall)
          brew "$subcmd" "$f"
          #  SEE https://stackoverflow.com/questions/5410757/how-to-delete-from-a-text-file-all-lines-that-contain-a-specific-string
          sed -i "/^${f}$/d" "$tmpfile"
          #  SEE https://stackoverflow.com/a/4827707
          set -- "$1" "${@:7}"
          ;;
        *)
          brew "$subcmd" "$f"
          ;;
      esac
      echo ""
    done
  else
    return 0
  fi
  brew_switch "$@"
}

# [B]rew [S]earch [F]zf
bsf() {
  local inst opt
  inst=$(
    {
      brew formulae
      brew casks
    } | fzf "${fzf_opts[@]}" --header='[Brew Search: ]'
  )

  opt=("install" "options" "info" "deps" "edit" "cat" "home" "uninstall" "link" "unlink" "pin" "unpin")
  if [[ $inst ]]; then
    brew_switch "$inst" "${opt[@]}"
  else
    return 0
  fi
  bsf
}

# [B]rew [M]anage [F]zf
bmf() {
  local tmpfile inst opt
  tmpfile=/tmp/bmf
  if [[ ! -e $tmpfile ]]; then
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

  if [[ $inst ]]; then
    brew_switch "$inst" "${opt[@]}"
  else
    rm -f $tmpfile && return 0
  fi
  bmf
}

# [B]rew up[G]rade [F]zf
bgf() {
  local tmpfile inst opt
  tmpfile=/tmp/bgf
  if [[ ! -e $tmpfile ]]; then
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

  if [[ $inst ]]; then
    brew_switch "$inst" "${opt[@]}"
  else
    rm -f $tmpfile && return 0
  fi
  bgf
}

# [B]rew [T]ap [F]zf
btf() {
  local inst
  inst=$(brew tap | fzf "${fzf_opts[@]}" --header='[Brew Tap: ]')

  if [[ $inst ]]; then
    brew_switch "$inst" "untap\ntap-info"
  else
    return 0
  fi
  btf
}
