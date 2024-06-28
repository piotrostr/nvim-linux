local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
  'rakr/vim-one',
  'williamboman/mason.nvim',
  'williamboman/mason-lspconfig.nvim',
  'leafgarland/typescript-vim',
  { "ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ...},
  'dag/vim-fish',
  'jparise/vim-graphql',
  'tpope/vim-fugitive',
  'prettier/vim-prettier',
  --{ 'neoclide/coc.nvim', branch = "master", build= "npm ci" },
  'simrat39/rust-tools.nvim',
  'ryanoasis/vim-devicons',
  'nvim-lua/plenary.nvim',
  'sindrets/diffview.nvim',
  'nvim-telescope/telescope.nvim',
  'neovim/nvim-lspconfig',
  'zbirenbaum/copilot.lua',
  'zbirenbaum/copilot-cmp',
  'hrsh7th/nvim-cmp',
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/cmp-vsnip',
  'hrsh7th/vim-vsnip',
  'vim-airline/vim-airline',
  'vim-airline/vim-airline-themes',
  'nvim-lua/popup.nvim',
  'kyazdani42/nvim-web-devicons',
  'nvim-treesitter/nvim-treesitter',
  'windwp/nvim-ts-autotag',
  'dylanaraps/wal.vim',
  'mfussenegger/nvim-dap',
  'aserowy/tmux.nvim',
  'nvim-telescope/telescope-fzf-native.nvim',
  'folke/tokyonight.nvim',
  'fladson/vim-kitty',
  'navarasu/onedark.nvim',
  'karb94/neoscroll.nvim',
  'dstein64/nvim-scrollview',
  'hashivim/vim-terraform',
  'github/copilot.vim',
  'christoomey/vim-system-copy',
  'norcalli/nvim-colorizer.lua',
  'sebdah/vim-delve',

  {
    "melbaldove/llm.nvim",
    dependencies = { "nvim-neotest/nvim-nio" }
  }
})
-- Mason Setup
require("mason").setup({
    ui = {
        icons = {
            package_installed = "",
            package_pending = "",
            package_uninstalled = "",
        },
    }
})
require("mason-lspconfig").setup()

vim.o.runtimepath = vim.o.runtimepath .. ',~/.vim'

vim.o.runtimepath = vim.o.runtimepath .. ',~/.vim/after'

-- Key mappings
vim.api.nvim_set_keymap('n', 'Y', 'y$', { noremap = true })
vim.api.nvim_set_keymap('n', 'n', 'nzzzv', { noremap = true })
vim.api.nvim_set_keymap('n', 'N', 'Nzzzv', { noremap = true })
vim.api.nvim_set_keymap('n', 'J', 'mzJ`z', { noremap = true })

-- Syntax and filetype
vim.cmd('syntax on')
vim.cmd('filetype plugin indent on')

-- General settings
vim.o.backup = false
vim.o.writebackup = false
vim.o.updatetime = 300
vim.wo.signcolumn = 'yes'

-- LSP settings
local nvim_lsp = require('lspconfig')

-- Enable completion
local cmp = require'cmp'

-- Completion Plugin Setup
local cmp = require'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-S-f>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<Tab>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    }),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },
  -- Installed sources:
  sources = {
    { name = 'nvim_lsp', keyword_length = 3 },      -- from language server
    { name = 'nvim_lsp_signature_help'},            -- display function signatures with current parameter emphasized
    { name = 'nvim_lua', keyword_length = 2},       -- complete neovim's Lua runtime API such vim.lsp.*
    -- { name = 'buffer', keyword_length = 2 },     -- source current buffer, comment out or remove this line
    { name = 'vsnip', keyword_length = 2 },         -- nvim-cmp source for vim-vsnip
    { name = 'path'},                               -- file paths
    { name = 'calc'},                               -- source for math calculation
  },
  window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
  },
  formatting = {
      fields = {'menu', 'abbr', 'kind'},
      format = function(entry, item)
          local menu_icon ={
              nvim_lsp = 'λ',
              vsnip = '⋗',
              buffer = 'Ω',
              path = '🖫',
          }
          item.menu = menu_icon[entry.source.name]
          return item
      end,
  },
})


-- Enable LSP servers
local servers = { 'tsserver', 'jsonls', 'rust_analyzer', 'pyright' }
for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup {
    on_attach = function(client, bufnr)
      local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
      local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

      -- Enable completion triggered by <c-x><c-o>
      buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

      -- Mappings.
      local opts = { noremap=true, silent=true }

      -- See `:help vim.lsp.*` for documentation on any of the below functions
      buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
      buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
      buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
      buf_set_keymap('n', 'gi', '<Cmd>lua vim.lsp.buf.implementation()<CR>', opts)
      buf_set_keymap('n', '<C-k>', '<Cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
      buf_set_keymap('n', '<space>D', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
      buf_set_keymap('n', '<space>rn', '<Cmd>lua vim.lsp.buf.rename()<CR>', opts)
      buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
      buf_set_keymap('n', '<space>e', '<Cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
      buf_set_keymap('n', '[d', '<Cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
      buf_set_keymap('n', ']d', '<Cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
      buf_set_keymap('n', '<space>q', '<Cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
      buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    end
  }
end

-- Show documentation function
function _G.show_documentation()
  if vim.bo.filetype == 'vim' or vim.bo.filetype == 'help' then
    vim.cmd('h ' .. vim.fn.expand('<cword>'))
  else
    vim.lsp.buf.hover()
  end
end
vim.api.nvim_set_keymap('n', 'K', ':lua show_documentation()<CR>', { noremap = true, silent = true })

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
  opts.max_width = opts.max_width or 80
  opts.max_height = opts.max_height or 20
  opts.focusable = opts.focusable or false
  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Autocommands for formatting
vim.cmd([[
augroup mygroup
  autocmd!
  autocmd BufWritePre *.ts,*.json lua vim.lsp.buf.formatting_sync(nil, 1000)
augroup end
]])

-- Statusline
vim.o.statusline = '%{v:lua.vim.lsp.status()}'

vim.o.packpath = vim.o.runtimepath
vim.g.dashboard_default_executive = 'telescope'
vim.g.onedark_config = { style = 'deep' }
vim.g.tokyonight_style = 'night'
vim.g.tokyonight_transparent = 1
vim.g.airline = {
  extensions = {
    tabline = {
      enabled = 1,
      formatter = 'unique_tail',
      show_splits = 0
    }
  }
}
vim.g.gruvbox_italic = 1
vim.g.gruvbox_bold = 1
vim.g.gruvbox_transparent_bg = 1
vim.g.airline_theme = 'minimalist'
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.vimspector_install_gadgets = { 'debugpy', 'vscode-node-debug2' }

-- if vim.fn.exists('+termguicolors') == 1 then
--   vim.o.t_8f = "\\<Esc>[38;2;%lu;%lu;%lum"
--   vim.o.t_8b = "\\<Esc>[48;2;%lu;%lu;%lum"
--   vim.o.termguicolors = true
-- end

vim.o.colorcolumn = '80'
vim.o.hidden = true
vim.o.encoding = 'utf-8'
vim.o.shiftwidth = 2
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.smarttab = true
vim.o.expandtab = true
vim.o.hlsearch = true
vim.o.ruler = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.guicursor = 'i:block'
vim.o.foldmethod = 'manual'

if os.getenv("DAYTIME") == 'day' then
  vim.o.background = 'light'
  vim.g.onedark_config = { style = 'light' }
else
  vim.g.onedark_config = { style = 'darker' }
  vim.o.background = 'dark'
end

vim.cmd('autocmd! BufWritePost ~/.config/nvim/init.vim source ~/.config/nvim/init.vim')
vim.cmd('autocmd! BufWritePost ~/.config/nvim/plug.vim source ~/.config/nvim/plug.vim')

vim.cmd([[colorscheme gruvbox]])
vim.o.background = 'dark'
vim.cmd('highlight Normal ctermbg=NONE guibg=NONE')
vim.cmd('highlight LineNr ctermbg=NONE guibg=NONE')
vim.cmd('highlight SignColumn ctermbg=NONE guibg=NONE')
vim.cmd('highlight Comment ctermfg=green')

vim.api.nvim_set_keymap('n', '<space>', '<Leader>', {})
vim.api.nvim_set_keymap('n', '<c-k>', ':wincmd k<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<c-j>', ':wincmd j<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<c-h>', ':wincmd h<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<c-l>', ':wincmd l<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<c-n>', ':bn<CR>', { silent = true })
vim.api.nvim_set_keymap('n', '<c-p>', ':bp<CR>', { silent = true })

-- Set up telescope bindings
vim.api.nvim_set_keymap('n', ';f', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ';r', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ';b', '<cmd>Telescope buffers<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', ';;', '<cmd>Telescope help_tags<cr>', { noremap = true, silent = true })

-- Remove buffer from tabline if it's closed
vim.cmd('autocmd BufDelete * lua require("airline").extensions.tabline.buftree.invalidate()')

-- Autocommands for filetypes
vim.cmd([[
  autocmd FileType go lua Go_settings()
  autocmd FileType python lua Python_settings()
]])

-- Go settings
function Go_settings()
  vim.bo.tabstop = 2
  vim.bo.shiftwidth = 2
  vim.bo.expandtab = true
  vim.api.nvim_command('autocmd FileType go nmap tj :CocCommand go.tags.add json<cr>')
  vim.api.nvim_command('autocmd FileType go nmap ty :CocCommand go.tags.add yaml<cr>')
  vim.api.nvim_command('autocmd FileType go nmap tx :CocCommand go.tags.clear<cr>')
end

-- Python settings
function Python_settings()
  vim.bo.tabstop = 4
  vim.bo.shiftwidth = 4
  vim.bo.expandtab = true
end

-- Organize imports on save for Go files
vim.cmd('autocmd BufWritePre *.go :silent call CocAction("runCommand", "editor.action.organizeImport")')

--telescope setup
local actions = require('telescope.actions')
require'telescope'.setup{
  defaults = {
    mappings = {
      n = {
        ["q"] = actions.close
      },
    },
    file_ignore_patterns = { "node%_modules/.*" }
  },
}

--treesitter setup
--require'nvim-treesitter.install'.compilers = { 'aarch64-apple-darwin21-gcc-11' }
require'nvim-treesitter.configs'.setup {
  ensure_installed = {
    "javascript",
    "tsx",
    "json",
    "html",
    "typescript",
    "lua",
    "go",
    "python"
  },
  highlight = {
    enable = true,
    disable = {"python"},
  },
  indent = {
    enable = false,
    disable = {},
  },
  autotag = {
    enable = true,
    filetypes = {
      "javascript.jsx",
      "typescript.tsx",
      "html",
      "javascriptreact",
      "javascript",
      "typescript",
      "typescriptreact",
    },
  }
}

require "nvim-treesitter.parsers".get_parser_configs().solidity = {
  install_info = {
    url = "https://github.com/JoranHonig/tree-sitter-solidity",
    files = {"src/parser.c"},
    requires_generate_from_grammar = true,
  },
  filetype = 'solidity'
}

-- tmux bindings
require'tmux'.setup{
    copy_sync = {
        enable = false,
        ignore_buffers = { empty = false },
        redirect_to_clipboard = true,
        register_offset = 0,
        sync_clipboard = true,
        sync_deletes = true,
        sync_unnamed = true,
    },
    navigation = {
        cycle_navigation = true,
        enable_default_keybindings = true,
        persist_zoom = false,
    }
}

require'colorizer'.setup()

require("llm").setup({
  timeout_ms = 10000,
  services = {
    openai = {
      url = "https://api.openai.com/v1/chat/completions",
      model = "gpt-4o-2024-05-13",
      api_key_name = "OPENAI_API_KEY",
    }
  }
})
vim.keymap.set("n", "g,", function() require('llm').prompt({ replace = false, service = "openai" }) end)
vim.keymap.set("v", "g.", function() require('llm').prompt({ replace = true, service = "openai" }) end)

-- GitHub Copilot setup
require('copilot').setup({
  suggestion = { enabled = false },
  panel = { enabled = false },
})
require('copilot_cmp').setup()
