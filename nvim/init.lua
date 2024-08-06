
---------------------- baseline options ----------------------
local home = os.getenv("HOME")
vim.api.nvim_command('set ignorecase')
vim.api.nvim_command('set hidden')
vim.api.nvim_command('set nu rnu')
vim.api.nvim_command('set autoindent')
vim.api.nvim_command('set mouse=a')
vim.api.nvim_command('set shiftwidth=4')
vim.api.nvim_command('set softtabstop=4')
vim.api.nvim_command('set expandtab')
vim.api.nvim_command('set backspace=indent,eol,start')
vim.api.nvim_set_option("clipboard","unnamedplus")


---------------------- LaTeX config -------------------------
vim.g.vimtex_view_method = 'zathura'
vim.g.tex_conceal = 'abdmg'
vim.api.nvim_command('set conceallevel=2')


---------------------- python config ------------------------
vim.g.python3_host_prog = home .. '/.virtualenvs/general/bin/python3'
vim.g.python_host_prog = home .. '/.virtualenvs/general/bin/python3'

----------------------- keybindings -------------------------
vim.api.nvim_command('nnoremap <silent> <leader>e :lua vim.diagnostic.open_float()<CR>')
vim.api.nvim_command("nnoremap <leader>r :!./run.sh<CR>")
vim.api.nvim_set_keymap('v', '<C-s>(', 'c()<Esc>P', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-s>[', 'c[]<Esc>P', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-s>{', 'c{}<Esc>P', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<C-s>m', 'c$$<Esc>P', { noremap = true, silent = true })
vim.api.nvim_command('highlight clear LspCodeLens')
vim.api.nvim_command('highlight link LspCodeLens Comment')

---------------------- misc options ------------------------
vim.g.NERDTreeWinSize=15
vim.o.completeopt = "menuone,noinsert,noselect"
    -- :help completeopt
    -- menuone: popup even when there's only one match
    -- noinsert: Do not insert text until a selection is made
    -- noselect: Do not auto-select, nvim-cmp plugin will handle this for us.
vim.opt.shortmess = vim.opt.shortmess + "c"
    -- Avoid showing extra messages when using completion
-- vim.api.nvim_set_hl(0, "CmpItemKindCopilot", {fg ="#6CC644"})

---------------------- package manager ---------------------
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git", "clone", "--depth", "1", 
                "https://github.com/wbthomason/packer.nvim",
                install_path
    })
    vim.cmd([[packadd packer.nvim]])
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()


---------------------- custom plugin ----------------------
require('vimiq').setup({
    python_path = home .. "/.virtualenvs/general/bin/python"
})

---------------------- package config ----------------------
require("packer").startup(function(use)
  use("wbthomason/packer.nvim")             -- package manager
  use("ellisonleao/gruvbox.nvim")           -- colorscheme
  require("gruvbox").setup({                -- colorscheme
    palette_overrides = {light0 = "#fdf6e3"}
  })

  use("neovim/nvim-lspconfig")              -- LSP provider
  use{                                      -- lsp progress bar
    "j-hui/fidget.nvim",
    tag='legacy',
    config = function()
      require("fidget").setup()
    end
  }

  use("hrsh7th/nvim-cmp")                   -- autocomplete
  use({
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    after = { "hrsh7th/nvim-cmp" },
    requires = { "hrsh7th/nvim-cmp" },
  })
  use('hrsh7th/vim-vsnip')

  use("simrat39/rust-tools.nvim")           -- ?
  use("nvim-lua/popup.nvim")                -- ?
  use("nvim-lua/plenary.nvim")              -- ?
  use("nvim-telescope/telescope.nvim")      -- ?
  use("madox2/vim-ai")                      -- ?
  use("onsails/lspkind.nvim")               -- lsp completion icons
  use("preservim/nerdtree")                 -- file explorer
  use("lervag/vimtex")                      -- TeX compilation
  use {                                     -- status bar
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  -- use {                                     -- copilot
  --   "zbirenbaum/copilot.lua",
  --   cmd = "Copilot",
  --   event = "InsertEnter",
  --   config = function()
  --   enabled = true,
  --     require("copilot").setup({
  --       suggestion = { auto_trigger = true, enabled = false },
  --       panel = { auto_refresh = true, enabled = false },
  --       filetypes = { ["*"] = false },
  --     })
  --   end
  -- }

  -- use {                                     -- copilot completion 
  --   "zbirenbaum/copilot-cmp",
  --   after = { "copilot.lua" },
  --   config = function ()
  --     require("copilot_cmp").setup()
  --   end
  -- }

  use({                                     -- scroll bar
    "petertriho/nvim-scrollbar",
    config = function()
      require("scrollbar").setup()
    end
  })

  use {                                     -- haskell
      'mrcjkb/haskell-tools.nvim',
      requires = {
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',    -- (optional)
      },
      branch = '1.x.x',
  }

  ------------------------ lsp info box -------------------------
  -- local function has_copilot(clients)       -- lsp info panel
  --   local has_copilot = false
  --   for _, client in ipairs(clients) do
  --     if client.name == "copilot" then
  --       has_copilot = true
  --     end
  --   end
  --   return has_copilot
  -- end


  -- local function activelsp()
  --   if not vim then
  --     return "ACTIVELSP::ERR"
  --   end

  --   local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
  --   local clients = vim.lsp.get_active_clients()    local cp_str = " (X)"

  --   if has_copilot(clients) then
  --     cp_str = " (AI)"
  --   end
  --   local msg = 'No Lsp' .. cp_str

  --   if next(clients) == nil then
  --     return msg
  --   end
  --   for _, client in ipairs(clients) do
  --     local filetypes = client.config.filetypes
  --     if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
  --       return client.name .. cp_str
  --     end
  --   end
  --   return msg
  -- end

  ------------------------ colorschemes ------------------------
  local colorconfig, os_ccfg = "default", os.getenv("COLORCONFIG")
  if os_ccfg then
      colorconfig = os_ccfg
  end

  use("rafamadriz/neon")
  local lualine_theme = "neon"
  if colorconfig == "default" then
      vim.o.background = "dark"
      vim.cmd([[colorscheme darktheme]])

  elseif colorconfig == "light" then
      vim.o.background = "light"
      lualine_theme = "gruvbox_light"
      vim.cmd([[colorscheme gruvbox]])
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

  if vim.fn.has("termguicolors") then
    vim.opt.termguicolors = true
  end

end)

if packer_bootstrap then
  require("packer").sync()
  return
end


------------------------ LSP config ----------------------------
local lspconfig = require('lspconfig')

-- rust
require("rust-tools").setup({
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
  server = {
    on_attach = function(client, buffer)
    end,
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy",
        },
      },
    },
  },
})

-- python
lspconfig.pylsp.setup{
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

-- terraform
lspconfig.terraformls.setup{}
vim.api.nvim_create_autocmd({"BufWritePre"}, {
  pattern = {"*.tf", "*.tfvars"},
  callback = function()
    vim.lsp.buf.format()
  end,
})


-- golang
lspconfig.gopls.setup{
    cmd = {"gopls", "serve"},
    filetypes = {"go", "gomod"},
    root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
        },
        staticcheck = true,
      },
    },
}

-- ocaml
lspconfig.ocamllsp.setup{}

-- clangd
lspconfig.clangd.setup{
    cmd = {"clangd"},
    filetypes = {"c", "cu", "cuda", "cpp", "objc", "objcpp"},
    root_dir = lspconfig.util.root_pattern("compile_commands.json", ".git"),
    settings = {
        clangd = {
            arguments = {"--background-index", "--clang-tidy"},
        },
    },
}

-- haskell
lspconfig.hls.setup{}


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
      -- symbol_map = {
      --   Copilot = "",
      -- },

      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      before = function (entry, vim_item)
        return vim_item
      end
    })
  },

  -- Installed sources
  sources = {
    -- { name = "copilot" },
    { name = "nvim_lsp" },
    { name = "vsnip" },
    { name = "path" },
    { name = "buffer" },
  },
})


---------------------- live reload buffer ----------------------
local function reload_current_buffer()
  local current_file = vim.fn.expand('%:p')
  if vim.fn.fnamemodify(current_file, ':e') == 'lua' then
    vim.cmd('luafile ' .. current_file)
    print('Reloaded Lua file: ' .. current_file)
  else
    vim.cmd('source ' .. current_file)
    print('Reloaded file: ' .. current_file)
  end
end

-- Create a Neovim command to reload the current buffer
vim.api.nvim_create_user_command("Reload", reload_current_buffer, {})

-- Create an alias 'RL' for the Reload command
vim.cmd('command! -nargs=0 RL Reload')





