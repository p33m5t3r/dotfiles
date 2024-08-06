-- vim.api.nvim_command('set relativenumber')
vim.api.nvim_command('set ignorecase')
vim.api.nvim_command('set nu rnu')
vim.api.nvim_command('set autoindent')
vim.api.nvim_command('set mouse=a')
vim.api.nvim_command('set shiftwidth=4')
vim.api.nvim_command('set softtabstop=4')
vim.api.nvim_command('set expandtab')
vim.api.nvim_command('set backspace=indent,eol,start')
-- vim.api.nvim_set_option("clipboard","unnamedplus")
vim.o.clipboard:append('unnamedplus')
-- python setup
vim.g.python3_host_prog = '/Users/anon/.envs/neovim3/bin/python3'
vim.g.python_host_prog = '/Users/anon/.envs/neovim3/bin/python3'



-- nerd tree
vim.g.NERDTreeWinSize=15

-- ensure the packer plugin manager is installed
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require("packer").startup(function(use)
  -- package manager
  use("wbthomason/packer.nvim")

  -- colorschemes
  -- https://github.com/ellisonleao/gruvbox.nvim/blob/main/lua/gruvbox/palette.lua
  use("ellisonleao/gruvbox.nvim")
  require("gruvbox").setup({
    palette_overrides = {
        light0 = "#fdf6e3",
    }
  })
  use("arcticicestudio/nord-vim")
  use("fenetikm/falcon")
  use("bluz71/vim-moonfly-colors")
  use("rafamadriz/neon")
  use('rockerBOO/boo-colorscheme-nvim')
  use('aktersnurra/no-clown-fiesta.nvim')

  -- require("boo-colorscheme").use({})
  require("no-clown-fiesta").setup({
      transparent = false, -- Enable this to disable the bg color
      styles = {
        -- You can set any of the style values specified for `:h nvim_set_hl`
        comments = {},
        keywords = {},
        functions = { italic = true },
        variables = {},
        type = { bold = true },
        lsp = { underline = true }
      },
  })


  -- setup colorscheme
  if vim.fn.has("termguicolors") then
    vim.opt.termguicolors = true
  end

  local colorconfig, os_ccfg = "default", os.getenv("COLORCONFIG")

  if os_ccfg then
      colorconfig = os_ccfg
  end

  local lualine_theme = "neon"
  if colorconfig == "default" then
      vim.o.background = "dark"
      vim.cmd([[colorscheme habamax]])

  elseif colorconfig == "light" then
      vim.o.background = "light"
      lualine_theme = "gruvbox_light"
      vim.cmd([[colorscheme gruvbox]])
  end


  -- LSP
  use("neovim/nvim-lspconfig")
  use{
    "j-hui/fidget.nvim",
    tag='legacy',
    config = function()
      require("fidget").setup()
    end
  }

  -- Autocompletion framework
  use("hrsh7th/nvim-cmp")
  use({
    -- cmp LSP completion
    "hrsh7th/cmp-nvim-lsp",
    -- cmp Snippet completion
    "hrsh7th/cmp-vsnip",
    -- cmp Path completion
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    after = { "hrsh7th/nvim-cmp" },
    requires = { "hrsh7th/nvim-cmp" },
  })
  -- See hrsh7th other plugins for more great completion sources!
  -- Snippet engine
  use('hrsh7th/vim-vsnip')
  -- Adds extra functionality over rust analyzer
  use("simrat39/rust-tools.nvim")

  
  -- Optional
  use("nvim-lua/popup.nvim")
  use("nvim-lua/plenary.nvim")
  use("nvim-telescope/telescope.nvim")

  -- Latex
  use("lervag/vimtex")

  -- GPT
  use("madox2/vim-ai")

  -- File explorer
  use("preservim/nerdtree")


  -- status bar
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  local function has_copilot(clients)
    local has_copilot = false
    for _, client in ipairs(clients) do
      print(client.name)
      if client.name == "copilot" then
        has_copilot = true
      end
    end
    return has_copilot
  end


  local function activelsp()
    if not vim then
      return "ACTIVELSP::ERR"
    end

    local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
    local clients = vim.lsp.get_active_clients()    local cp_str = " (X)"

    if has_copilot(clients) then
      cp_str = " (AI)"
    end
    local msg = 'No Lsp' .. cp_str

    if next(clients) == nil then
      return msg
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return client.name .. cp_str
      end
    end
    return msg
  end

  require('lualine').setup {
        options = {
        theme = lualine_theme,
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'filetype'},
        lualine_y = { activelsp },
        lualine_z = {'progress'}
    },
    inactive_sections = {
    lualine_a = {'branch'},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {'windows'},
    lualine_z = {}
  },
  }
  vim.opt.showmode = false


  -- lua version of copilot
  use {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { auto_trigger = true, enabled = false },
        panel = { auto_refresh = true, enabled = false },
        filetypes = {
          javascript = true, 
          typescript = true, 
          c = true,
          lua = true,
          rust = true,
          python = true,
          ["*"] = false,
        },
      })
    end
  }

  -- changes the way copilot shows suggestions
  use {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
    config = function ()
      require("copilot_cmp").setup()
    end
  }

  -- scrollbar
  
  use("petertriho/nvim-scrollbar")
  require("scrollbar").setup()

  use("onsails/lspkind.nvim")
    
  use {
      'mrcjkb/haskell-tools.nvim',
      requires = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim', -- optional
      },
      branch = '1.x.x', -- recommended
  }

end)



-- the first run will install packer and our plugins
if packer_bootstrap then
  require("packer").sync()
  return
end


-- Set completeopt to have a better completion experience
-- :help completeopt
-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not auto-select, nvim-cmp plugin will handle this for us.
vim.o.completeopt = "menuone,noinsert,noselect"
-- Avoid showing extra messages when using completion
vim.opt.shortmess = vim.opt.shortmess + "c"

local function on_attach(client, buffer)
  -- This callback is called when the LSP is atttached/enabled for this buffer
  -- we could set keymaps related to LSP, etc here.
end

-- Configure LSP through rust-tools.nvim plugin.
-- rust-tools will configure and enable certain LSP features for us.
-- See https://github.com/simrat39/rust-tools.nvim#configuration
local opts = {
  tools = {
    runnables = {
      use_telescope = true,
    },
    inlay_hints = {
      auto = true,
      show_parameter_hints = false,
      parameter_hints_prefix = "",
      other_hints_prefix = "",
    },
  },

  -- all the opts to send to nvim-lspconfig
  -- these override the defaults set by rust-tools.nvim
  -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
  server = {
    -- on_attach is a callback called when the language server attachs to the buffer
    on_attach = on_attach,
    settings = {
      -- to enable rust-analyzer settings visit:
      -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
      ["rust-analyzer"] = {
        -- enable clippy on save
        checkOnSave = {
          command = "clippy",
        },
      },
    },
  },
}

-- local lspconfig = require('lspconfig')
-- lspconfig.pyright.setup {
--                             analysis = {
--                               autoSearchPaths = true,
--                               diagnosticMode = "workspace",
--                               useLibraryCodeForTypes = true,
--                               typeCheckingMode = "off",
--                             } 
--                         }

-- python language server 
require'lspconfig'.pylsp.setup{
  settings = {
    pylsp = {
      plugins = {
        pycodestyle = {
            enabled = false,
        }
      }
    }
  }
}



require("rust-tools").setup(opts)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
end,
})

vim.api.nvim_set_hl(0, "CmpItemKindCopilot", {fg ="#6CC644"})



-- Setup Completion
-- See https://github.com/hrsh7th/nvim-cmp#basic-configuration

local lspkind = require('lspkind')
local cmp = require("cmp")
cmp.setup({
  preselect = cmp.PreselectMode.None,
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {

    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = false,
    }),
  },

  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol', -- show only symbol annotations
      maxwidth = 50, 
      ellipsis_char = '...', 
      symbol_map = {
        Copilot = "",
      },

      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      before = function (entry, vim_item)
        return vim_item
      end
    })
  },

  -- Installed sources
  sources = {
    { name = "copilot" },
    { name = "nvim_lsp" },
    { name = "vsnip" },
    { name = "path" },
    { name = "buffer" },
  },
})

-- keybinds 
vim.api.nvim_set_keymap('n', '<F8>', 'iprintln!("{:?}",);<Esc>hi<Space>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<F8>', 'println!("{:?}",);<Esc>hi<Space>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-s>(', 'c()<Esc>P', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-s>[', 'c[]<Esc>P', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-s>{', 'c{}<Esc>P', { noremap = true, silent = true })


vim.api.nvim_command('highlight clear LspCodeLens')
vim.api.nvim_command('highlight link LspCodeLens Comment')

