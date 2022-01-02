# set options if not defined
if [ -z "$FZF_COLLECTION_OPTS" ]; then
  FZF_COLLECTION_OPTS="
  --header-first
  --ansi
  --reverse
  --cycle
  --no-multi
  --sort
  --exact
  --info=inline
  --bind=change:first,btab:up+toggle,ctrl-n:down,ctrl-p:up
  --bind=ctrl-u:cancel,ctrl-l:jump,ctrl-t:toggle-all,ctrl-v:clear-selection"
fi

fzf_opts=($(echo "${FZF_COLLECTION_OPTS}"))

if [ -z "$FZF_COLLECTION_MODULES" ]; then
  FZF_COLLECTION_MODULES=(
    browser
    brew
    pip
    git
    gh
    other
  )
fi

source "${0:h:A}/base.sh"

for f in "${FZF_COLLECTION_MODULES[@]}"; do
  source "${0:h:A}/fzf-${f}.sh"
done
