# Neovim Config

Personal Neovim setup focused on C++ development with LSP, debugging, and AI assistance.

## Requirements

- Neovim >= 0.9
- [Nerd Font](https://www.nerdfonts.com/) (icons throughout)
- `make`, `git`, `ripgrep`, `fd`
- `clangd` for C/C++ LSP

## Structure

```
nvim/
├── init.lua              # Core settings, keymaps, autocmds
├── lua/
│   ├── config/
│   │   └── lazy.lua      # Plugin manager bootstrap
│   └── plugins/          # One file per plugin
└── README.md
```

---

## Plugins

| Plugin | Purpose |
|---|---|
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder for files, grep, symbols, git |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) + mason | LSP (clangd, lua_ls, jdtls, zls) |
| [nvim-dap](https://github.com/mfussenegger/nvim-dap) + codelldb | C++ debugger via DAP |
| [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | Debugger UI panels |
| [avante.nvim](https://github.com/yetone/avante.nvim) | AI code assistant |
| [nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Autocompletion |
| [conform.nvim](https://github.com/stevearc/conform.nvim) | Formatting (clang-format, stylua) |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | Git hunk indicators |
| [vim-fugitive](https://github.com/tpope/vim-fugitive) | Git commands |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | File tree |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | Directory editor |
| [mini.nvim](https://github.com/echasnovski/mini.nvim) | Surround, text objects, statusline |
| [catppuccin](https://github.com/catppuccin/nvim) | Colorscheme |
| [which-key.nvim](https://github.com/folke/which-key.nvim) | Keymap hints |
| [todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | TODO/FIXME highlights |

---

## Keymaps

`<leader>` = `Space`

### Files & Search

| Key | Action |
|---|---|
| `<leader>sf` | Find files |
| `<leader>sg` | Live grep |
| `<leader>sw` | Search word under cursor |
| `<leader>sr` | Resume last search |
| `<leader>s.` | Recent files |
| `<leader><leader>` | Open buffers |
| `<leader>/` | Fuzzy search current buffer |
| `<leader>e` | Open parent directory (oil) |
| `<leader>E` | Open project root (oil) |
| `\` | File tree (neo-tree) |

### LSP

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gi` | Go to implementation |
| `gD` | Go to declaration |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>ds` | Document symbols |
| `<leader>ws` | Workspace symbols |
| `<leader>th` | Toggle inlay hints |
| `K` | Hover docs |

### Debugging (nvim-dap)

| Key | Action |
|---|---|
| `<leader>dc` | Start / continue |
| `<leader>dn` | Step over |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>dr` | Run to cursor |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `]b` / `[b` | Next / prev breakpoint |
| `<leader>dl` | Run last config |
| `<leader>du` | Toggle DAP UI |
| `<leader>dx` | Terminate session |

Launch configs are defined per-project in `.nvim.lua` at the project root (loaded automatically via `exrc`).

### Build & Quickfix

| Key | Action |
|---|---|
| `<leader>l` | Build project (output + quickfix on error) |
| `<leader>bt` | Run unit tests with filter prompt (project-local) |
| `<leader>bT` | Run test under cursor (project-local) |
| `<leader>dT` | Debug test under cursor (project-local) |
| `]q` / `[q` | Next / prev error (wraps) |
| `<CR>` in quickfix | Open error in source window |

`makeprg` is set per-project in `.nvim.lua`.

### Git

| Key | Action |
|---|---|
| `<leader>ms` | Git status |
| `<leader>mb` | Git blame |
| `<leader>md` | Diff (vertical split) |
| `<leader>mf` | Branches |
| `<leader>mc` | Commits |
| `]c` / `[c` | Next / prev hunk |
| `<leader>ts` | Stage hunk |
| `<leader>tr` | Reset hunk |
| `<leader>tp` | Preview hunk |

### Windows & Buffers

| Key | Action |
|---|---|
| `<C-h/j/k/l>` | Move between windows |
| `<leader>v` | Vertical split |
| `<leader>h` | Horizontal split |
| `<leader>q` | Close buffer |
| `<leader>bn` / `<leader>bp` | Next / prev buffer |
| `<Up/Down/Left/Right>` | Resize window |

### Editing

| Key | Action |
|---|---|
| `<leader>f` | Format buffer |
| `<leader>D` | Delete without yanking |
| `<A-j>` / `<A-k>` | Move line / selection up or down |
| `<leader>tm` | Convert virtual method → GMock `MOCK_METHOD` |

---

## Project-local Config

Projects can drop a `.nvim.lua` at their root to configure `makeprg`, DAP launch configs, and test runners. Neovim loads it automatically via `exrc` (you'll be asked to trust it once).

```lua
-- example .nvim.lua
local dap = require('dap')
local root = vim.fn.getcwd()

vim.opt.makeprg = "cmake --build " .. root .. "/build"

dap.configurations.cpp = {
    {
        name = 'My App',
        type = 'codelldb',
        request = 'launch',
        program = root .. '/build/my_app',
        cwd = root,
        stopOnEntry = false,
        args = {},
    },
}
```

For git worktrees, symlink the `.nvim.lua` files from the main tree into the corresponding paths in each worktree so they're picked up automatically.
