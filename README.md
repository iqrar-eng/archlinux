# archlinux

Dotfiles, package lists, and install/backup scripts for a Hyprland + tmux +
Neovim development environment on Arch Linux.

## Contents

* [Overview](#overview)
* [Layout](#layout)
* [Installation](#installation)
* [Backup / sync](#backup--sync)
* [Component breakdown](#component-breakdown)

  * [keyd — system-level key remapping](#keyd--system-level-key-remapping)
  * [Hyprland (Lua config)](#hyprland-lua-config)
  * [tmux + oh-my-tmux](#tmux--oh-my-tmux)
  * [Kitty](#kitty)
  * [Neovim / LazyVim](#neovim--lazyvim)
  * [CopyQ](#copyq)
  * [Yazi](#yazi)
  * [ble.sh](#blesh)
  * [xdg-desktop-portal-termfilechooser](#xdg-desktop-portal-termfilechooser)
  * [systemd user units](#systemd-user-units)
  * [Theme sync](#theme-sync)
* [Why LazyVim, but modified](#why-lazyvim-but-modified)
* [Comparisons](#comparisons)
* [Package lists](#package-lists)
* [Disclaimer](#disclaimer)

## Overview

The setup is built around one principle:

> GUI interaction is avoided when a shortcut or script can do it faster.

The result? Less about making it pretty, more about making it work.

## Installation

1. Installs every package listed in `./pacman.packages` and ./`yay.packages`.
3. Clones this repository to `~/archlinux` and symlinks paths listed in
   the `symlinks` file from `$HOME` into it.
4. Clones docs such as MDN into ~/.src for local, greppable access.

The package manifests and `symlinks` file are therefore **generated artifacts,
not hand-maintained configuration**.

## Component breakdown

### keyd — system-level key remapping

**Why keyd instead of a Hyprland-level or X11-level remap:** keyd operates at
the `evdev` input layer, below the compositor, display server, and desktop
environment.

That gives the remap one property this setup depends on: the same physical
keyboard layout works in Hyprland, a TTY, a VM, and GRUB — anywhere the
keyboard is read. A Hyprland remap only exists once Hyprland is running, while
an X11 remap only applies to X11 applications.

`etc/keyd/default.conf` defines a Colemak-DH-style base layer together with
`control`, `alt`, `shift`, and `meta` layers, plus custom layers containing
macros for punctuation pairs, application switching, and window-management
shortcuts.

### Hyprland (Lua config)

Hyprland is configured through `hyprland.lua` and `bind.lua` using its Lua
configuration support rather than the traditional `hyprland.conf` syntax.

The main benefit is actual control flow and reusable functions. For example,
`bind.lua` defines `paste_slot(n)`, which selects a CopyQ slot and dispatches
the paste operation. The same function is reused across multiple keybinds
instead of duplicating the underlying shell commands.

Workspace rules pin Firefox, the tmux terminal, CopyQ, and Yazi to fixed
workspace numbers, so `SUPER + [1-5]` consistently reaches the same
application regardless of launch order.

Gaps, rounding, shadows, blur, and animations are disabled. The goal is a
performance-first, decoration-free layout rather than a visual "rice".

### Neovim / LazyVim

The Neovim configuration starts from a nearly stock `lazy.nvim` bootstrap,
with one deliberate architectural change: LazyVim itself is vendored locally
and modified directly. See [Why LazyVim, but modified](#why-lazyvim-but-modified).

On top of that base:

* **Snacks.nvim explorer** replaces `nvim-tree`, with a custom
  `keymaps_explorer.lua` that reimplements buffer-scoped yank, open, paste,
  rename, delete, and add operations. It constructs a minimal fake picker
  object so Snacks' explorer actions can operate on the file behind the
  current buffer without requiring an active explorer session.
* Custom **Snacks picker** sources and actions provide utilities such as
  `toggle_regex` and `M.wrap`, which pre-fill picker input from the current
  visual selection or word under the cursor.
* **ble.sh integration** provides vi-mode clipboard synchronization through
  `xclip`/`wl-copy`, along with vim-slime-style REPL sending into tmux panes.
  The tmux target implementation is modeled directly on
  [vim-slime's tmux target](https://github.com/jpalardy/vim-slime/blob/main/autoload/slime/targets/tmux.vim).
* `render-markdown.nvim`, Treesitter conceal queries, and `dial.nvim`
  augments provide a documentation-oriented editing environment for Markdown
  and MDX. These are the same documentation formats mirrored locally into
  `~/.src`.

### xdg-desktop-portal-termfilechooser

Replaces the GTK file-picker dialog that applications such as Firefox
normally use for opening and saving files with a script-driven wrapper,
`yazi-wrapper.sh`.

The wrapper opens **Yazi inside a floating Kitty window**.

The point is consistency rather than aesthetics: file selection anywhere in
the system — including browser upload dialogs and save-as prompts — uses the
same file manager, keybindings, theme, and navigation model as the rest of
the environment.

### Yazi

Terminal file manager, themed with the Catppuccin Mocha/Latte flavors and
used as the default file manager for file-opening and save dialogs.

### tmux + oh-my-tmux

The terminal session layer. tmux provides persistent sessions and application
switching while oh-my-tmux supplies the base configuration, with local scripts
handling the parts that need to integrate with the rest of the environment.

### Kitty

The terminal emulator used throughout the desktop. It provides the terminal
surface for tmux and also serves as the host for transient terminal
applications such as Yazi's file chooser.

Light and dark themes are synchronized with the rest of the desktop.

### CopyQ

Clipboard manager and routing layer.

Instead of treating clipboard history as a passive list, this setup exposes
numbered clipboard slots that can be selected and pasted through global
keybindings. This makes frequently reused values accessible without leaving
the current application.

### ble.sh

A Bash line editor providing vi-mode editing and shell integration that fits
the same keyboard-driven workflow used by Neovim and tmux.

Clipboard synchronization and REPL integration connect the interactive shell
to the rest of the development environment.

### systemd user units

User-level services and timers handle tasks that should happen automatically
without being tied to a particular terminal session, including battery
checks and periodic system synchronization.

### Theme sync

Light/dark mode is treated as shared state rather than an independent setting
inside every application. Theme changes propagate across Kitty, Yazi,
Neovim, and other configured components so the environment changes as one
system.

## Why LazyVim, but modified

I considered starting from Kickstart.nvim, but that would mean building and
maintaining more of the editor infrastructure myself. Kickstart is
intentionally minimal: it provides a starting point and leaves most
architectural decisions to the user. That is useful when the goal is to
understand and assemble every part of a Neovim configuration from scratch.

My goal is different: a **complete, opinionated Neovim environment** without
giving up control over the framework itself.

LazyVim provides the infrastructure that would otherwise be tedious to
recreate and maintain — plugin management, sensible defaults, plugin
integrations, LSP configuration, formatting, diagnostics, keymaps, and its
extras system. It also has a well-defined structure that makes those pieces
relatively easy to modify.

Rather than treating LazyVim as an immutable dependency and placing all
changes in `lua/plugins/`, this setup keeps a local copy of LazyVim and
modifies the framework itself.

That makes the configuration more invasive than the standard LazyVim
workflow, but removes the artificial boundary between "LazyVim's
configuration" and "my configuration".

The result is essentially **LazyVim as a starting framework, progressively
reshaped into my own Neovim environment**. I keep the architecture and
upstream components that eliminate unnecessary maintenance while changing or
removing anything that does not fit the workflow.

The tradeoff is explicit: upstream updates require deliberate merging rather
than a normal plugin update. That is acceptable because the goal is not to
track stock LazyVim. The goal is to have a Neovim environment whose defaults
are mine.

## Comparisons

### xdg-desktop-portal-termfilechooser vs. the default file chooser

The default GTK/Qt portal provides a conventional graphical file chooser
with its own navigation, theme, and keybindings.

[**xdg-desktop-portal-termfilechooser**](https://github.com/boydaihungst/xdg-desktop-portal-termfilechooser)
instead allows the file-selection operation to be delegated to an arbitrary
script. Here that script launches Yazi in Kitty.

The result is that file-open and save dialogs inherit the same keybindings,
theme, and navigation model as the everyday file manager. There is one file
selection workflow instead of separate GUI and TUI workflows.

## Package lists

`pacman.packages` contains packages installed through the official Arch
repositories.

`yay.packages` contains AUR packages.

Both manifests are generated by the sync process rather than maintained by
hand.

## Disclaimer

> This is my personal Arch Linux development environment, tailored to my
> workflow and primarily intended for reference. Use individual configurations
> or the installation scripts as needed.
