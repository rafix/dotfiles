# AGENTS.md - Dotfiles Configuration

## Overview
This is a **dotfiles repository** for personal macOS development environment, built with [Dotly](https://github.com/CodelyTV/dotly) + [Zimfw](https://github.com/zimfw/zimfw). Not a typical application.

## Key Commands

```bash
# First-time setup (after git clone)
git submodule update --init --recursive modules/dotly
./scripts/setup.zsh

# Daily updates
up                           # Update all packages (brew, dotly, zimfw)
dot package import           # Import Dotly packages
dot symlinks apply           # Apply symlink configuration

# Shell changes
zimfw install && zimfw build  # Rebuild Zimfw after .zimrc changes
zimfw update                  # Update zimfw modules

# Manual reload
source ~/.zshrc
```

## Environment Variables (set by setup.zsh)
- `DOTFILES_PATH` - Root of this repo
- `DOTLY_PATH` - `$DOTFILES_PATH/modules/dotly`
- `ZDOTDIR` - `$DOTFILES_PATH/shell/zsh`
- `ZIM_HOME` - `$ZDOTDIR/.zim`

## Important Paths
- Shell config: `shell/zsh/` (linked to `~/.zshrc`, `~/.zshenv`)
- tmux config: `shell/tmux/tmux.conf` (linked to `~/.tmux.conf`)
- Brewfile: `os/mac/brew/Brewfile`
- Symlinks: `symlinks/conf.yaml`, `symlinks/conf.macos.yaml`

## Common Tasks

**Add a new brew package:**
```bash
brew install <package>
brew bundle dump --file=os/mac/brew/Brewfile --force
```

**Add a new shell alias:** Edit `shell/aliases.sh`, then `source ~/.zshrc`

**Add a new symlink:** Edit `symlinks/conf.yaml` or `symlinks/conf.macos.yaml`, then `dot symlinks apply`

**Troubleshoot slow shell:**
```bash
zsh -xvs 2>&1 | head -100
zimfw build
```

## Generated Files (gitignored)
- `shell/zsh/.zim/` - Zimfw build outputs
- `*.zwc` - Compiled Zsh files
- `*.old` - Backup files