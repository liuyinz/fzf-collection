#!/usr/bin/env bash

_pipf_list() {
  pip list --not-required --disable-pip-version-check --format=json "$@"
}

_pipf_extract() {
  pip show "$1" | perl -sne '/^\Q$f\E: (.+)$/ && print "$1"' -- -f="$2"
}

_pipf_switch() {

  subcmd=$(echo "${@:2}" | perl -pe 's/ /\n/g' | _fzf_single)

  if [ -n "$subcmd" ]; then

    # check pip version every time before upgrade
    [ "$subcmd" = "upgrade" ] && pip install --user --upgrade pip

    for f in $(echo "$1"); do
      case $subcmd in
        upgrade)
          pip install --user --upgrade "$f" && _fzf_tmpfile_shift "$f"
          ;;
        uninstall)
          _pip_uninstall "$f" && _fzf_tmpfile_shift "$f"
          ;;
        install)
          pip install --user "$f"
          ;;
        rollback)
          _pipf_rollback "$f"
          ;;
        homepage)
          url="$(_pipf_extract "$f" Home-page)"
          [ -n "$url" ] && open "$url" || echo "No homepage."
          ;;
        deps)
          _pipf_extract "$f" Requires
          ;;
        use)
          _pipf_extract "$f" Required-by
          ;;
        info)
          pip show "$f"
          ;;
        *) pip "$subcmd" "$f" ;;
      esac
      echo ""
    done

    case $subcmd in
      upgrade | uninstall | rollback) return 0 ;;
    esac

  else
    return 0
  fi

  _pipf_switch "$@"

}

_pipf_uninstall() {
  if _fzf_exist pip-autoremove; then
    # REQUIRE pip install pip-autoremove
    pip-autoremove "$@" --yes
  else
    pip uninstall --yes "$@"
  fi

}

_pipf_rollback() {
  local header versions current new

  header=$(_fzf_header)
  versions=$(
    pip index versions --pre "$1" 2>/dev/null \
      | perl -lne '/Available versions: (.*)$/m && print $1' \
      | perl -pe 's/, /\n/g'
  )

  if [ -n "$versions" ]; then
    current=$(_pipf_extract "$f" Version)
    echo "Current version: $current"
    new=$(echo "$versions" | _fzf_single)

    if [ -n "$new" ]; then
      _fzf_version_check
      pip install --upgrade --force-reinstall "$f==$new" 2>/dev/null
    else
      echo "Rollback cancel." && return 0
    fi

  else
    echo "No version provided for package $1." && return 0
  fi
}

pipf-manage() {
  local tmpfile inst header opt

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmpfile)
  opt=("uninstall" "rollback" "homepage" "deps" "use" "info")

  if [ ! -e "$tmpfile" ]; then
    touch "$tmpfile"

    # SEE https://unix.stackexchange.com/a/615709
    inst=$(
      echo "pip $(_pipf_extract pip Version)" \
        | cat - <(_pipf_list | jq -r '.[] | "\(.name) \(.version)"') \
        | _fzf_format manage \
        | _fzf_tmpfile_write
    )

  else
    inst=$(_fzf_tmpfile_read)
  fi

  if [ -n "$inst" ]; then
    _pipf_switch "$inst" "${opt[@]}"
  else
    rm -f "$tmpfile" && return 0
  fi

  pipf-manage

}

pipf-search() {
  local tmpfile inst opt header

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmpfile)

  opt=("install" "uninstall" "rollback")

  if [ ! -e "$tmpfile" ]; then
    touch "$tmpfile"

    inst=$(
      curl -s "$(pip config get global.index-url)/" \
        | perl -lne '/">(.*?)<\/a>/ && print $1' \
        | _fzf_tmpfile_write
    )

  else
    inst=$(_fzf_tmpfile_read)
  fi

  if [ -n "$inst" ]; then
    _pipf_switch "$inst" "${opt[@]}"
  else
    rm -f "$tmpfile" && return 0
  fi

  pipf-search

}

pipf-outdated() {
  local inst header opt tmpfile

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmpfile)
  opt=("upgrade" "uninstall" "rollback" "deps" "use" "info")

  if [ ! -e "$tmpfile" ]; then

    outdated_list=$(
      _pipf_list --outdated \
        | jq -r '.[] | "\(.name) \(.version) \(.latest_version)"' \
        | _fzf_format outdated
    )

    if [ -n "$outdated_list" ]; then
      touch "$tmpfile"
      inst=$(echo "$outdated_list" | _fzf_tmpfile_write)
    else
      echo "No updates in pip packages."
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
    _pipf_switch "$inst" "${opt[@]}"
  else
    echo "Upgrade cancel."
    rm -f "$tmpfile" && return 0
  fi

  pipf-outdated
}

pipf() {
  local cmd header

  header=$(_fzf_header)
  cmd=("outdated" "search" "manage")

  _fzf_command
}
