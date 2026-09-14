# Reset PATH in tmux to break inheritance chain, causing duplicate 'echo $PATH' entries
if [ -n "$TMUX" ]; then
  export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
fi

[[ $- == *i* ]] && source -- /usr/share/blesh/ble.sh --attach=none

# Helper to add to PATH only if not already present
pathadd() {
  [[ ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"
}
pathadd "$HOME/bin"
pathadd "$HOME/.local/bin"
pathadd "$HOME/.npm-global/bin"
pathadd "$HOME/go/bin"
pathadd "$HOME/.local/share/nvim/mason/bin"

# NVM — only once
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

HISTSIZE=10000
shopt -s histappend
shopt -s autocd
shopt -s dotglob
shopt -s cdspell

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

set -o vi

if [ -f /usr/share/bash-completion/bash_completion ]; then
  source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

alias ls='ls --hyperlink=always --color=always -A --group-directories-first'

source <(fzf --bash)

export FZF_DEFAULT_OPTS="
--height 100%
--history=$HOME/.fzf_history
--filepath-word
--border none
--no-separator
--ansi
--info inline-right
--multi
--cycle
--scrollbar='█'
--layout=reverse
--walker-skip .git,node_modules,target
--bind 'ctrl-d:execute-silent(realpath -- {} | wl-copy)'
--bind 'ctrl-k:execute-silent(realpath -- {} | sed \"s|^$HOME|~|\" | wl-copy)'
--bind 'ctrl-]:execute-silent(printf %s {+} | wl-copy)'
--bind 'alt-x:forward-word'
--bind 'alt-e:backward-word'
--bind 'ctrl-alt-shift-left:forward-subword'
--bind 'alt-g:backward-subword'
--bind 'ctrl-alt-shift-up:kill-word'
--bind 'ctrl-y:backward-kill-word'
--bind 'ctrl-alt-e:kill-subword'
--bind 'ctrl-alt-h:backward-kill-subword'
--bind 'shift-end:kill-line'
--bind 'alt-p:toggle-preview'
--bind 'ctrl-a:toggle-all'
--bind 'alt-2:preview-page-down'
--bind 'alt-3:preview-page-up'
--bind 'alt-7:preview-top'
--bind 'alt-6:preview-bottom'
--bind 'ctrl-home:first'
--bind 'ctrl-end:last'
--bind 'ctrl-up:prev-history'
--bind 'ctrl-down:next-history'
--bind 'ctrl-alt-shift-home:execute(/home/iqrar/archlinux/.config/tmux/bin/vim-fzf-focus {})'
--bind 'focus:transform-preview-label:echo {}'
--color 'hl:-1:underline,hl+:-1:underline:reverse' \
--preview-window 'top:70%:noborder'
--bind 'ctrl-p:change-preview-window(right:border-left|up:noborder)+refresh-preview'
--preview '
    printf \"\033_Ga=d,q=1\033\\\\\"
    if [ -d {} ]; then
        ls --color=always -A --group-directories-first {}
    else
        tmp=\"/tmp/fzf_preview\"
        case \$(basename {}) in
            *.pdf)
                pdftoppm -q -f 1 -l 1 -jpeg -jpegopt quality=60 -scale-to-x 1000 -scale-to-y -1 -singlefile {} \$tmp && \\
                kitty icat --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 \$tmp.jpg
                ;;
            *)
                if file --mime-type {} | grep -qP \"image/(?!vnd\\.djvu)\"; then
                    kitty icat --transfer-mode=memory --stdin=no --place=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0 {}
                else
                  cat -n -- {} 2>/dev/null
                fi
                ;;
        esac
    fi
'
"

export FZF_CTRL_R_OPTS="--no-preview"

eval "$(starship init bash)"
eval "$(zoxide init bash --cmd cd)"

[[ ! ${BLE_VERSION-} ]] || ble-attach
