#!/usr/bin/env bash

# SEE https://gist.github.com/steakknife/8294792

_brewf_pkg_version() {
  brew list --versions | perl -slne '/^$f (.+)$/ && print "$1"' -- -f="$1"
}

_brewf_list_outdated() {
  brew update &>/dev/null
  brew outdated --greedy --verbose \
    | grep -Fv "pinned at" \
    | perl -pe 's/, /|/g; tr/()//d' \
    | perl -ane 'printf "%s %s %s\n", $F[0], $F[1], $F[3]'

  # # NOTE time consuming is as twice as above
  #   brew info --json=v2 --installed \
  #     | jq -r '.[] | values[] | "\(.name | if type=="array" then .[0] else . end) \(.installed | if type=="array" then map(.version) | join("|") else . end)"' \

}

_brewf_list_installed() {
  brew list --versions \
    | perl -ane 'printf "%s %s\n", $F[0], join"|",@F[1 .. $#F]'

  # # NOTE time consuming is as twice as above
  #   brew info --json=v2 --installed \
  #     | jq -r '.[] | values[] | "\(.name | if type=="array" then .[0] else . end) \(.installed | if type=="array" then map(.version) | join("|") else . end)"'

}

_brewf_list_available() {
  brew formulae
  brew casks
}

_brewf_switch() {
  local subcmd

  subcmd=$(_fzf_subcmd)

  if [ -n "$subcmd" ]; then
    for f in $(echo "$inst"); do
      case $subcmd in
        rollback)
          _brewf_rollback "$f"
          ;;
        edit)
          $EDITOR "$(brew formula "$f")"
          ;;
        upgrade | uninstall | untap)
          brew "$subcmd" "$f" && _fzf_tmp_shift "$f"
          ;;
        uses)
          brew uses --installed "$f"
          ;;
        deps)
          brew deps "$f" --tree
          ;;
        *) brew "$subcmd" "$f" ;;
      esac
      echo ""
    done

    case $subcmd in
      upgrade | uninstall | untap | rollback) return 0 ;;
    esac

  else
    return 0
  fi

  _brewf_switch

}

_brewf_rollback() {
  local pkg dir sha header

  header=$(_fzf_header)
  pkg="$1"
  f="$pkg.rb"
  dir=$(dirname "$(find "$(brew --repository)" -name "$f")")

  if [ -n "$dir" ]; then
    _fzf_msg "$(_brewf_pkg_version "$pkg")" "$pkg"
    sha=$(
      git -C "$dir" log --color=always --pretty='format:%s' -- "$f" \
        | _fzf_single --tiebreak=index --query="$1 update"
    )

    if [ -n "$sha" ]; then
      brew unpin "$pkg" &>/dev/null

      git -C "$dir" checkout "$sha" "$f"
      (HOMEBREW_NO_AUTO_UPDATE=1 && brew reinstall "$pkg")
      git -C "$dir" checkout HEAD "$f"

      # pin formulae if it's not the latest.
      brew outdated "$pkg" &>/dev/null || brew pin "$pkg" &>/dev/null

    else
      echo "No commit selected." && return 0
    fi

  else
    echo "No formulae or cask exists." && return 0
  fi
}

brewf-search() {
  local tmpfile inst opt header available switch

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmp_create)
  available="_brewf_list_available"
  switch="_brewf_switch"
  opt=("install" "rollback" "options" "homepage" "info" "deps" "uses" "edit" "cat"
    "uninstall" "link" "unlink" "pin" "unpin")

  _fzf_search
}

brewf-manage() {
  local inst opt header tmpfile format installed switch

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmp_create)
  format="manage"
  installed="_brewf_list_installed"
  switch="_brewf_switch"
  opt=("uninstall" "rollback" "homepage" "link" "unlink" "pin" "unpin"
    "options" "info" "deps" "uses" "edit" "cat")

  _fzf_manage
}

brewf-outdated() {
  local inst opt header tmpfile format outdated switch

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmp_create)
  format="outdated"
  outdated="_brewf_list_outdated"
  switch="_brewf_switch"
  opt=("upgrade" "uninstall" "rollback" "options" "homepage" "info" "deps" "edit" "cat")

  _fzf_outdated
}

brewf-tap() {
  local tmpfile inst opt header

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmp_create)
  opt=("untap" "tap-info")

  if [ ! -e "$tmpfile" ]; then
    tap_list=$(brew tap)

    if [ -n "$tap_list" ]; then
      touch "$tmpfile"
      inst=$(echo "$tap_list" | _fzf_tmp_write)
    else
      echo "No tap."
      return 0
    fi

  else

    if [ -s "$tmpfile" ]; then
      inst=$(_fzf_tmp_read)
    else
      echo "No tap."
      rm -f "$tmpfile" && return 0
    fi
  fi

  if [ -n "$inst" ]; then
    _brewf_switch
  else
    echo "Tap cancel."
    rm -f "$tmpfile" && return 0
  fi

  brewf-tap
}

brewf-pinned() {
  local tmpfile inst opt header format switch caller lst

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmp_create)
  caller=$(_fzf_parent 1)
  switch="_brewf_switch"
  format="pinned"
  opt=("unpin" "rollback" "uninstall" "homepage" "link" "unlink"
    "options" "info" "deps" "uses" "edit" "cat")

  if [ ! -e "$tmpfile" ]; then
    lst=$(brew ls --pinned --versions)
    if [ -n "$lst" ]; then
      touch "$tmpfile"
      inst=$(echo "$lst" | _fzf_format | _fzf_tmp_write)
    else
      _fzf_msg "No pinned." && return 0
    fi

  else

    if [ -s "$tmpfile" ]; then
      inst=$(_fzf_tmp_read)
    else
      rm -f "$tmpfile"
      _fzf_msg "No pinned." && return 0
    fi
  fi

  if [ -n "$inst" ]; then
    eval " $switch"
  else
    rm -f "$tmpfile"
    _fzf_msg "Unpin cancel." && return 0
  fi

  brewf-pinned
}

brewf() {
  local header opt

  header=$(_fzf_header)
  opt=("outdated" "search" "manage" "pinned" "tap")

  _fzf_command

}
