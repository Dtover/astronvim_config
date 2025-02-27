-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 500, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "auto", -- sets vim.opt.signcolumn to auto
        wrap = false, -- sets vim.opt.wrap
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        mdip_use_hexo = 1,
        mdip_imgname_input = 0,
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map
        ["<leader>r"] = {
          function()
            if vim.bo.filetype == "markdown" then vim.cmd "MarkdownPreviewToggle" end
          end,
          desc = "toggle markdown-preview",
        },

        ["<leader>a"] = {
          function()
            if vim.fn.has "win32" == 1 or vim.fn.has "win64" == 1 then
              vim.cmd("cd " .. os.getenv "UserProfile" .. "\\AppData\\Local\\nvim\\lua\\user")
            elseif vim.fn.has "unix" == 1 then
              vim.cmd "cd ~/.config/nvim"
            end
          end,
          desc = "change to user config dir",
        },

        ["<leader>A"] = {
          function()
            if vim.fn.has "unix" == 1 then vim.cmd("cd " .. vim.fn.expand "%:h") end
          end,
          desc = "change to user config dir",
        },

        ["<leader><enter>"] = { ":nohlsearch<cr>", desc = "set no hightlight search" },

        -- navigate buffer tabs with `H` and `L`
        ["tl"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["th"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bD"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Pick to close",
        },
        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        ["<Leader>b"] = { desc = "Buffers" },
        -- quick save
        -- ["<C-s>"] = { ":w!<cr>", desc = "Save File" },  -- change description but the same command

        -- movement
        -- ["J"] = { "5gj", desc = "quick move down" },
        -- ["K"] = { "5gk", desc = "quick move up" },
        ["H"] = { "^", desc = "move the cursor to start of the line" },
        ["L"] = { "$", desc = "move the cursor to end of the line" },
        ["gw"] = { "*", desc = "map to *" },
        ["gW"] = { "#", desc = "map to #" },

        -- buffer operation
        ["Q"] = { ":wq<CR>", desc = "write and quit" },
        -- switch buffer
        -- ["tl"] = {
        --   function() require("astronvim.utils.buffer").nav(vim.v.count > 0 and vim.v.count or 1) end,
        --   desc = "Next buffer",
        -- },
        -- ["th"] = {
        --   function() require("astronvim.utils.buffer").nav(-(vim.v.count > 0 and vim.v.count or 1)) end,
        --   desc = "Previous buffer",
        -- },
      },
      t = {
        -- setting a mapping to false will disable it
        -- ["<esc>"] = false,
      },

      v = {
        -- ["J"] = { "5gj", desc = "quick move down" },
        -- ["K"] = { "5gk", desc = "quick move up" },
        ["H"] = { "^", desc = "move the cursor to start of the line" },
        ["L"] = { "$", desc = "move the cursor to end of the line" },
      },
    },
  },
}
