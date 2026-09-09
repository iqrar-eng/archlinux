# archlinux

> This is my personal Arch Linux development environment. It is opinionated
> and primarily intended for reference. Use individual configurations or the
> installation scripts as needed.

Dotfiles, package lists, and install/backup scripts for a Hyprland +
tmux + Neovim development setup on Arch Linux. Every piece here exists
because it closed a specific gap in a previous setup — nothing is here
by default or by convention. The sections below explain *why* each
component was chosen over the obvious alternative, not just what it does.

## Contents

- [Overview](#overview)
- [Layout](#layout)
- [Installation](#installation)
- [Backup / sync](#backup--sync)
- [Component breakdown](#component-breakdown)
  - [keyd — system-level key remapping](#keyd--system-level-key-remapping)
  - [Hyprland (Lua config)](#hyprland-lua-config)
  - [tmux + oh-my-tmux](#tmux--oh-my-tmux)
  - [Kitty](#kitty)
  - [Neovim / LazyVim](#neovim--lazyvim)
  - [CopyQ](#copyq)
  - [Yazi](#yazi)
  - [ble.sh](#blesh)
  - [xdg-desktop-portal-termfilechooser](#xdg-desktop-portal-termfilechooser)
  - [systemd user units](#systemd-user-units)
  - [Theme sync](#theme-sync)
- [Why local instead of upstream](#why-local-instead-of-upstream)
- [Comparisons](#comparisons)
- [Package lists](#package-lists)
- [Disclaimer](#disclaimer)

## Overview

The setup is built around one idea: **every app should be reachable and
scriptable from every other app.** Concretely:

- Neovim, tmux, Kitty, Hyprland, and CopyQ all talk to each other through
  small shell scripts rather than through one monolithic "rice" config.
- The clipboard (via CopyQ) is treated as a first-class routing layer —
  not just copy/paste, but a numbered slot store that can be selected,
  jumped to, and pasted into a specific app from anywhere.
- Nothing waits for a GUI when a keyboard shortcut or a script can do it
  faster — file pickers, WiFi connection, theme switching, and clipboard
  history are all terminal-first.

## Layout

```
.
├── .bash_profile, .bashrc, .blerc      # shell + ble.sh (fish-like line editor for bash)
├── .gitconfig
├── .config/
│   ├── copyq/                          # clipboard manager: commands, themes
│   ├── dunst/                          # notification daemon
│   ├── fd/                             # ignore rules for `fd`
│   ├── hypr/                           # Hyprland, in Lua (hyprland.lua, bind.lua)
│   ├── kitty/                          # terminal emulator + light/dark themes
│   ├── nvim/                           # Neovim entrypoint + vendored LazyVim (see below)
│   ├── systemd/user/                   # battery check + periodic full-system sync timers
│   ├── tmux/                           # tmux.conf (oh-my-tmux) + helper scripts
│   ├── xdg-desktop-portal*/            # terminal (yazi) file picker instead of GTK
│   ├── yazi/                           # terminal file manager, flavors + plugins
│   └── mimeapps.list, starship.toml
├── .local/bin/                         # cross-app glue scripts (clipboard, sync, power)
├── etc/keyd/default.conf               # system-wide key remap layer
├── pacman.packages / yay.packages      # full package manifest (official + AUR)
└── symlinks                            # every path this repo manages, one per line
```

## Installation

This is **not** a one-shot installer for a stranger's machine — it assumes
the Lenovo/AMD hardware, the `iqrar` username, and the French AZERTY layout
this was built for. Read `.local/bin/sys/restore` before running any of it.
At a high level, it:

1. Installs `yay` from the AUR (bootstraps itself, since nothing else here
   is installed yet).
2. Installs every package in `pacman.packages` and `yay.packages` straight
   from the raw GitHub URLs, so a fresh machine doesn't even need this repo
   cloned first.
3. Clones this repo to `~/archlinux` and symlinks every path listed in
   `symlinks` from `$HOME` into it — that file is *generated*, not
   hand-maintained (see [Backup / sync](#backup--sync)).
4. Symlinks `etc/keyd/default.conf` into `/etc/keyd/`.
5. Sets a TLP battery charge threshold and configures autologin on tty1.
6. Sparse-checks out the *documentation subtrees only* (not the whole repo)
   of Prisma, better-auth, Next.js, Node, MDN, and React into `~/.src` —
   a local, offline, greppable doc cache for the exact stack in
   [Iqrar's `widgethub` work](#) (Next.js, Prisma, Postgres).

## Backup / sync

`.local/bin/sys/sync` is the inverse of the installer, and it's the part
that keeps this repo honest: instead of hand-editing `symlinks` or the
package lists, the script **derives them from the live system** —

- it walks `$HOME`, `$HOME/.config`, and the desktop-entry directory for
  every symlink actually present and writes that list out fresh;
- it regenerates `pacman.packages` / `yay.packages` from
  `pacman -Qqen` / `pacman -Qqem` (explicitly installed, native vs AUR);
- it fast-forwards every git repo under `~/.src` to its remote HEAD.

A `sync-system.timer` systemd unit runs this automatically. The effect is
that the repo can't silently drift from the machine — every sync either
matches reality or the next `git diff` shows exactly what changed.

## Component breakdown

### keyd — system-level key remapping

**Why keyd and not a Hyprland-level or X11-level remap:** keyd operates at
the `evdev`/kernel input layer, below any compositor, display server, or
desktop environment. That has one concrete consequence this setup relies
on: the remap is identical in Hyprland, in a TTY, in a VM, and in GRUB —
anywhere the physical keyboard is read at all. A remap done inside
Hyprland's own config only fires once Hyprland is running and only inside
Hyprland; a remap done via `xmodmap`/X11 only works under X. keyd doesn't
care what's rendering on screen, which is exactly the property needed for
a full-layout remap this deep (`etc/keyd/default.conf` defines a
Colemak-DH-style base layer plus `control`, `alt`, `shift`, `meta`, and
several custom layers with macros for punctuation pairs, app switching,
and window management shortcuts).

### Hyprland (Lua config)

Configured via `hyprland.lua` + `bind.lua` using Hyprland's Lua
configuration support, not the traditional `hyprland.conf` keyword syntax.
This buys real control flow and functions — `bind.lua` defines a
`paste_slot(n)` helper that both selects a CopyQ slot *and* dispatches a
paste, reused across three separate keybinds instead of duplicating the
two-step shell command three times. Workspace rules pin Firefox, the tmux
terminal, CopyQ, and Yazi to fixed workspace numbers, so muscle-memory
`SUPER + [1-5]` always lands on the same app regardless of launch order.
Gaps, rounding, shadows, blur, and animations are all off — this is a
performance-first, decoration-off layout, not a "rice."

### tmux + oh-my-tmux

Built on the [oh-my-tmux](https://github.com/gpakosz/.tmux) framework for
the status bar/theme layer, with a large custom command table under
prefix `y` (`my-table`) and a set of helper scripts in `.config/tmux/bin/`:

- `capture-context` / `capture-prompt` — dump the current pane (or just the
  last shell prompt's output, parsed with `awk` against the `❯` prompt
  character) to a temp file, copy a file-URI into the clipboard via CopyQ,
  and jump to workspace 1 to paste it — built for pasting terminal output
  or AI context into a chat window with one keystroke.
- `vim-fzf-focus` — finds a running Neovim's RPC socket under
  `/run/user/$UID/nvim.*` and sends it an `:e` command remotely, so an
  fzf result opens in the *already-running* Neovim instead of spawning a
  second one.
- `reload-kitty` — saves tmux-resurrect state, kills the tmux server, and
  relaunches Kitty with a fresh attach, for when the terminal itself needs
  a reload without losing session state.
- `tmux-continuum` autosave is enabled with the status bar hidden — session
  persistence without the bar it's normally tied to visually.

### Kitty

Terminal emulator with separate `light.conf` / `dark.conf` theme files,
switched by symlinking `current-theme.conf` and reloading via `kitty @` —
see [Theme sync](#theme-sync). A second, unconfigured Kitty instance
(`--config NONE`) is used purely as a WiFi-connect popup
(`nmcli device wifi list` + `nmtui-connect` in a floating, centered
window), so a network switch never has to leave the keyboard or open a
full GUI settings panel.

### Neovim / LazyVim

Base entrypoint is a nearly-stock `lazy.nvim` bootstrap, but with one
deliberate change — see [Why local instead of upstream](#why-local-instead-of-upstream).
On top of that base:

- **Snacks.nvim explorer**, replacing `nvim-tree`, with a from-scratch
  `keymaps_explorer.lua` that re-implements buffer-scoped yank / open /
  paste / rename / delete / add actions by constructing a *fake picker
  object* — enough of Snacks' picker interface (`selected`, `dir`, `cwd`,
  `find`, `current`, …) stubbed out that the explorer's own action
  functions can run against a single buffer path with no real picker
  session open. This lets a keybind like `<C-D>` yank "the file behind
  this buffer" from anywhere, not just from inside the tree view.
- Custom **Snacks picker** sources/actions, a universal `toggle_regex`
  action, and an `M.wrap` picker utility that pre-fills the picker input
  from the current visual selection or word-under-cursor.
- **ble.sh integration** for vi-mode clipboard sync via `xclip`/`wl-copy`,
  plus vim-slime-style REPL sending into tmux panes
  (`clipboard-slime-core`, modeled directly on
  [vim-slime's tmux target](https://github.com/jpalardy/vim-slime/blob/main/autoload/slime/targets/tmux.vim)).
- `render-markdown.nvim`, treesitter conceal queries, and `dial.nvim`
  augends for MD/MDX documentation editing — the same doc formats mirrored
  locally by `sys/restore` into `~/.src`.

### CopyQ

Not used as a passive clipboard *history* viewer — it's wired as a
20-slot addressable store. `copyq-commands.ini` maps single keys and
`shift+`/`ctrl+`-prefixed keys directly to slot indices (`q,w,m,r,z,y,u,i,
o,p,a,s,d,f,g,e,h,l,n,j` → slots `0`–`19`, following the same custom keyd
layout), so "select slot 7 and paste it into the focused window" is one
keystroke, and a second binding does select-*and*-jump-*and*-paste in one
shot by shelling out to `hyprctl dispatch` between CopyQ's own `select()`
and the shared `hypr/bin/paste` script.

### Yazi

Terminal file manager, themed with the Catppuccin Mocha/Latte flavors and
extended with the [gvfs.yazi](https://github.com/boydaihungst/gvfs.yazi)
plugin for mounting/unmounting GVFS devices (MTP phones, etc.) from inside
the file manager. Custom `g`-prefixed jumps go straight to this repo's own
config dir, the mounted phone's WhatsApp media folder, and a personal USB
drive — turning the file manager into a fixed set of bookmarks for the
specific sync workflow in [Backup / sync](#backup--sync).

### ble.sh

A [Bash Line Editor](https://github.com/akinomyoga/ble.sh) — gives bash
fish-like autosuggestions, syntax highlighting, and a real vi-mode. Chosen
over switching the login shell to zsh or fish specifically so `.bashrc`
stays the single source of truth and every script in this repo (all of
which use `#!/usr/bin/env bash`) keeps running unmodified in interactive
shells too. `.blerc` adds custom completion-menu widgets (numbered accept,
accept-and-execute) on top of ble.sh's own completion system.

### xdg-desktop-portal-termfilechooser

Swaps the GTK file-picker dialog that apps like Firefox normally spawn for
opening/saving files with a script-driven wrapper
(`yazi-wrapper.sh`) that opens **Yazi in a floating Kitty window** instead.
The benefit is consistency, not aesthetics: file selection anywhere in the
system — inside a browser upload dialog, a save-as prompt — uses the exact
same keybinds, theme, and GVFS-mount shortcuts as the file manager used
everywhere else, instead of a separate GTK tree view with its own
(different) navigation model.

### systemd user units

Two timers, both intentionally lightweight `oneshot` services:

- `battery-check.timer` — polls `/sys/class/power_supply/BAT0` every 10
  minutes and sends a `dbus-send` desktop notification below 40% charge
  (and cleans it up once charging resumes), without pulling in a full
  system-tray battery applet.
- `sync-system.timer` — runs `sys/sync` on a `OnCalendar=*-01,05,09-01`
  schedule (the 1st of January, May, and September) as a periodic,
  low-frequency checkpoint of the [backup/sync](#backup--sync) process,
  on top of running it manually whenever a package or symlink set changes.

### Theme sync

`.local/bin/toggle-theme` is the single script that keeps every app's
light/dark state consistent, run from one Hyprland keybind. In order, one
invocation: re-symlinks Kitty's `current-theme.conf`, reloads Kitty live
via its remote-control socket (falling back to `SIGUSR1` if that's
unavailable), updates tmux's copy-mode highlight color, flips the GNOME
`color-scheme` gsetting, loads the matching CopyQ theme file, and — for
every currently running Neovim server socket under `/run/user/$UID/` —
remotely sends `:colorscheme catppuccin-latte|mocha`. One keypress, six
apps, no restart of anything.

## Why local instead of upstream

LazyVim is not pulled in as a normal `lazy.nvim` plugin spec pointing at
`LazyVim/LazyVim` on GitHub. `init.lua` instead does:

```lua
{
  "LazyVim/LazyVim",
  dir = vim.env.HOME .. "/.config/nvim/LazyVim",
  import = "lazyvim.plugins",
},
```

`dir` tells `lazy.nvim` to load LazyVim from a local path instead of
cloning it — the entire `lua/lazyvim/` tree (config, plugins, util —
about 7,500 lines of Lua) lives inside this repo and is edited directly,
in place. The standard LazyVim workflow treats `lua/plugins/*.lua` in the
*user's own* config as an overlay on top of an untouched, separately
updated LazyVim install; this setup treats **LazyVim's own source as the
config**, so a change like `keymaps_explorer.lua` (a file that doesn't
exist upstream) or a rewritten `plugins/extras/editor/snacks_explorer.lua`
isn't an override layered on top of LazyVim's defaults — it *is* the
default now, on this machine. The tradeoff is explicit and intentional:
LazyVim's own auto-updater no longer manages this tree, so pulling
upstream LazyVim changes has to be done manually (e.g. diffing against a
fresh clone) rather than automatically on the next plugin sync — accepted
here because several of the customizations (the explorer keymaps,
`M.wrap`) needed to sit *inside* LazyVim's own module boundaries, not
bolted on from a user overlay that loads after it.

## Comparisons

Not every component here was picked because no alternative exists — most
have close relatives. This section is about the specific tradeoff made in
each case.

- **[keyd](https://github.com/rvaiya/keyd)** vs. a compositor-level remap
  (e.g. Hyprland's own `input:kb_*` options) or `xmodmap`:
  - keyd remaps at the evdev layer, so the same layout applies in a raw
    TTY, inside Hyprland, and inside X11 sessions alike.
  - A Hyprland-native remap only exists while Hyprland is the active
    session; it's simpler to write but doesn't survive dropping to a TTY
    or running a different compositor.
  - `xmodmap` is X11-only and does nothing under Wayland, which rules it
    out entirely for a Hyprland-based setup.

- **[xdg-desktop-portal-termfilechooser](https://github.com/boydaihungst/xdg-desktop-portal-termfilechooser)**
  vs. the default GTK/Qt portal file chooser:
  - The stock portal spawns a GTK (or Qt) dialog with its own navigation,
    theme, and keybinds, disconnected from the rest of the setup.
  - termfilechooser instead runs *any* script, so pointing it at Yazi
    means file-open/save dialogs inherit the exact same keymap, theme, and
    GVFS-mount shortcuts as the everyday file manager — one less UI to
    relearn.

- **LazyVim vendored locally** vs. the standard LazyVim starter layout
  (`lua/plugins/*.lua` as a user overlay, LazyVim itself pulled as a
  normal git-tracked plugin):
  - The standard layout keeps LazyVim as an independently-updatable
    dependency; overrides are additive files that layer on top.
  - Vendoring it under `dir = ...` means the *base* files are edited
    directly, which is required for changes that add new modules inside
    `lazyvim.config`/`lazyvim.plugins` rather than ones that only add or
    replace a spec from outside — at the cost of manual, diff-based
    upstream syncing instead of automatic plugin updates.

- **CopyQ as an addressable slot store** vs. a typical clipboard-manager
  workflow (fuzzy-search history, pick-and-paste):
  - Most clipboard managers optimize for *searching* a long history.
  - This setup optimizes for *speed to a known slot*: keys map directly to
    fixed slot indices, so recalling "the thing in slot 3" never requires
    typing a search query — it's a single keypress, matched against the
    same custom key layout keyd already remapped.

- **tmux (oh-my-tmux) + Kitty** vs. a single do-it-all terminal
  (e.g. WezTerm with built-in multiplexing):
  - Splitting the multiplexer (tmux) from the terminal emulator (Kitty)
    keeps session state (tmux-resurrect/continuum) independent of which
    GPU-accelerated terminal renders it — `reload-kitty` can kill and
    relaunch the terminal process entirely without losing any pane layout
    or scrollback, which isn't as clean a boundary in a terminal that is
    also its own multiplexer.

## Package lists

- [`pacman.packages`](./pacman.packages) — every **explicitly installed,
  official-repo** package (`pacman -Qqen`), regenerated by `sys/sync`, not
  hand-maintained.
- [`yay.packages`](./yay.packages) — every explicitly installed **AUR**
  package (`pacman -Qqem`), same generation process.
- [`symlinks`](./symlinks) — every path under `$HOME` that this repo
  manages as a symlink back into `~/archlinux`, also generated, not
  hand-written.

Treating these three files as generated output (instead of something
edited by hand) is what makes `sys/sync` safe to run repeatedly: the
worst case is a no-op diff, never a silently stale package list.

## Disclaimer

This is my personal Arch Linux development environment. It is opinionated
and primarily intended for reference. Use individual configurations or the
installation scripts as needed.
