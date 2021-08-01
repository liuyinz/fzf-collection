#! /usr/bin/env bash

# GIT
# ------------------
# gsha - get git commit sha
gsha() {
  local commit

  commit=$(git log --pretty=oneline --abbrev-commit |
    eval "fzf $FZF_COLLECTION_OPTS --header='[commits: ]'" |
    sed "s/ .*//")

  echo "$commit"
}

# gck - checkout git commit
gck() {
  local commit
  commit=$(gsha)

  if [[ $commit ]]; then
    git checkout "$commit"
  fi
}

# gwf - checkout git branch/tag
gwf() {
  local tags
  local branches
  local target

  tags="$(
    git tag |
      awk '{print "\x1b[31;1mtag\x1b[m\t" $1}'
  )" || return

  branches="$(
    git branch --all |
      grep -v HEAD |
      sed 's/.* //' |
      sed 's#remotes/[^/]*/##' |
      sort -u |
      awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}'
  )" || return

  target="$(
    printf '%s\n%s' "$tags" "$branches" |
      fzf \
        --no-hscroll \
        --ansi \
        +m \
        -d '\t' \
        -n 2 \
        -q "$*"
  )" || return

  git checkout "$(echo "$target" | awk '{print $2}')"
}

# [G]it r[E]store [F]zf
gef() {
  local inst
  inst=$(git ls-files -m --exclude-standard |
    eval "fzf ${FZF_COLLECTION_OPTS} --header='[git restore:]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      git restore "$prog"
    done
  fi
}

# [G]it r[E]store [S]taged
# SEE https://www.javaer101.com/en/article/16751334.html
ges() {
  local inst
  inst=$(git diff --name-only --cached |
    xargs -I '{}' realpath --relative-to=. \
      "$(git rev-parse --show-toplevel)"/'{}' |
    eval "fzf ${FZF_COLLECTION_OPTS} --header='[git restore: --staged]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      git restore --staged "$prog"
    done
  fi
}

# [G]it r[E]store [A]ll
gea() {
  local inst
  inst=$(git diff --name-only HEAD |
    xargs -I '{}' realpath --relative-to=. \
      "$(git rev-parse --show-toplevel)"/'{}' |
    eval "fzf ${FZF_COLLECTIONOPTS} --header='[git restore: --staged --worktree]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      git restore --staged --worktree "$prog"
    done
  fi
}

# TODO git submodule fzf

# [G]it [S]ub[M]odule [I]nteractive
gsmi() {
  local module
  local subcmd

  # SEE https://stackoverflow.com/questions/12641469/list-submodules-in-a-git-repository#comment84215697_12641787
  module=$(
    git config -z --file \
      "$(git rev-parse --show-toplevel)"/.gitmodules --get-regexp '\.path$' |
      sed -nz 's/^[^\n]*\n//p' | tr '\0' '\n' |
      eval "fzf ${FZF_COLLECTION_OPTS} --header='[git submodule: ]'"
  )

  if [[ $module ]]; then
    # shellcheck disable=SC2028
    subcmd=$(echo "browse\ndelete\ninit\ndeinit\nupdate-init\nupdate-remote" |
      eval "fzf --header='[git submodule: subcmd]'")

    for i in $(echo "$module"); do
      prog="$(git rev-parse --show-toplevel)"/$i
      case $subcmd in
      browse)
        # SEE https://stackoverflow.com/a/786515/13194984
        (cd "$prog" && exec gh browse)
        ;;
      delete)
        git delete-submodule --force "$prog"
        ;;
      update-remote)
        echo "$i ..."
        git submodule update --remote "$prog"
        ;;
      update-init)
        echo "$i ..."
        git submodule update --init "$prog"
        ;;
      deinit)
        git submodule deinit --force "$prog"
        ;;
      init)
        git submodule init "$prog"
        ;;
      esac
    done
  fi
}

# [G]it [ST]ash [I]nteractive
gsti() {
  local inst
  inst=$(git stash list |
    eval "fzf $FZF_COLLECTION_OPTS --header='[git stash: pop]'" |
    awk 'BEGIN { FS = ":" } { print $1 }' | tac)

  if [[ $inst ]]; then
    local subcmd

    # shellcheck disable=SC2028
    subcmd=$(echo "pop\nbranch\ndrop\napply\nshow" |
      eval "fzf --header='[git stash: subcmd]'")

    if [ "$subcmd" = "branch" ]; then
      local name
      name=$(bash -c 'read -r -p "Branch name: "; echo $REPLY')
      git stash branch "$name" "$inst"
    elif [ "$subcmd" = "show" ]; then
      git stash show "$inst" --patch-with-stat
    else
      for prog in $(echo "$inst"); do
        git stash "$subcmd" "$prog"
      done
    fi
  fi
}

# [G]it [I]gnore-io [F]zf
gif() {
  local inst
  inst=$(git ignore-io -l | sed -e "s/[[:space:]]\+/\n/g" |
    eval "fzf ${FZF_COLLECTION_OPTS} --header='[git ignore-io:append]'")

  if [[ $inst ]]; then
    for prog in $(echo "$inst"); do
      git ignore-io --append "$prog"
    done
  fi
}
