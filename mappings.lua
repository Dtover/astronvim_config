-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
return {
  -- first key is the mode
  n = {
    -- second key is the lefthand side of the map
    -- ["<leader>r"] = { ":MarkdownPreview<cr>", desc = "run markdown-preview" },
    ["<leader>r"] = {
      function()
        if vim.bo.filetype == "markdown" then vim.cmd "MarkdownPreviewToggle" end
      end,
      desc = "toggle markdown-preview",
    },
    -- cd to nvim config directory
    ["<leader>A"] = {
      function()
        if vim.fn.has "win32" == 1 or vim.fn.has "win64" == 1 then
          vim.cmd "cd C:\\Users\\Mycroft\\AppData\\Local\\nvim"
        elseif vim.fn.has "unix" == 1 then
          vim.cmd "cd ~/.config/nvim"
        end
      end,
      desc = "change to astro nvim config dir",
    },

    ["<leader>a"] = {
      function()
        if vim.fn.has "win32" == 1 or vim.fn.has "win64" == 1 then
          vim.cmd "cd C:\\Users\\Mycroft\\AppData\\Local\\nvim\\lua\\user"
        elseif vim.fn.has "unix" == 1 then
          vim.cmd "cd ~/.config/nvim/lua/user"
        end
      end,
      desc = "change to user config dir",
    },

    ["<leader><enter>"] = { ":nohlsearch<cr>", desc = "set no hightlight search" },

    -- mappings seen under group name "Buffer"
    ["<leader>bD"] = {
      function()
        require("astronvim.utils.status").heirline.buffer_picker(
          function(bufnr) require("astronvim.utils.buffer").close(bufnr) end
        )
      end,
      desc = "Pick to close",
    },
    -- tables with the `name` key will be registered with which-key if it's installed
    -- this is useful for naming menus
    ["<leader>b"] = { name = "Buffers" },
    -- quick save
    ["<C-s>"] = { ":w!<cr>", desc = "Save File" }, -- change description but the same command

    -- movement
    ["J"] = { "5gj", desc = "quick move down" },
    ["K"] = { "5gk", desc = "quick move up" },
    ["H"] = { "^", desc = "move the cursor to start of the line" },
    ["L"] = { "$", desc = "move the cursor to end of the line" },
    ["gw"] = { "*", desc = "map to *" },
    ["gW"] = { "#", desc = "map to #" },

    -- buffer operation
    ["Q"] = {
      function() require("astronvim.utils.buffer").close() end,
      desc = "close current buffer",
    },
    -- switch buffer
    ["tl"] = {
      function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
      desc = "Next buffer",
    },
    ["th"] = {
      function() require("astronvim.utils.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
      desc = "Previous buffer",
    },

    -- something else
    ["<leader>P"] = {
      function()
        if vim.bo.filetype == "markdown" then
          local cword = vim.fn.expand "<cword>"
          if cword ~= "" then vim.api.nvim_command "normal! o" end
          vim.cmd "call mdip#MarkdownClipboardImage()"
        end
      end,
      desc = "paste image in md",
    },
  },
  t = {
    -- setting a mapping to false will disable it
    -- ["<esc>"] = false,
  },
  v = {
    ["J"] = { "5gj", desc = "quick move down" },
    ["K"] = { "5gk", desc = "quick move up" },
    ["H"] = { "^", desc = "move the cursor to start of the line" },
    ["L"] = { "$", desc = "move the cursor to end of the line" },
  },
}
