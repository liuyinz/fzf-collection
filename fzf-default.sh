#! /usr/bin/env bash

# PATH
# ------------------

# [F]ind [P]ath
# list directories in $PATH,press [enter] on an entry to list,press [escape] to go back,[escape] twice to exit completely

fp() {
  local loc
  loc=$(echo "$PATH" | sed -e $'s/:/\\\n/g' |
    eval "fzf ${FZF_COLLECTION_OPTS} --header='[find:path]'")

  if [[ -d $loc ]]; then
    rg --files "$loc" | rev | cut -d"/" -f1 | rev |
      eval "fzf ${FZF_COLLECTION_OPTS} --header='[find:exe] => ${loc}' >/dev/null"
    fp
  fi
}

# [F]ind [FP]ath
# list directories in $FPATH,press [enter] on an entry to list,press [escape] to go back,[escape] twice to exit completely
ffp() {
  local loc
  loc=$(echo "$FPATH" | sed -e $'s/:/\\\n/g' |
    eval "fzf ${FZF_COLLECTION_OPTS} --header='[find:path]'")

  if [[ -d $loc ]]; then
    rg --files "$loc" | rev | cut -d"/" -f1 | rev | eval \
      "fzf ${FZF_COLLECTION_OPTS} --header='[find:exe] => ${loc}' \
      >/dev/null"
    fp
  fi
}

# PROCESS
# ------------------
# mnemonic: [K]ill [P]rocess
# show output of "ps -ef", use [ab] to select one or multiple entries
# press [enter] to kill selected processes and go back to the process list.
# or press [escape] to go back to the process list. Press [escape] twice to exit completely.

kp() {
  local pid
  pid=$(ps -ef | sed 1d |
    eval "fzf ${FZF_COLLECTION_OPTS} --header='[kill:process]'" |
    awk '{print $2}')

  if [ "x$pid" != "x" ]; then
    echo "$pid" | xargs kill -"${1:-9}"
    kp "$@"
  fi
}
