-- autocmd
local group_id = vim.api.nvim_create_augroup("Todoboard", { clear = true })
vim.api.nvim_create_autocmd("VimEnter", {
  group = group_id,
  callback = function()
    if vim.fn.argc() == 0 then require("todoboard").instance() end
  end,
})

vim.api.nvim_create_user_command("Todoboard", function() require("todoboard").instance() end, {})
