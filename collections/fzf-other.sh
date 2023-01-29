#!/usr/bin/env bash

# [F]ind [P]ath

# TODO add -d to echo dirpath, or full-filepath
fp() {
  local header format
  header="Find Path"
  format="general"

  for i in $(echo ${PATH//:/ }); do
    if [ -d "$i" ]; then
      find "$i" -maxdepth 1 -executable -type f,l -printf "%f ${i/$HOME/~}\n"
    fi
  done \
    | _fzf_format \
    | uniq \
    | _fzf_read --tiebreak=index
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
