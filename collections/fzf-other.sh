#!/usr/bin/env bash

# [F]ind [P]ath

fp() {
  local header

  header="Find Path"

  for i in $(echo ${PATH//:/ }); do

    if [ -d "$i" ]; then
      find "$i" -maxdepth 1 -executable -type f,l -printf "%f ${i/$HOME/~}\n"
    fi

  done \
    | perl -lane 'printf "%s \x1b[33m%s\x1b[0m\n", $F[0], $F[1]' \
    | uniq \
    | column -t -s ' ' \
    | _fzf_single --tiebreak=index
}

# [F]ind [FP]ath

ffp() {
  local loc header
  header="Find Fpath"
  loc=$(
    echo "$FPATH" \
      | perl -pe 's/:/\n/g' \
      | _fzf_single
  )

  if [ -d "$loc" ]; then
    header="Find Fpath => ${loc}"
    rg --files "$loc" \
      | rev \
      | cut -d"/" -f1 \
      | rev \
      | _fzf_single >/dev/null
    ffp
  fi
}
