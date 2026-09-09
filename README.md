### Principle

> GUI interaction is avoided when a shortcut or script can do it faster.

The result? Less about making it pretty, more about making it work.

### Installation

```bash
curl -fsSL https://raw.githubusercontent.com/iqrar-eng/archlinux/main/.local/bin/sys/restore -o yes
bash yes && rm yes
```

### How it works

1. Installs every package listed in `./pacman.packages` and ./`yay.packages`.
3. Clones this repository and symlinks paths in the `./symlinks` from `$HOME` into it.
4. Clones docs such as MDN for local, greppable access.
