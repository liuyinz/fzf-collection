##!/usr/bin/env bash

ghf() {
  local tmpfile user header

  header="Gh Fzf"
  tmpfile=$(_fzf_temp_file)
  user=$(gh api user --jq '.login')

  if [ ! -e $tmpfile ]; then
    touch $tmpfile
    inst=$(
      gh api users/"$user"/repos --paginate --jq '.[].name' \
        | tee $tmpfile \
        | _fzf_multi_header
    )
  else
    inst=$(cat <$tmpfile | _fzf_multi_header)
  fi

  if [ -n "$inst" ]; then
    subcmd=$(echo "delete-repo\nbrowse" | _fzf_single_header)
    if [ -n "$subcmd" ]; then
      for f in $(echo "$inst"); do
        case $subcmd in
          delete-repo)
            gh "$subcmd" "$user/$f"
            perl -i -slne '/$f/||print' -- -f="$f" "$tmpfile"
            ;;
          browse)
            gh browse --repo "$user/$f"
            ;;
          *) return 0 ;;
        esac
      done
    fi
  else
    rm -f $tmpfile && return 0
  fi

  ghf

}
