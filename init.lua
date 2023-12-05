return {
  -- Configure AstroNvim updates
  updater = {
    remote = "origin", -- remote to use
    channel = "stable", -- "stable" or "nightly"
    version = "latest", -- "latest", tag name, or regex search like "v1.*" to only do updates before v2 (STABLE ONLY)
    branch = "nightly", -- branch name (NIGHTLY ONLY)
    commit = nil, -- commit hash (NIGHTLY ONLY)
    pin_plugins = nil, -- nil, true, false (nil will pin plugins on stable only)
    skip_prompts = false, -- skip prompts about breaking changes
    show_changelog = true, -- show the changelog after performing an update
    auto_quit = false, -- automatically quit the current session after a successful update
    remotes = { -- easily add new remotes to track
      --   ["remote_name"] = "https://remote_url.come/repo.git", -- full remote url
      --   ["remote2"] = "github_user/repo", -- GitHub user/repo shortcut,
      --   ["remote3"] = "github_user", -- GitHub user assume AstroNvim fork
    },
  },

  -- Set colorscheme to use
  colorscheme = "astrodark",

  -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
  diagnostics = {
    virtual_text = true,
    underline = true,
  },

  lsp = {
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = true, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      -- "pyright"
    },
  },

  -- Configure require("lazy").setup() options
  lazy = {
    defaults = { lazy = true },
    performance = {
      rtp = {
        -- customize default disabled vim plugins
        disabled_plugins = { "tohtml", "gzip", "matchit", "zipPlugin", "netrwPlugin", "tarPlugin" },
      },
    },
  },

  -- This function is run last and is a good place to configuring
  -- augroups/autocommands and custom filetypes also this just pure lua so
  -- anything that doesn't fit in the normal config locations above can go here
  polish = function()
    -- Set up custom filetypes
    -- vim.filetype.add {
    --   extension = {
    --     foo = "fooscript",
    --   },
    --   filename = {
    --     ["Foofile"] = "fooscript",
    --   },
    --   pattern = {
    --     ["~/%.config/foo/.*"] = "fooscript",
    --   },
    -- }

    -- set lazyredraw to some file type
    if vim.filetype == 'ass' then
      vim.opt.lazyredraw = true;
    end

    -- md-img-paste
    vim.g.mdip_imgdir = 'images'

    -- config for neovide
    local ime_input = vim.api.nvim_create_augroup("ime_input", { clear = false})

    local function set_ime(args)
      if args.event:match("Enter$") then
          vim.g.neovide_input_ime = true
      else
          vim.g.neovide_input_ime = false
      end
    end

    vim.api.nvim_create_autocmd({ "InsertLeave", "InsertEnter" }, {
        group = ime_input,
        pattern = "*",
        callback = set_ime
    })

    vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
        group = ime_input,
        pattern = "[/\\?]",
        callback = set_ime
    })

    local function alpha()
      return string.format("%x", math.floor(255 * (vim.g.transparency or 0.8)))
    end

    if vim.g.neovide then
      vim.o.guifont="ComicShannsMono Nerd Font:h14,YouYuan:h14"
      -- vim.o.guifont="DejaVuSansM Nerd Font"
      vim.g.neovide_transparency = 0.98
      vim.g.transparency = 0.98
      vim.g.neovide_backgroud_color = "#0f1117" .. alpha()

      vim.g.neovide_floating_blur_amount_x = 10.0
      vim.g.neovide_floating_blur_amount_y = 10.0
      vim.g.neovide_scroll_animation_length = 0.1
      vim.g.neovide_confirm_quit = false
      vim.g.neovide_profiler = false
      vim.g.neovide_input_ime = true

      vim.g.neovide_scroll_animation_far_lines = 1
      vim.g.neovide_cursor_vfx_mode = "ripple"

      vim.g.neovide_cursor_vfx_opacity = 100
    end
  end,
}
