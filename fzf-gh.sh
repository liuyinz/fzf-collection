##!/usr/bin/env sh

ghf() {
  local tmpfile user head

  tmpfile=/tmp/ghf

  head=$(headerf "Gh Fzf")

  if [ ! -e $tmpfile ]; then
    user=$(gh api user --jq '.login')
    touch $tmpfile
    inst=$(
      gh api users/"$user"/repos --paginate --jq '.[].name' \
        | tee $tmpfile \
        | fzf "${fzf_opts[@]}" --header "$head"
    )
  else
    inst=$(cat <$tmpfile | fzf "${fzf_opts[@]}" --header "$head")
  fi

  if [ -n "$inst" ]; then
    subcmd=$(echo "delete-repo\nbrowse" | fzf "${fzf_opts[@]}" --header "$head")
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
