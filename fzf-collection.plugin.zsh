#!/usr/bin/env zsh

for f in "${0:h:A}"/fzf-*.sh; do
  source $f
done
