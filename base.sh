#!/usr/bin/env bash

_fzf_opts=($(echo "${FZF_COLLECTION_OPTS}"))

## Add underline
__underline_string() {
  printf '%s\n' "$1"
  printf '%*s' ${#1} ' ' | perl -pe 's/ /▔/g'
}

## return brewf-* header
_headerf() {
  __underline_string "${1:-$header}"
}

_fzf_single() {
  fzf "${_fzf_opts[@]}" "$@"
}

_fzf_multi() {
  fzf "${_fzf_opts[@]}" --multi "$@"
}

_fzf_single_header() {
  fzf \
    "${_fzf_opts[@]}" \
    --header \
    "$(__underline_string "$header")" \
    "$@"
}

_fzf_multi_header() {
  fzf \
    "${_fzf_opts[@]}" \
    --multi \
    --header \
    "$(__underline_string "$header")" \
    "$@"
}

_fzf_temp_file() {
  echo "/tmp/${header// /-}.lock"
}
