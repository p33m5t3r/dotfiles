## some of my dotfiles.

### installation

```
# if u want habamax colorscheme:
cd ~/Downloads
git clone https://github.com/habamax/vim-habamax
cd vim-habamax 
sudo cp vim-habamax /usr/share/nvim/runtime/colors/

# install python stuff
mkvirtualenv neovim3
pip install -r requirements.txt
# <replace paths in .init/lua with correct virtualenv>

---

#### init.lua: neovim config
* pkg manager: packer
* themes: gruvbox/nord 
* LSPs: nvim-lspconfig, rust, analyzer, rust-tools, pylsp
* autocomplete: nvim-cmp
* latex: vimtex
* QoL: nerdtree, lualine, nvim-scrollbar, lspkind, and more...
* ai stuff: copilot.lua, copilot-cmp, vim-ai 



#### zshrc: zshrc
* basic config, a few useful aliases
