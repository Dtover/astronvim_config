-- config for neovide
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
