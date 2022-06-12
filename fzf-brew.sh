#!/usr/bin/env bash

# SEE https://gist.github.com/steakknife/8294792

_brewf_switch() {

  subcmd=$(echo "${@:2}" | perl -pe 's/ /\n/g' | _fzf_single)

  if [ -n "$subcmd" ]; then
    for f in $(echo "$1"); do
      case $subcmd in
        rollback)
          _brewf_rollback "$f"
          ;;
        edit)
          $EDITOR "$(brew formula "$f")"
          ;;
        upgrade | uninstall | untap)
          brew "$subcmd" "$f" && _fzf_tmpfile_shift "$f"
          ;;
        uses)
          brew uses --installed "$f"
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

  _brewf_switch "$@"

}

_brewf_rollback() {
  local f dir sha header

  header=$(_fzf_header)
  f="$1.rb"
  dir=$(dirname "$(find "$(brew --repository)" -name "$f")")

  if [ -n "$dir" ]; then
    sha=$(
      git -C "$dir" log --color=always -- "$f" \
        | _fzf_single --tiebreak=index --query="$1 update"
    )

    if [ -n "$sha" ]; then
      brew unpin "$1" &>/dev/null

      git -C "$dir" checkout "$sha" "$f"
      (HOMEBREW_NO_AUTO_UPDATE=1 && brew reinstall "$1")
      git -C "$dir" checkout HEAD "$f"

      if ! brew outdated "$1" &>/dev/null; then
        brew pin "$1" &>/dev/null
      fi

    else
      echo "No commit selected." && return 0
    fi

  else
    echo "No formulae or cask exists." && return 0
  fi

}

brewf-search() {
  local tmpfile inst opt header

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmpfile)

  opt=("install" "rollback" "options" "homepage" "info" "deps" "uses" "edit" "cat"
    "uninstall" "link" "unlink" "pin" "unpin")

  if [ ! -e "$tmpfile" ]; then
    touch "$tmpfile"

    inst=$(
      {
        brew formulae
        brew casks
      } \
        | _fzf_tmpfile_write
    )

  else
    inst=$(_fzf_tmpfile_read)
  fi

  if [ -n "$inst" ]; then
    _brewf_switch "$inst" "${opt[@]}"
  else
    rm -f "$tmpfile" && return 0
  fi

  brewf-search

}

brewf-manage() {
  local tmpfile inst opt header

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmpfile)

  opt=("uninstall" "rollback" "homepage" "link" "unlink" "pin" "unpin"
    "options" "info" "deps" "uses" "edit" "cat")

  if [ ! -e "$tmpfile" ]; then
    touch "$tmpfile"

    inst=$(
      brew list --versions \
        | perl -ane 'printf "%s %s\n", $F[0], join"|",@F[1 .. $#F]' \
        | _fzf_format manage \
        | _fzf_tmpfile_write
    )

    # # NOTE time consuming is as twice as above
    # inst=$(
    #   brew info --json=v2 --installed \
    #     | jq -r '.[] | values[] | "\(.name | if type=="array" then .[0] else . end) \(.installed | if type=="array" then map(.version) | join("|") else . end)"' \
    #     | _fzf_format manage \
    #     | _fzf_tmpfile_write
    # )

  else

    inst=$(_fzf_tmpfile_read)
  fi

  if [ -n "$inst" ]; then
    _brewf_switch "$inst" "${opt[@]}"
  else
    rm -f "$tmpfile" && return 0
  fi

  brewf-manage

}

brewf-outdated() {
  local tmpfile outdated_list inst opt header

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmpfile)
  opt=("upgrade" "uninstall" "rollback" "options" "homepage" "info" "deps" "edit" "cat")

  if [ ! -e "$tmpfile" ]; then
    brew update

    # NOTE time consuming is as much as below
    outdated_list=$(
      brew outdated --greedy --verbose \
        | grep -Fv "pinned at" \
        | perl -pe 's/, /|/g; tr/()//d' \
        | perl -ane 'printf "%s %s %s\n", $F[0], $F[1], $F[3]' \
        | _fzf_format outdated
    )

    # outdated_list=$(
    #   brew outdated --greedy --json=v2 \
    #     | jq -r '.[] | values[] | select(.pinned = false) | "\(.name) \(.installed_versions | if type=="array" then . | join("|") else . end) \(.current_version)"' \
    #     | _fzf_format outdated
    # )

    if [ -n "$outdated_list" ]; then
      touch "$tmpfile"
      inst=$(echo "$outdated_list" | _fzf_tmpfile_write)
    else
      echo "No updates within installed formulae or cask."
      return 0
    fi

  else

    if [ -s "$tmpfile" ]; then
      inst=$(_fzf_tmpfile_read)
    else
      echo "Upgrade finished."
      rm -f "$tmpfile" && return 0
    fi

  fi

  if [ -n "$inst" ]; then
    _brewf_switch "$inst" "${opt[@]}"
  else
    echo "Upgrade cancel."
    rm -f "$tmpfile" && return 0
  fi

  brewf-outdated
}

brewf-tap() {
  local tmpfile inst opt header

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmpfile)
  opt=("untap" "tap-info")

  if [ ! -e "$tmpfile" ]; then
    tap_list=$(brew tap)

    if [ -n "$tap_list" ]; then
      touch "$tmpfile"
      inst=$(echo "$tap_list" | _fzf_tmpfile_write)
    else
      echo "No taps used."
      return 0
    fi

  else

    if [ -s "$tmpfile" ]; then
      inst=$(_fzf_tmpfile_read)
    else
      echo "Tap finished."
      rm -f "$tmpfile" && return 0
    fi
  fi

  if [ -n "$inst" ]; then
    _brewf_switch "$inst" "${opt[@]}"
  else
    echo "Tap cancel."
    rm -f "$tmpfile" && return 0
  fi

  brewf-tap

}

brewf-pinned() {
  local tmpfile inst opt header

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmpfile)

  if [ ! -e "$tmpfile" ]; then
    pinned_list=$(brew ls --pinned --versions)

    if [ -n "$pinned_list" ]; then
      touch "$tmpfile"
      inst=$(echo "$pinned_list" | _fzf_format pinned | _fzf_tmpfile_write)
    else
      echo "No formulae is pinned."
      return 0
    fi

  else

    if [ -s "$tmpfile" ]; then
      inst=$(_fzf_tmpfile_read)
    else
      echo "No formulae is pinned."
      rm -f "$tmpfile" && return 0
    fi
  fi

  if [ -n "$inst" ]; then
    for f in $(echo "$inst"); do
      brew unpin "$f" && _fzf_tmpfile_shift "$f"
    done
  else
    echo "Unpin cancel."
    rm -f "$tmpfile" && return 0
  fi

  brewf-pinned

}

brewf() {
  local cmd header

  header=$(_fzf_header)
  cmd=("outdated" "search" "manage" "pinned" "tap")

  _fzf_command

}
