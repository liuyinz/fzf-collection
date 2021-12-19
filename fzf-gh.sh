##!/usr/bin/env bash

ghf() {
  local tmpfile user head

  tmpfile=/tmp/ghf

  head=$(_headerf "Gh Fzf")

  if [ ! -e $tmpfile ]; then
    user=$(gh api user --jq '.login')
    touch $tmpfile
    inst=$(
      gh api users/"$user"/repos --paginate --jq '.[].name' \
        | tee $tmpfile \
        | _fzf_multi --header "$head"
    )
  else
    inst=$(cat <$tmpfile | _fzf_multi --header "$head")
  fi

  if [ -n "$inst" ]; then
    subcmd=$(echo "delete-repo\nbrowse" | _fzf_single --header "$head")
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
