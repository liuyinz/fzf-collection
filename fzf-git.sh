#! /usr/bin/env bash

# GIT
# ------------------

# [G]it [A]dd [F]zf
gaf() {
  local inst
  inst=$(git ls-files -m -o --exclude-standard |
    eval "fzf ${FZF_DEFAULT_OPTS} --header='[git add:]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      git add "$prog"
    done
  fi
}

# [G]it [A]dd [P]atch [F]zf
gapf() {
  local inst
  inst=$(git ls-files -m -o --exclude-standard |
    eval "fzf ${FZF_DEFAULT_OPTS} --header='[git add: --patch]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      git add --patch "$prog"
    done
  fi
}

# [G]it r[E]store [F]zf
gef() {
  local inst
  inst=$(git ls-files -m --exclude-standard |
    eval "fzf ${FZF_DEFAULT_OPTS} --header='[git restore:]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      git restore "$prog"
    done
  fi
}

# [G]it r[E]store [S]taged [F]zf
#  HACK @https://www.javaer101.com/en/article/16751334.html
gesf() {
  local inst
  inst=$(git diff --name-only --cached |
    xargs -I '{}' realpath --relative-to=. \
      $(git rev-parse --show-toplevel)/'{}' |
    eval "fzf ${FZF_DEFAULT_OPTS} --header='[git restore: --staged]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      git restore --staged "$prog"
    done
  fi
}

# [G]it r[E]store [A]ll [F]zf
geaf() {
  local inst
  inst=$(git diff --name-only HEAD |
    xargs -I '{}' realpath --relative-to=. \
      $(git rev-parse --show-toplevel)/'{}' |
    eval "fzf ${FZF_DEFAULTOPTS} --header='[git restore: --staged --worktree]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      git restore --staged --worktree "$prog"
    done
  fi
}

# [G]it [S]ub[M]odule [R]emove
#  FIXME @https://stackoverflow.com/questions/12641469/list-submodules-in-a-git-repository#comment84215697_12641787
gsmr() {
  local inst
  inst=$(git config -z --file .gitmodules --get-regexp '\.path$' |
    sed -nz 's/^[^\n]*\n//p' | tr '\0' '\n' |
    eval "fzf ${FZF_DEFAULT_OPTS} --header='[git delete-submodule: --force]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      git delete-submodule --force "$prog"
    done
  fi
}

# TODO git submodule fzf
