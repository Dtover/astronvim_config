-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set up custom filetypes
vim.filetype.add {
  extension = {
    foo = "fooscript",
  },
  filename = {
    ["Foofile"] = "fooscript",
  },
  pattern = {
    ["~/%.config/foo/.*"] = "fooscript",
  },
}

-- set lazyredraw to some file type
if vim.filetype == "ass" then vim.opt.lazyredraw = true end

-- md-img-paste
vim.g.mdip_imgdir = "images"

-- config for neovide
local ime_input = vim.api.nvim_create_augroup("ime_input", { clear = false })

local function set_ime(args)
  if args.event:match "Enter$" then
    vim.g.neovide_input_ime = true
  else
    vim.g.neovide_input_ime = false
  end
end

vim.api.nvim_create_autocmd({ "InsertLeave", "InsertEnter" }, {
  group = ime_input,
  pattern = "*",
  callback = set_ime,
})

vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
  group = ime_input,
  pattern = "[/\\?]",
  callback = set_ime,
})

local function alpha() return string.format("%x", math.floor(255 * (vim.g.transparency or 0.8))) end

if vim.g.neovide then
  vim.o.guifont = "ComicShannsMono Nerd Font:h16"
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
