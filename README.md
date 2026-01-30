# Eitan's Dotfiles

Personal configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

![Catppuccin Mocha](https://img.shields.io/badge/theme-Catppuccin%20Mocha-cba6f7?style=flat-square)
![macOS](https://img.shields.io/badge/os-macOS-000000?style=flat-square&logo=apple)

## What's Included

| Package    | Description                          |
|------------|--------------------------------------|
| `zsh`      | Zsh configuration with aliases       |
| `git`      | Git configuration                    |
| `vim`      | Vim configuration                    |
| `tmux`     | Tmux with Catppuccin theme           |
| `starship` | Cross-shell prompt                   |
| `nvim`     | Neovim (LazyVim)                     |
| `ghostty`  | GPU-accelerated terminal             |
| `fastfetch`| System info display                  |

## Quick Start

### Fresh Install

```bash
# Clone the repository
git clone https://github.com/eitanpod/dotfiles.git ~/.dotfiles

# Run the installer
~/.dotfiles/install.sh
```

### Manual Installation

```bash
# Install GNU Stow
brew install stow

# Clone the repo
git clone https://github.com/eitanpod/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Stow individual packages
stow zsh
stow git
stow vim
stow tmux
stow starship
stow nvim
stow ghostty
stow fastfetch

# Or stow all at once
stow */
```

## Structure

```
~/.dotfiles/
├── README.md
├── install.sh          # Bootstrap script
├── Brewfile            # Homebrew dependencies
├── .gitignore
│
├── zsh/
│   ├── .zshrc          # Main zsh config
│   └── .zshrc.local.example  # Template for secrets
│
├── git/
│   └── .gitconfig
│
├── vim/
│   └── .vimrc
│
├── tmux/
│   └── .config/
│       └── tmux/
│           └── .tmux.conf
│
├── starship/
│   └── .config/
│       └── starship/
│           └── starship.toml
│
├── nvim/
│   └── .config/
│       └── nvim/
│           ├── init.lua
│           └── lua/...
│
├── ghostty/
│   └── .config/
│       └── ghostty/
│           └── config
│
└── fastfetch/
    └── .config/
        └── fastfetch/
            └── config.jsonc
```

## How Stow Works

GNU Stow creates symlinks from your home directory to the dotfiles repo:

```bash
# Running this:
cd ~/.dotfiles && stow zsh

# Creates this symlink:
~/.zshrc -> ~/.dotfiles/zsh/.zshrc
```

To remove a package's symlinks:
```bash
stow -D zsh  # Unstow/remove the zsh package
```

## Local Configuration

Secrets and machine-specific settings go in `~/.zshrc.local` (gitignored):

```bash
# Copy the template
cp ~/.dotfiles/zsh/.zshrc.local.example ~/.zshrc.local

# Edit with your secrets
nvim ~/.zshrc.local
```

Example content:
```bash
export ANTHROPIC_API_KEY="sk-ant-..."
export OPENAI_API_KEY="sk-..."
export GITHUB_TOKEN="ghp_..."
```

## Key Bindings

### Tmux (prefix: `Ctrl-a`)

| Binding         | Action                    |
|-----------------|---------------------------|
| `prefix + \|`   | Split horizontally        |
| `prefix + -`    | Split vertically          |
| `prefix + r`    | Reload config             |
| `prefix + m`    | Toggle maximize pane      |
| `prefix + hjkl` | Resize panes              |
| `prefix + I`    | Install plugins (TPM)     |

### Aliases

| Alias    | Command                                |
|----------|----------------------------------------|
| `vim`    | `nvim`                                 |
| `ls`     | `eza --icons`                          |
| `ll`     | `eza -lh --icons`                      |
| `la`     | `eza -la --icons`                      |
| `lt`     | `eza --tree --level=2 --icons`         |
| `cat`    | `bat --paging=never`                   |
| `k`      | `kubectl`                              |
| `tf`     | `terraform`                            |
| `tg`     | `terragrunt`                           |
| `reload` | `source ~/.zshrc`                      |
| `dotfiles` | `cd ~/.dotfiles`                     |

## Dependencies

Install all dependencies with:
```bash
brew bundle --file=~/.dotfiles/Brewfile
```

Or install individually:
```bash
brew install stow neovim tmux starship eza bat ripgrep zoxide fzf
brew install zsh-autosuggestions zsh-syntax-highlighting
```

## Updating

```bash
cd ~/.dotfiles
git pull
./install.sh  # Re-run to pick up new packages
```

## Theme

All tools use the [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) color scheme for a consistent look across:
- Terminal (Ghostty)
- Tmux status bar
- Starship prompt
- Neovim

## License

MIT
