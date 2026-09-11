-- Bridge Neovim to existing Vim configuration
vim.opt.rtp:prepend(vim.fn.expand("~/.vim"))
vim.opt.rtp:append(vim.fn.expand("~/.vim/after"))
vim.o.packpath = vim.o.runtimepath

-- Disable providers for unused language runtimes
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Configure Python 3 provider if mise or python3 is available
if vim.fn.executable("mise") == 1 then
  local mise_python = vim.fn.trim(vim.fn.system("mise which python3"))
  if vim.fn.filereadable(mise_python) == 1 then
    vim.g.python3_host_prog = mise_python
  end
elseif vim.fn.executable("python3") == 1 then
  vim.g.python3_host_prog = vim.fn.exepath("python3")
end

-- Source ~/.vimrc to initialize vim-plug and settings before lazy.nvim
local vimrc = vim.fn.expand("~/.vimrc")
if vim.fn.filereadable(vimrc) == 1 then
  vim.cmd.source(vimrc)
end

-- Bootstrap and configure lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) and #vim.api.nvim_list_uis() > 0 then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
end
if vim.uv.fs_stat(lazypath) then
  vim.opt.rtp:prepend(lazypath)
  local ok, lazy = pcall(require, "lazy")
  if ok then
    lazy.setup({
      spec = {
        {
          "rebelot/kanagawa.nvim",
          commit = "bb85e4bfc8d89b0e62c8fa53ccdd13d12e2f77b3",
          lazy = false,
          priority = 1000,
          config = function()
            vim.cmd.colorscheme("kanagawa")
          end,
        },
        {
          "nvim-lua/plenary.nvim",
          version = "v0.1.4",
          lazy = true,
        },
        {
          "a-usr/xml2lua.nvim",
          commit = "c5fa33ad038958e9592df06e8ca6a88f4e7543aa",
          lazy = true,
        },
        {
          "kruton/nvim-lambdamoo",
          version = "v0.1.5",
          dependencies = {
            "nvim-lua/plenary.nvim",
            "a-usr/xml2lua.nvim",
          },
          main = "lambdamoo",
          opts = {
            connections = {
              {
                authority = "waterpoint",
                endpoint = "https://moo.waterpoint.org/dav/",
              },
              {
                authority = "codepoint",
                endpoint = "https://moo.codepoint.the-b.org/dav/",
              },
            },
          },
        },
        {
          "MysticalDevil/inlay-hints.nvim",
          version = "v0.0.7",
          opts = {
            commands = { enable = true },
            autocmd = { enable = true },
          },
        },
      },
      install = {
        missing = #vim.api.nvim_list_uis() > 0,
      },
      performance = {
        reset_packpath = false,
        rtp = {
          reset = false,
        },
      },
    })
  end
end

-- Set up LSP keybindings on attach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
  callback = function(ev)
    local opts = { buffer = ev.buf, silent = true }
    -- Go to definition (resolves remote verbs over moo://)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    -- Show hover / verb definition origins
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  end,
})
