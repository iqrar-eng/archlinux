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
pathadd "$HOME/.cargo/bin"

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
--layout=reverse
--walker-skip .git,node_modules,target
--bind 'alt-y:execute-silent(realpath -- {} | wl-copy)'
--bind 'alt-c:execute-silent(printf %s {+} | wl-copy)'
--bind 'shift-end:kill-line'
--bind 'alt-p:toggle-preview'
--bind 'ctrl-a:toggle-all'
--bind 'ctrl-f:preview-page-down'
--bind 'alt-7:preview-page-up'
--bind 'ctrl-home:first'
--bind 'ctrl-end:last'
--preview '
printf \"\\033_Ga=d,q=1\\033\\\\\"
if [ -d {} ]; then
    eza -aTL 2 --group-directories-first --color=always --icons=always {}
    exit 0
fi
tmp=/tmp/fzf_preview
name=\$(basename {})
place=\"\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES}@0x0\"
case \"\$name\" in
    *.pdf)
        pdftoppm -q -f 1 -l 1 -jpeg -jpegopt quality=60 -scale-to-x 1000 -scale-to-y -1 -singlefile {} \"\$tmp\" && \
        kitty icat --transfer-mode=memory --stdin=no --place=\"\$place\" \"\$tmp.jpg\"
        ;;
    *.doc|*.docx|*.xls|*.xlsx|*.ppt|*.pptx|*.odt|*.ods|*.odp)
        libreoffice --convert-to jpg --outdir /tmp {} >/dev/null 2>&1 && \
        mv \"/tmp/\${name%.*}.jpg\" \"\$tmp\" && \
        kitty icat --transfer-mode=memory --stdin=no --place=\"\$place\" \"\$tmp\"
        ;;
    *.djvu)
        ddjvu -format=ppm -page=1 -size 1000x-1 -aspect=yes {} \"\$tmp\" 2>/dev/null && \
        kitty icat --transfer-mode=memory --stdin=no --place=\"\$place\" \"\$tmp\"
        ;;
    *)
        case \$(file -b --mime-type {}) in
            image/vnd.djvu) bat -p {} --color=always 2>/dev/null ;;
            image/*) kitty icat --transfer-mode=memory --stdin=no --place=\"\$place\" {} ;;
            video/*)
                dur=\$(ffprobe -v quiet -select_streams v -show_entries format=duration -of csv=p=0 {})
                dur=\${dur%.*}
                ffmpeg -v quiet -hwaccel auto -threads 1 -an -sn -dn \
                    -ss \$(( \${dur:-0} * 5 / 100 )) -skip_frame nokey -i {} \
                    -vframes 1 -q:v 9 -vf scale=1000:-2 -f image2 -y \"\$tmp.jpg\" && \
                kitty icat --transfer-mode=memory --stdin=no --place=\"\$place\" \"\$tmp.jpg\"
                ;;
            *) bat -p {} --color=always 2>/dev/null ;;
        esac
        ;;
esac
'
"

eval "$(starship init bash)"
eval "$(zoxide init bash --cmd cd)"

[[ ! ${BLE_VERSION-} ]] || ble-attach
