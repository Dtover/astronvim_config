---@class todoboard.HighlightGroups
---@field public header string
---@field public icon string
---@field public directory string
---@field public hotkey string

---@class todoboard.Config.opts
---@field public date_format? string
---@field public highlight_groups todoboard.HighlightGroups
---@field public on_load fun(dir: string)
---@field public keys (table)
---@field public redrew_on_resized boolean
---@field public exclude_filetype (table)

---@class todoboard.Config
---@field public header string[]
---@field public directories (string | fun(): string[])[]
---@field public footer (string | fun(): string?)[]
---@field public opts(table) todoboard.Config.opts

---@class todoboard.State
---@field config todoboard.Config
local state = {}
return state
