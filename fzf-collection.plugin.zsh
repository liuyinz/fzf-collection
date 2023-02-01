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
  --tiebreak=begin,index
  --bind=change:first,btab:up+toggle,ctrl-n:down,ctrl-p:up
  --bind=ctrl-u:cancel,ctrl-l:jump,ctrl-t:toggle-all,ctrl-v:clear-selection"
fi

if [ -z "$FZF_COLLECTION_MODULES" ]; then
  FZF_COLLECTION_MODULES=(
    browser
    brew
    npm
    pip
    gem
    cargo
    proxy
    git
    gh
    other
  )
fi

source "${0:h:A}/base.sh"

for f in "${FZF_COLLECTION_MODULES[@]}"; do
  source "${0:h:A}/collections/fzf-${f}.sh"
done
