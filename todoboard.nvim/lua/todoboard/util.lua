local M = {}
local easyPressKeySeq = {
  "a",
  "s",
  "d",
  "f",
  "g",
  "h",
  "l",
  "q",
  "w",
  "e",
  "r",
  "t",
  "y",
  "u",
  "i",
  "o",
  "p",
  "z",
  "x",
  "c",
  "v",
  "b",
  "n",
  "m",
}
local usedKeySeq = {}

function M.get_nextKey()
  table.insert(usedKeySeq, easyPressKeySeq[#usedKeySeq + 1])
  return usedKeySeq[#usedKeySeq]
end

---@param value string
---@return integer
function M.len(value) return vim.api.nvim_strwidth(value) end

---@param height integer
---@return string[]
function M.get_padded_table(window, height)
  local padded_table = {}
  local extra_lines = vim.api.nvim_win_get_height(window) - height
  local top_pad = math.floor(extra_lines / 2) - 2
  for _ = 1, top_pad do
    table.insert(padded_table, "")
  end
  return padded_table
end

---@param width integer
---@return string
function M.pad_left(window, width)
  local extra_space = vim.api.nvim_win_get_width(window) - width
  local left_pad = math.floor(extra_space / 2) - 2
  if left_pad > 0 and width > 0 then
    return (" "):rep(left_pad)
  else
    return ""
  end
end

---@param dir string
---@return boolean
function M.is_dir(dir)
  local path = vim.fs.normalize(dir)
  return vim.fn.isdirectory(path) == 1
end

---@param dir string
---@return string
function M.get_icon(dir)
  if M.is_dir(dir .. "/.git") then
    return ""
  else
    return ""
  end
end

---@param table table
---@param element string|table
---@return boolean
function M.contains(table, element)
  for _, value in pairs(table) do
    if value == element then return true end
  end
  return false
end

---@param bufnr integer
---@return boolean
function M.is_empty(bufnr)
  local num_lines = vim.api.nvim_buf_line_count(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  return num_lines == 1 and lines[1] == ""
end

function M.sk(keys)
  for _, key in pairs(keys) do
    if key.disable == true then
      vim.keymap.del(key[1], key[2])
    else
      vim.keymap.set(key[1], key[2], key[3], key[4])
    end
  end
end

return M
