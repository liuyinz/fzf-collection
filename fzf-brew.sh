#!/usr/bin/env bash

# BREW
# ------------------

brew_switch() {
  if [[ $1 ]]; then
    # shellcheck disable=SC2028
    subcmd=$(echo "$2" | eval "fzf --header='[Brew Formulae: subcmd]'")
    for f in $(echo "$1"); do
      case $subcmd in
      cat)
        bat "$(brew formula "$f")"
        ;;
      edit)
        $EDITOR "$(brew formula "$f")"
        ;;
      upgrade)
        brew upgrade --greedy "$f"
        ;;
      *)
        brew "$subcmd" "$f"
        ;;
      esac
      echo ""
    done
  fi
}

# [B]rew [S]earch [F]zf
bsf() {
  local inst
  inst=$(
    (
      brew formulae
      brew casks
    ) |
      eval "fzf ${FZF_COLLECTION_OPTS} --header='[Brew Search: ]'"
  )

  brew_switch "$inst" "install\noptions\ninfo\ndeps\nedit\ncat\nhome"
}

# [B]rew [M]anage [F]zf
bmf() {
  local inst
  inst=$(
    (
      brew leaves
      brew list --cask
    ) | eval "fzf ${FZF_COLLECTION_OPTS} --header='[Brew Manage: ]'"
  )

  brew_switch "$inst" "uninstall\noptions\ninfo\ndeps\nedit\ncat\nhome\nlink\nunlink\npin\nunpin\n"
}

# [B]rew up[G]rade [F]zf
bgf() {
  brew update
  local inst
  inst=$(brew outdated --greedy | eval "fzf ${FZF_COLLECTION_OPTS} \
    --header='[Brew Upgrade: ]'")

  brew_switch "$inst" "upgrade\nuninstall\noptions\ninfo\ndeps\nedit\ncat\nhome\nlink\nunlink\npin\nunpin\n"
}

# [B]rew [T]ap [F]zf
btf() {
  local inst
  inst=$(brew tap | eval "fzf ${FZF_COLLECTION_OPTS} --header='[Brew Tap: ]'")

  brew_switch "$inst" "untap\ntap-info"
}
