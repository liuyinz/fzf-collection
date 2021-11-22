#!/usr/bin/env bash

## Uppercase every first letter and downcase other letter in every word in string.
capitalize-first() {
  sed -E 's/(\w)(\w*)/\U\1\L\2/g' <<<"$1"
}

## Add underline
underline_string() {
  printf '%s\n' "$1"
  printf '%*s' ${#1} ' ' | sed 's/ /▔/g'
}

## return brewf-* header
headerf() {
  underline_string "$(capitalize-first "${1:-${funcstack[2]//f-/ }}")"
}
