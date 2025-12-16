-- =============================================================================
-- Core Options
-- =============================================================================

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.smartindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- UI
opt.termguicolors = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitright = true
opt.splitbelow = true
opt.wrap = false
opt.showmode = false
opt.laststatus = 3

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- Files
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Clipboard (use system clipboard)
opt.clipboard = "unnamedplus"

-- Mouse
opt.mouse = "a"

-- =============================================================================
-- Platform-Specific Settings
-- =============================================================================

if vim.fn.has("win32") == 1 then
    -- Windows: Use PowerShell 7 if available
    local pwsh = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
    opt.shell = pwsh
    opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command "
        .. "[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"
    opt.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
    opt.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
    opt.shellquote = ""
    opt.shellxquote = ""
end

