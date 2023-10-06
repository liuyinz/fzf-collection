_pnpmf() {
  pnpm "$1" --global "${@:2}"
}

_pnpmf_list_outdated() {
  _pnpmf outdated --json \
    | jq -r 'to_entries[] | "\(.key) \(.value | .current) \(.value | .latest)"'
}

_pnpmf_list_installed() {
  _pnpmf list --json \
    | jq -r '.[].dependencies | values[] | "\(.from) \(.version)"'
}

_pnpmf_list_available() {
  all-the-package-names
}

_pnpmf_version_current() {
  _pnpmf list --json "$pkg" 2>/dev/null \
    | jq -r '.[].dependencies | values[].version'
}

_pnpmf_version_install() {
  echo "Install $pkg@$new"
  _pnpmf add "$pkg@$new" 2>/dev/null
}

_pnpmf_switch() {
  local subcmd

  subcmd=$(_fzf_subcmd)

  if [ -n "$subcmd" ]; then
    for f in $(echo "$inst"); do
      case $subcmd in
        update)
          echo "upgrade $f"
          _pnpmf update "$f" && _fzf_tmp_shift "$f"
          ;;
        remove)
          _pnpmf remove "$f" && _fzf_tmp_shift "$f"
          ;;
        add)
          _pnpmf add "$f"
          ;;
        rollback)
          _pnpmf_rollback "$f"
          ;;
        homepage)
          _fzf_homepage "$(pnpm view "$f" homepage)"
          ;;
        deps)
          pnpm view "$f" dependencies
          ;;
        info)
          pnpm view "$f"
          ;;
        *) pnpm "$subcmd" "$f" ;;
      esac
      echo ""
    done

    case $subcmd in
      update | remove | rollback) return 0 ;;
    esac

  else
    return 0
  fi

  _pnpmf_switch
}

_pnpmf_rollback() {
  local header pkg current install versions

  pkg=$1
  header=$(_fzf_header)
  current="_pnpmf_version_current"
  install="_pnpmf_version_install"
  versions=$(
    pnpm info "$pkg" versions --json 2>/dev/null \
      | jq -r 'reverse | .[]' 2>/dev/null
  )

  _fzf_rollback
}

pnpmf-manage() {
  local tmpfile inst header opt format installed switch

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmp_create)
  format="manage"
  installed="_pnpmf_list_installed"
  switch="_pnpmf_switch"
  opt=("remove" "rollback" "homepage" "deps" "info")

  _fzf_manage
}

pnpmf-outdated() {
  local inst header opt tmpfile format outdated switch

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmp_create)
  format="outdated"
  outdated="_pnpmf_list_outdated"
  switch="_pnpmf_switch"
  opt=("update" "remove" "rollback" "homepage" "deps" "info")

  _fzf_outdated
}

pnpmf-search() {
  local tmpfile inst opt header available switch fzf_extra

  # REQUIRE npm install -g all-the-package-names
  if ! _fzf_exist all-the-package-names; then
    echo 'Error! please run "pnpm add -g all-the-package-names" first!' && return 0
  fi

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmp_create)
  available="_pnpmf_list_available"
  switch="_pnpmf_switch"
  opt=("add" "rollback" "homepage" "deps" "info")
  fzf_extra="--tiebreak=begin,length,index"

  _fzf_search
}

# REQUIRE npm install -g nnrm
pnpmf-registry() {
  local inst header format

  if ! _fzf_exist prm; then
    echo 'Error! please run "pnpm add -g nnrm" first!' && return 0
  else
    echo "Current: $(prm ls | perl -slne '/\* (.+) -+ https.*$/ && print $1')"
  fi

  format="registry"
  header=$(_fzf_header)
  inst=$(timeout 3 prm test \
    | perl -pe 's/-+//; s/^\s+|\s+$//' \
    | _fzf_format \
    | _fzf_read)

  if [ -n "$inst" ]; then
    prm use "$inst"
  else
    echo "Registry switch cancel." && return 0
  fi

}

pnpmf() {
  local header opt

  header=$(_fzf_header)
  opt=("outdated" "search" "manage" "registry")

  _fzf_command
}
