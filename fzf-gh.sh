##!/usr/bin/env bash

ghf() {
  local tmpfile user header

  header=$(_fzf_header)
  tmpfile=$(_fzf_tmpfile)
  user=$(gh api user --jq '.login')

  if [ ! -e "$tmpfile" ]; then
    touch "$tmpfile"
    inst=$(
      gh api users/"$user"/repos --paginate --jq '.[].name' \
        | _fzf_tmpfile_write
    )
  else
    inst=$(_fzf_tmpfile_read)
  fi

  if [ -n "$inst" ]; then
    subcmd=$(echo "delete-repo\nbrowse" | _fzf_single)
    if [ -n "$subcmd" ]; then
      for f in $(echo "$inst"); do
        case $subcmd in
          delete-repo)
            gh "$subcmd" "$user/$f" && _fzf_tmpfile_shift "$f"
            ;;
          browse)
            gh browse --repo "$user/$f"
            ;;
          *) return 0 ;;
        esac
      done
    fi
  else
    rm -f "$tmpfile" && return 0
  fi

  ghf

}
