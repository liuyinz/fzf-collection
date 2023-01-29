#!/usr/bin/env bash

# https://docs.npmjs.com/cli/v8/using-npm/config#shorthands-and-other-cli-niceties

_npmf() {
  npm "$1" --quiet --no-fund --no-audit --global "${@:2}"
}

_npmf_list_outdated() {
  _npmf outdated --json \
    | jq -r 'to_entries[] | "\(.key) \(.value | .current) \(.value | .latest)"'
}

_npmf_list_installed() {
  _npmf list --json \
    | jq -r '.dependencies | to_entries[] | "\(.key) \(.value | .version)"'
}

_npmf_list_available() {
  all-the-package-names
}

_npmf_version_current() {
  _npmf list --depth 0 2>/dev/null \
    | perl -slne '/\Q$f\E@(.+)$/ && print "$1"' -- -f="$pkg"
}

_npmf_version_install() {
  echo "Install $pkg@$new"
  _npmf install "$pkg@$new" 2>/dev/null
}

_npmf_switch() {
  local subcmd

  subcmd=$(_fzf_subcmd)

  if [ -n "$subcmd" ]; then
    for f in $(echo "$inst"); do
      case $subcmd in
        update)
          echo "upgrade $f"
          _npmf update "$f" && _fzf_tmp_shift "$f"
          ;;
        uninstall)
          _npmf uninstall "$f" && _fzf_tmp_shift "$f"
          ;;
        install)
          _npmf install "$f"
          ;;
        rollback)
          _npmf_rollback "$f"
          ;;
        homepage)
          _fzf_homepage "$(npm view "$f" homepage)"
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

  _npmf_switch
}

_npmf_rollback() {
  local header pkg current install versions

  pkg=$1
  header=$(_fzf_header)
  current="_npmf_version_current"
  install="_npmf_version_install"
  versions=$(
    npm info "$pkg" versions --json 2>/dev/null \
      | jq -r 'reverse | .[]' 2>/dev/null
  )

  _fzf_rollback
}

npmf-manage() {
  local tmpfile inst header opt format installed switch

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmp_create)
  format="manage"
  installed="_npmf_list_installed"
  switch="_npmf_switch"
  opt=("uninstall" "rollback" "homepage" "deps" "info")

  _fzf_manage
}

npmf-outdated() {
  local inst header opt tmpfile format outdated switch

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmp_create)
  format="outdated"
  outdated="_npmf_list_outdated"
  switch="_npmf_switch"
  opt=("update" "uninstall" "rollback" "homepage" "deps" "info")

  _fzf_outdated
}

npmf-search() {
  local tmpfile inst opt header available switch fzf_extra

  # REQUIRE npm install -g all-the-package-names
  if ! _fzf_exist all-the-package-names; then
    echo 'Error! please run "npm i -g all-the-package-names" first!' && return 0
  fi

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmp_create)
  available="_npmf_list_available"
  switch="_npmf_switch"
  opt=("install" "rollback" "homepage" "deps" "info")
  fzf_extra="--tiebreak=begin,length,index"

  _fzf_search
}

# REQUIRE npm install -g nrm
npmf-registry() {
  local inst header format

  if ! _fzf_exist nrm; then
    echo 'Error! please run "npm i -g nrm" first!' && return 0
  else
    echo "Current: $(nrm current)"
  fi

  format="registry"
  header=$(_fzf_header)
  inst=$(nrm test | perl -pe's/..|^\s*$//' | _fzf_format | _fzf_read)

  if [ -n "$inst" ]; then
    nrm use "$inst"
  else
    echo "Registry switch cancel." && return 0
  fi

}

npmf() {
  local header opt

  header=$(_fzf_header)
  opt=("outdated" "search" "manage" "registry")

  _fzf_command
}
