#!/usr/bin/env bash

# [F]ind [P]ath
# option -d return executable path

fp() {
  local header format rule
  header="Find Path"
  format="general"

  if [[ "$1" == "-d" ]]; then
    rule='printf "%s/", glob($F[$#F])'
  else
    rule='printf "%s/%s", glob($F[$#F]), $F[0]'
  fi

  for i in $(echo ${PATH//:/ }); do
    if [ -d "$i" ]; then
      # option -H to allow symblic root_path to parse normally
      # SEE https://www.gnu.org/software/findutils/manual/html_node/find_html/Symbolic-Links.html
      find -H "$i" -maxdepth 1 -executable -type f,l -printf "%f ${i/$HOME/~}\n"
    fi
  done \
    | _fzf_format \
    | uniq \
    | fzf "${_fzf_opts[@]}" --header "$(_fzf_underline "$header")" --tiebreak=index \
    | perl -lane "$rule"
}

# [F]ind [FP]ath

ffp() {
  local loc header
  header="Find Fpath"
  loc=$(
    echo "$FPATH" \
      | perl -pe 's/:/\n/g' \
      | _fzf_read
  )

  if [ -d "$loc" ]; then
    header="Find Fpath => ${loc}"
    rg --files "$loc" \
      | rev \
      | cut -d"/" -f1 \
      | rev \
      | _fzf_read >/dev/null
    ffp
  fi
}
