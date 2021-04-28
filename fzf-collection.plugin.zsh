#!/usr/bin/env zsh

source "${0:h:A}/fzf-default.sh"
command -v brew >/dev/null && source "${0:h:A}/fzf-brew.sh"
command -v pip3 >/dev/null && source "${0:h:A}/fzf-pip.sh"
