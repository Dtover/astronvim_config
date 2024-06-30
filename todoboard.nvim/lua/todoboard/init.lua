-- abbr for todoboard
local tdb = {}
local sections = require "todoboard.sections"
local state = require "todoboard.state"
local util = require "todoboard.util"
local nf = require "notify"

-- window and buffer info
local wb_info = {
  window = -1,
  buffer = -1,
}

local init_cursor_pos = {}
local cursor_poses = {}
local cursor_pos_records = {}

local function is_toboboard() return vim.bo.ft == "todoboard" end

---@param lines (string | table)[]
---@return integer
local function get_max_width(lines)
  local lengths = {}
  for _, line in ipairs(lines) do
    if type(line) == "string" then
      table.insert(lengths, util.len(line))
    elseif type(line) == "table" and line.dir then
      table.insert(lengths, #line.dir + 6)
    end
  end
  return vim.fn.max(lengths)
end

---@class todoboard.ResolvedHighlight
---@field line integer
---@field name string
---@field start integer
---@field length integer

---@param lines (string | table)[]
---@return string[]
---@return todoboard.ResolvedHighlight[]
local function center(lines)
  -- clear cursor records
  init_cursor_pos = {}
  cursor_poses = {}
  cursor_pos_records = {}

  local max_width = get_max_width(lines)
  local center_lines = util.get_padded_table(wb_info.window, #lines)
  local groups = state.config.opts.highlight_groups
  local highlights = {}
  for _, line in ipairs(lines) do
    if type(line) == "string" then
      local left_pad = util.pad_left(wb_info.window, util.len(line))
      local content = string.format("%s%s", left_pad, line)

      table.insert(center_lines, content)

      table.insert(highlights, {
        line = #center_lines - 1,
        name = groups.header,
        start = #left_pad,
        length = #line,
      })
    elseif type(line) == "table" then
      local left_pad = util.pad_left(wb_info.window, max_width)

      -- get init cursor pos
      if init_cursor_pos.y == nil then init_cursor_pos.y = #center_lines + 1 end
      if init_cursor_pos.x == nil then init_cursor_pos.x = #left_pad - 2 end
      -- get positions that cursor can be set at
      cursor_poses[#cursor_poses + 1] = { y = #center_lines + 1, x = #left_pad - 2 }

      local icon = util.get_icon(line.dir)
      local inner_content = string.format("%s %s", icon, line.dir)

      local hotkey_content = string.format("[%s]", line.key)

      local content = string.format(
        "%s%s%s%s",
        left_pad,
        inner_content,
        (" "):rep(max_width - util.len(inner_content) - #hotkey_content),
        hotkey_content
      )

      table.insert(center_lines, content)

      table.insert(highlights, {
        line = #center_lines - 1,
        name = groups.icon,
        start = #left_pad,
        length = #icon + 1,
      })
      table.insert(highlights, {
        line = #center_lines - 1,
        name = groups.directory,
        start = #left_pad + #icon + 1,
        length = #line.dir,
      })
      table.insert(highlights, {
        line = #center_lines - 1,
        name = groups.hotkey,
        start = #content - #hotkey_content,
        length = #hotkey_content,
      })
    else
      error("Unhandled type: " .. type(line))
    end
  end
  return center_lines, highlights
end

---@param key string
---@param dir string
local function map_key(key, dir)
  dir = vim.fs.normalize(dir)
  vim.keymap.set("n", key, function()
    vim.cmd("cd " .. dir)
    vim.cmd "e ."
    state.config.opts.on_load(dir)
  end, { buffer = true })
end

local function get_draw_content()
  local lines = {}

  for _, line in ipairs(state.config.header) do
    table.insert(lines, line)
  end

  if state.config.opts.date_format then table.insert(lines, os.date(state.config.opts.date_format)) end

  local directory_paths = {}
  for _, dir in ipairs(state.config.directories) do
    if type(dir) == "string" then
      table.insert(directory_paths, dir)
    elseif type(dir) == "function" then
      for _, path in ipairs(dir()) do
        table.insert(directory_paths, path)
      end
    end
  end

  local directories = {}
  for i, dir in ipairs(directory_paths) do
    if i <= 24 and util.is_dir(dir) then table.insert(directories, dir) end
  end

  for _, dir in ipairs(directories) do
    local key = util.get_nextKey()
    map_key(key, dir)
    table.insert(lines, { dir = dir, key = key })
    table.insert(lines, "")
  end

  for _, section in ipairs(state.config.footer) do
    if type(section) == "string" then
      if sections[section] ~= nil then
        local line = sections[section]()
        if line ~= nil then table.insert(lines, line) end
      else
        table.insert(lines, section)
      end
    elseif type(section) == "function" then
      local line = section()
      if line ~= nil and type(line) == "string" then table.insert(lines, line) end
    else
      print("Unhandled footer type: " .. type(section))
    end
  end
  return center(lines)
end

-- get cursor position
local function get_cursor(window)
  window = window or vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(window)
  return { y = cursor[1], x = cursor[2] }
end

-- set cursor position
local function set_cursor(window, y, x)
  window = window or vim.api.nvim_get_current_win()
  pcall(vim.api.nvim_win_set_cursor, window, { y, x })
end

-- record cursor pos
local function record_cursor_pos(y, x)
  local i = 0
  for _, pos in pairs(cursor_poses) do
    if pos.y == y then
      i = _
      break
    end
  end
  cursor_pos_records[#cursor_pos_records + 1] = { y = y, x = x, i = i }
end

-- get target cursor pos according to current pos
local function get_target_pos(window, cursor)
  window = window or vim.api.nvim_get_current_win()
  local targetY
  local targetX = cursor_pos_records[#cursor_pos_records].x
  if cursor.y == cursor_pos_records[#cursor_pos_records].y then
    targetY, targetX = cursor_pos_records[#cursor_pos_records].y, cursor_pos_records[#cursor_pos_records].x
  else
    if cursor.y > cursor_poses[#cursor_poses].y then
      targetY = cursor_poses[#cursor_poses].y
    elseif cursor.y < cursor_poses[1].y then
      targetY = cursor_poses[1].y
    else
      local direction = cursor.y - cursor_pos_records[#cursor_pos_records].y > 0
      if direction then
        local index = cursor_pos_records[#cursor_pos_records].i + 1
        targetY = cursor_poses[index].y
      else
        local index = cursor_pos_records[#cursor_pos_records].i - 1
        targetY = cursor_poses[index].y
      end
    end
  end
  return targetY, targetX
end

local function close(ev)
  -- clear all auto cmd
  vim.api.nvim_del_augroup_by_id(ev.group)
end

local function cursor_move()
  -- get cursor pos right after key pressed
  local window = vim.api.nvim_get_current_win()
  if is_toboboard() then
    local cursor = get_cursor(window)
    local targetY, targetX = get_target_pos(window, cursor)

    set_cursor(window, targetY, targetX)
    -- record cursor pos
    record_cursor_pos(targetY, targetX)
  end
end

-- draw and set extmark for highlights
---@param bufnr integer
local function draw(bufnr)
  -- get page content that are going to show
  local center_lines, highlights = get_draw_content()

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, center_lines)

  local ns_id = vim.api.nvim_create_namespace "Todoboard"
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_set_extmark(bufnr, ns_id, hl.line, hl.start, {
      end_col = hl.start + hl.length,
      hl_group = hl.name,
    })
  end
  -- set cursor
  -- record initial cursor pos
  record_cursor_pos(init_cursor_pos.y, init_cursor_pos.x)
  -- set cursor pos
  set_cursor(nil, init_cursor_pos.y, init_cursor_pos.x)
end

local function start()
  local bufnr = wb_info.buffer
  vim.bo[bufnr].modifiable = true
  -- draw page content
  draw(bufnr)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false
end

-- init settings before draw the dashboard
local function init()
  -- page vim settings (for better display)
  vim.opt_local.bufhidden = "wipe"
  vim.opt_local.buflisted = false
  vim.opt_local.matchpairs = ""
  vim.opt_local.swapfile = false
  vim.opt_local.buftype = "nofile"
  vim.opt_local.filetype = "todoboard"
  vim.opt_local.synmaxcol = 0
  vim.opt_local.wrap = false
  vim.opt_local.colorcolumn = ""
  vim.opt_local.foldlevel = 999
  vim.opt_local.foldcolumn = "0"
  vim.opt_local.cursorcolumn = false
  vim.opt_local.cursorline = false
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.list = false
  vim.opt_local.spell = false
  vim.opt_local.signcolumn = "no"

  -- auto command
  local group_id = vim.api.nvim_create_augroup("Todoboard", { clear = false })
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = group_id,
    callback = cursor_move,
  })

  vim.api.nvim_create_autocmd("BufUnload", {
    group = group_id,
    callback = close,
  })

  vim.api.nvim_create_autocmd("SessionLoadPost", {
    group = group_id,
    callback = close,
  })

  if vim.F.if_nil(state.config.opts.redraw_on_resize, true) then
    if vim.version().api_level >= 11 then
      vim.api.nvim_create_autocmd("WinResized", {
        group = group_id,
        callback = start,
      })
    else
      vim.api.nvim_create_autocmd("VimResized", {
        group = group_id,
        pattern = "*",
        callback = function() start() end,
      })
      vim.api.nvim_create_autocmd({ "BufLeave", "WinEnter", "WinNew", "WinClosed" }, {
        group = group_id,
        pattern = "*",
        callback = function() start() end,
      })
    end
  end

  -- init cursor paramter
  init_cursor_pos = {}
  cursor_poses = {}
  cursor_pos_records = {}

  -- record current window and buffer
  wb_info.window = vim.api.nvim_get_current_win()
  wb_info.buffer = vim.api.nvim_get_current_buf()
end

---@class todoboard.UserHighlightGroups
---@field public header? string
---@field public icon? string
---@field public directory? string
---@field public hotkey? string

---@param opts? todoboard.Config
function tdb.setup(opts)
  ---@type todoboard.Config
  local default_config = {
    header = {
      "             ▄▄██████████▄▄             ",
      "             ▀▀▀   ██   ▀▀▀             ",
      "     ▄██▄   ▄▄████████████▄▄   ▄██▄     ",
      "   ▄███▀  ▄████▀▀▀    ▀▀▀████▄  ▀███▄   ",
      "  ████▄ ▄███▀              ▀███▄ ▄████  ",
      " ███▀█████▀▄████▄      ▄████▄▀█████▀███ ",
      " ██▀  ███▀ ██████      ██████ ▀███  ▀██ ",
      "  ▀  ▄██▀  ▀████▀  ▄▄  ▀████▀  ▀██▄  ▀  ",
      "     ███           ▀▀           ███     ",
      "     ██████████████████████████████     ",
      " ▄█  ▀██  ███   ██    ██   ███  ██▀  █▄ ",
      " ███  ███ ███   ██    ██   ███▄███  ███ ",
      " ▀██▄████████   ██    ██   ████████▄██▀ ",
      "  ▀███▀ ▀████   ██    ██   ████▀ ▀███▀  ",
      "   ▀███▄  ▀███████    ███████▀  ▄███▀   ",
      "     ▀███    ▀▀██████████▀▀▀   ███▀     ",
      "       ▀    ▄▄▄    ██    ▄▄▄    ▀       ",
      "             ▀████████████▀             ",
      "                                        ",
    },
    directories = {},
    footer = {},
    opts = {
      date_format = nil,
      on_load = function()
        -- Do nothing
      end,
      highlight_groups = {
        header = "Statement",
        icon = "Type",
        directory = "Delimiter",
        hotkey = "Constant",
      },
      keys = {
        { "n", "<Leader>H", function() require("todoboard").instance() end, { desc = "todoboard" } },
      },
      exclude_filetype = {
        "neo-tree",
      },
      redrew_on_resized = false,
    },
  }
  if opts ~= nil then
    for _, key in pairs(default_config.opts.keys) do
      table.insert(opts.opts.keys, 0, key)
    end
  end
  state.config = vim.tbl_deep_extend("force", default_config, opts or {})
end

function tdb.instance()
  if util.contains(state.config.opts.exclude_filetype, vim.bo.ft) then return end

  local bufnr = vim.api.nvim_get_current_buf()
  -- create or delete buffer
  if is_toboboard() ~= true then
    if not util.is_empty(bufnr) then
      bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(0, bufnr)
    end
  else
    ---@diagnostic disable-next-line: param-type-mismatch
    if not pcall(vim.cmd, "e #") then vim.api.nvim_buf_delete(vim.api.nvim_get_current_buf(), {}) end
    return
  end

  -- some basic settings
  init()

  -- start todoboard
  start()

  -- set key map
  util.sk(state.config.opts.keys)
end

return tdb
