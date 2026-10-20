function blerc/vim-mode-hook {
  ble-bind -m vi_nmap -f C-m accept-line
  ble-bind -m vi_xmap -f C-m accept-line
  ble-bind -m vi_imap -f C-m accept-line

  ble-bind -m vi_nmap -f C-c discard-line
  ble-bind -m vi_xmap -f C-c discard-line
  ble-bind -m vi_imap -f C-c discard-line

  ble-bind -m vi_imap -f S-RET newline
  ble-bind -m auto_complete -f S-RET newline
  ble-bind -m menu_complete -f S-RET newline

  ble-bind -m vi_imap -f C-f 'history-search forward:hide-status'
  ble-bind -m vi_imap -f C-s 'history-search backward:hide-status'
  ble-bind -m auto_complete -f C-f 'history-search forward:hide-status'
  ble-bind -m auto_complete -f C-s 'history-search backward:hide-status'
  ble-bind -m nsearch -f C-f nsearch/forward
  ble-bind -m nsearch -f C-s nsearch/backward

  ble-bind -m vi_nmap -f C-y redo
  ble-bind -m auto_complete -f C-a auto_complete/accept-line

  ble-bind -m vi_nmap -c 'SP s' 'source ~/.bashrc'
  ble-bind -m vi_nmap -c 'SP i' 'yay -Slq | fzf -q "$1" -m --preview "yay -Si {1}"| xargs -ro yay -S --needed --noconfirm'
  ble-bind -m vi_nmap -c 'SP r' 'yay -Qq | fzf -q "$1" -m --preview "yay -Qi {1}" | xargs -ro yay -Rns --noconfirm'
  ble-bind -m vi_nmap -c 'SP I' 'pacman -Slq | fzf -q "$1" -m --preview "pacman -Si {1}" | xargs -ro sudo pacman -S --needed --noconfirm'
  ble-bind -m vi_nmap -c 'SP R' 'pacman -Qq | fzf -q "$1" -m --preview "pacman -Qi {1}" | xargs -ro sudo pacman -Rns --noconfirm'

  ble-sabbrev -i '\n'='npm run dev'
  ble-sabbrev -i '\d'=' | wl-copy && hyprctl dispatch "hl.dsp.focus({ workspace = \"1\" })" && ~/.config/hypr/bin/paste'

  # ------------------------------------------------

  ble-import lib/vim-surround
  ble-import -d integration/fzf-completion
  ble-import -d integration/fzf-key-bindings
  bleopt complete_auto_menu=1
  stty time 0
  bind 'set keyseq-timeout 1'

  ble-bind -m vi_cmap --cursor 5
  ble-bind -m vi_imap --cursor 5
  ble-bind -m vi_nmap --cursor 2
}
blehook/eval-after-load keymap_vi blerc/vim-mode-hook
