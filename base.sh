##!/usr/bin/env sh

headerf() {
  printf '%s\n' $1
  printf '%*s' ${#1} | sed 's/ /▔/g'
}
