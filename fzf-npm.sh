#!/usr/bin/env bash

_npmf_format() {
  local input rule

  input="$([[ -p /dev/stdin ]] && cat - || return)"

  case $1 in
    manage | registry)
      rule='printf "%s \x1b[34m%s\x1b[0m\n", $F[0], $F[$#F]'
      ;;
    outdated)
      rule='printf "%s \x1b[34m%s\x1b[0m => \x1b[33m%s\x1b[0m\n", $F[0], $F[1], $F[2]'
      ;;
    *) echo "Argument error: No such $1" && return 0 ;;
  esac

  [ -n "$input" ] && echo "$input" | perl -sane "$rule" | column -s ' ' -t
}

_npmf_switch() {

  subcmd=$(echo "${@:2}" | perl -pe 's/ /\n/g' | _fzf_single)

  if [ -n "$subcmd" ]; then
    for f in $(echo "$1"); do
      case $subcmd in
        update)
          if npm update --global "$f"; then
            perl -i -slne '/$f/||print' -- -f="$f" "$tmpfile"
          fi
          ;;
        uninstall)
          if npm uninstall --global "$f"; then
            perl -i -slne '/$f/||print' -- -f="$f" "$tmpfile"
          fi
          ;;
        install)
          npm install --global "$f"
          ;;
        rollback)
          _npmf_rollback "$f"
          ;;
        homepage)
          open "$(npm view "$f" homepage)"
          ;;
        deps)
          npm view "$f" dependencies
          ;;
        info)
          npm view "$f"
          ;;
        *) npm "$subcmd" "$f" ;;
      esac
      echo ""
    done

    case $subcmd in
      update | uninstall | rollback) return 0 ;;
    esac

  else
    return 0
  fi

  _npmf_switch "$@"

}

_npmf_rollback() {
  local version_list version header

  header=$(_fzf_header)
  version_list=$(npm info "$1" versions --json 2>/dev/null | jq -r 'reverse | .[]')

  if [ -n "$version_list" ]; then

    version=$(echo "$version_list" | _fzf_single)

    if [ -n "$version" ]; then
      npm install --global "$1@$version" 2>/dev/null
    else
      echo "Rollback cancel." && return 0
    fi

  else
    echo "No version provided for package $1." && return 0
  fi

}

npmf-manage() {
  local tmpfile inst header opt

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmpfile)
  opt=("uninstall" "rollback" "homepage" "deps" "info")

  if [ ! -e "$tmpfile" ]; then
    touch "$tmpfile"

    inst=$(
      npm list --json --global \
        | jq -r '.dependencies | to_entries[] | "\(.key) \(.value | .version)"' \
        | _npmf_format manage \
        | _fzf_tmpfile_write
    )

  else
    inst=$(_fzf_tmpfile_read)
  fi

  if [ -n "$inst" ]; then
    _npmf_switch "$inst" "${opt[@]}"
  else
    rm -f "$tmpfile" && return 0
  fi

  npmf-manage

}

npmf-outdated() {
  local tmpfile inst header opt

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmpfile)
  opt=("update" "uninstall" "rollback" "homepage" "deps" "info")

  if [ ! -e "$tmpfile" ]; then
    outdate_list=$(
      npm outdated --global --json \
        | jq -r 'to_entries[] | "\(.key) \(.value | .current) \(.value | .latest)"' \
        | _npmf_format outdated
    )

    if [ -n "$outdate_list" ]; then
      touch "$tmpfile"
      inst=$(echo "$outdate_list" | _fzf_tmpfile_write)
    else
      echo "No updates in npm packages."
      return 0
    fi

  else

    if [ -s "$tmpfile" ]; then
      inst=$(_fzf_tmpfile_read)
    else
      echo "Update finished."
      rm -f "$tmpfile" && return 0
    fi

  fi

  if [ -n "$inst" ]; then
    _npmf_switch "$inst" "${opt[@]}"
  else
    echo "Update cancel."
    rm -f "$tmpfile" && return 0
  fi

  npmf-outdated

}

# npm install -g all-the-package-names
npmf-search() {
  local tmpfile inst opt header

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmpfile)
  opt=("install" "homepage" "deps" "info")

  if ! command -v all-the-package-names &>/dev/null; then
    echo 'Error! please run "npm i -g all-the-package-names" first!' && return 0
  fi

  if [ ! -e "$tmpfile" ]; then
    touch "$tmpfile"
    inst=$(all-the-package-names | _fzf_tmpfile_write --tiebreak=begin,length)
  else
    inst=$(_fzf_tmpfile_read --tiebreak=begin,length)
  fi

  if [ -n "$inst" ]; then
    _npmf_switch "$inst" "${opt[@]}"
  else
    rm -f "$tmpfile" && return 0
  fi

  npmf-search

}

npmf-registry() {
  local inst header

  header=$(_fzf_header)

  if ! command -v nrm &>/dev/null; then
    echo 'Error! please run "npm i -g nrm" first!' && return 0
  else
    echo "Current: $(nrm current)"
  fi

  # inst=$(nrm test | perl -pe's/..//' | _npmf_format registry | _fzf_single)
  inst=$(nrm ls | tail -n +2 | _npmf_format registry | _fzf_single)

  if [ -n "$inst" ]; then
    nrm use "$inst"
  else
    echo "Registry switch cancel." && return 0
  fi

}

npmf() {
  local cmd header

  header=$(_fzf_header)
  cmd=("outdated" "search" "manage" "registry")

  _fzf_command

}
