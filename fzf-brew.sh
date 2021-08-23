#!/usr/bin/env bash

# BREW
# ------------------

brew_switch() {
  # shellcheck disable=SC2028
  subcmd=$(echo "$2" | fzf "${fzf_opts[@]}")

  if [[ $subcmd ]]; then
    for f in $(echo "$1"); do
      case $subcmd in
        cat)
          bat "$(brew formula "$f")"
          ;;
        edit)
          $EDITOR "$(brew formula "$f")"
          ;;
        upgrade|uninstall)
          brew "$subcmd" "$f"
          # SEE https://stackoverflow.com/questions/5410757/how-to-delete-from-a-text-file-all-lines-that-contain-a-specific-string
          sed -i "/^${f}$/d" "$tmpfile"
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
  brew_switch "$1" "$2"
}

# [B]rew [S]earch [F]zf
bsf() {
  local inst
  inst=$(
    {
      brew formulae
      brew casks
    } | fzf "${fzf_opts[@]}" --header='[Brew Search: ]'
  )

  if [[ $inst ]]; then
    brew_switch "$inst" "install\noptions\ninfo\ndeps\nedit\ncat\nhome"
  else
    return 0
  fi
  bsf
}

# [B]rew [M]anage [F]zf
bmf() {
  local tmpfile inst
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

  if [[ $inst ]]; then
    brew_switch "$inst" "uninstall\noptions\ninfo\ndeps\nedit\ncat\nhome\nlink\nunlink\npin\nunpin\n"
  else
    rm -f $tmpfile && return 0
  fi
  bmf
}

# [B]rew up[G]rade [F]zf
bgf() {
  local tmpfile inst
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

  if [[ $inst ]]; then
    brew_switch "$inst" "upgrade\nuninstall\noptions\ninfo\ndeps\nedit\ncat\nhome\nlink\nunlink\npin\nunpin\n"
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
