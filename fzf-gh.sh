##!/usr/bin/env bash

ghf() {
  local tmpfile user header

  header="Gh Fzf"
  tmpfile=/tmp/ghf

  if [ ! -e $tmpfile ]; then
    user=$(gh api user --jq '.login')
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
            sed -i "/^$(sed 's/\//\\&/g' <<<"$f")$/d" "$tmpfile"
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
