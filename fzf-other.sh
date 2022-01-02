#! /usr/bin/env bash

# [F]ind [P]ath

fp() {
  local header

  header="Find Path"

  for i in $(echo ${PATH//:/ }); do

    if [ -d "$i" ]; then
      find "$i" -maxdepth 1 -executable -type f,l -printf "%f ${i/$HOME/~}\n"
    fi

  done \
    | awk '{printf "%s \x1b[33m%s\x1b[0m\n", $1, $2}' \
    | uniq \
    | column -t -s ' ' \
    | _fzf_single_header --tiebreak=index
}

# [F]ind [FP]ath

ffp() {
  local loc
  loc=$(
    echo "$FPATH" \
      | sed -e $'s/:/\\\n/g' \
      | _fzf_single --header "$(_headerf "Find Fpath")"
  )

  if [ -d "$loc" ]; then
    rg --files "$loc" \
      | rev \
      | cut -d"/" -f1 \
      | rev \
      | _fzf_single --header "$(_headerf "Find Fpath => ${loc}")" >/dev/null
    ffp
  fi
}
