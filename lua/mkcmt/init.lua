local M = {}
local config = {
  default_title = "HELLO WORLD",
  cmd = true,
  min_width = 60, -- minimum width of the block
  padding = 10, -- extra spacing around title
  chs = {
    m = { l = "[", r = "]" },
    c = { l = "+", r = "+" },
  },
}

--- @class mkcmt.setup.Opts
--- @inlinedoc
---
--- The default title when no title is provided when there is a prompt.
--- @field default_title? string
---
--- If true will make a user command MkCmt
--- @field cmd? boolean
---
--- Minimum width of the block
--- @field min_width? integer
---
--- Extra spacing around title
--- @field padding? integer
---
--- custom characters
--- @field chs? table

--- Setup MkCmt user preferences
--- @param opts? mkcmt.setup.Opts
function M.setup(opts)
  for k, v in pairs(opts or {}) do
    config[k] = v
  end

  if config.cmd then
    vim.api.nvim_create_user_command("MkCmt", M.comment, {})
  end
end

local function get_comment_str()
  local cs = vim.bo.commentstring or "# %s"
  local pre = cs:match("^(.*)%%s") or ""
  local suf = cs:match("%%s(.*)$") or ""
  return pre, suf
end

--- @class mkcmt.comment.Opts
--- @field title? string set the title

---make a comment block
---@param opts? mkcmt.comment.Opts
function M.comment(opts)
  local title = (opts or {}).title or vim.fn.input("title: ")
  title = title == "" and config.default_title or title

  local pre, suf = get_comment_str()
  local chs = config.chs
  local total_width = math.max(config.min_width, #title + config.padding * 2)

  -- Center the title
  local space = total_width - #title - #pre - #suf - 4
  local left = math.floor(space / 2)
  local right = space - left
  local mdl = ("%s%s%s  %s  %s%s%s"):format(
    pre,
    chs.m.l,
    (" "):rep(left - #chs.m.l),
    title,
    (" "):rep(right - #chs.m.r),
    chs.m.r,
    suf
  )

  local dashes = total_width - #pre - #suf - #chs.c.l - #chs.c.r
  local line = ("%s")
    :rep(5)
    :format(pre, chs.c.l, ("-"):rep(dashes), chs.c.r, suf)
  local lines = { line, mdl, line }

  -- local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_put(lines, "l", true, true)
end

return M
