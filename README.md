# nvim-config

Personal Neovim configuration. Cross-platform (macOS, Linux, Windows WSL).

## Prerequisites

- Git
- C compiler (gcc, clang, or zig) - required for Treesitter
- [Nerd Font](https://www.nerdfonts.com/) - required for icons

## Installation

### Option 1: Automatic (Recommended)

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/nvim-config.git ~/nvim-config

# Run installer (installs dependencies + creates symlink)
cd ~/nvim-config
./install.sh
```

### Option 2: Manual

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/nvim-config.git ~/nvim-config

# 2. Install dependencies
# macOS
brew install neovim ripgrep fd lazygit node

# Ubuntu/Debian
sudo apt install neovim ripgrep fd-find nodejs

# 3. Create symlink
# macOS/Linux
ln -sf ~/nvim-config/nvim ~/.config/nvim

# Windows (PowerShell as Admin)
New-Item -ItemType Junction -Path "$env:LOCALAPPDATA\nvim" -Target "C:\path\to\nvim-config\nvim"

# 4. Launch Neovim (plugins install automatically)
nvim
```

## Usage

### First Launch

On first launch, lazy.nvim will automatically:
1. Bootstrap itself
2. Install all plugins
3. Generate `lazy-lock.json`

Wait for installation to complete, then restart Neovim.

### Key Bindings

Leader key: `<Space>`

| Key | Action |
|-----|--------|
| `<Space>ff` | Find files |
| `<Space>fg` | Live grep (search text) |
| `<Space>fb` | List buffers |
| `<Space>fr` | Recent files |
| `<Space>e` | Toggle file explorer |
| `<Space>w` | Save file |
| `<Space>q` | Quit |
| `gd` | Go to definition |
| `gr` | Go to references |
| `K` | Hover documentation |
| `<Space>la` | Code action |
| `<Space>lr` | Rename symbol |
| `<Space>lf` | Format file |

Press `<Space>` and wait for which-key popup to see all available bindings.

### Plugin Management

```vim
" Open plugin manager UI
:Lazy

" Update all plugins
:Lazy update

" Sync plugins (install missing + update)
:Lazy sync

" Restore plugins to lockfile versions
:Lazy restore
```

### LSP Management

```vim
" Open Mason UI (manage LSP servers, formatters, linters)
:Mason

" Install a server
:MasonInstall pyright

" Available servers are auto-installed on file open if configured
```

### Adding Language Support

Edit `nvim/lua/plugins/lsp.lua`, add server to `ensure_installed`:

```lua
ensure_installed = {
    "lua_ls",
    "pyright",      -- Python
    "rust_analyzer", -- Rust
    "gopls",        -- Go
    "ts_ls",        -- TypeScript/JavaScript
    "clangd",       -- C/C++
},
```

## Updating

```bash
# Pull latest config
cd ~/nvim-config && git pull

# Update plugins (in Neovim)
:Lazy sync
```

## Syncing Across Machines

The `lazy-lock.json` file pins exact plugin versions. Always commit it:

```bash
cd ~/nvim-config
git add nvim/lazy-lock.json
git commit -m "update plugin versions"
git push
```

On another machine:
```bash
git pull
nvim
:Lazy restore
```

## Structure

```
nvim-config/
├── install.sh              # Auto-install script
├── uninstall.sh            # Remove symlinks
└── nvim/
    ├── init.lua            # Entry point
    ├── lazy-lock.json      # Plugin version lock (auto-generated)
    └── lua/
        ├── config/
        │   ├── options.lua     # Editor settings
        │   ├── keymaps.lua     # Key bindings
        │   ├── autocmds.lua    # Auto commands
        │   └── lazy.lua        # Plugin manager setup
        └── plugins/
            ├── colorscheme.lua # Theme (TokyoNight)
            ├── editor.lua      # File explorer, fuzzy finder, etc.
            ├── lsp.lua         # Language servers + completion
            ├── treesitter.lua  # Syntax highlighting
            └── ui.lua          # Statusline, bufferline, notifications
```

## Uninstall

```bash
cd ~/nvim-config
./uninstall.sh

# Optionally remove plugin data
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
```

## License

MIT
