local M = {}

-- TODO: make custom borders

-- +-------------------------------------------------------+
-- [                        config                         ]
-- +-------------------------------------------------------+
local config = {
  default_header = "HELLO WORLD",
  cmd = true,
  min_width = 60, -- minimum width of the block
  padding = 10, -- extra spacing around header
  chs = {
    m = { l = "[", r = "]" },
    c = { l = "+", r = "+" },
  },
}

-- +-------------------------------------------------------+
-- [                         setup                         ]
-- +-------------------------------------------------------+

--- @class mkcmt.setup.Opts
--- @inlinedoc
---
--- The default header when no header is provided when there is a prompt.
--- @field default_header? string
---
--- If true will make a user command MkCmt
--- @field cmd? boolean
---
--- Minimum width of the block
--- @field min_width? integer
---
--- Extra spacing around header
--- @field padding? integer
---
--- custom characters
--- @field chs? table|string

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

-- +-------------------------------------------------------+
-- [                       functions                       ]
-- +-------------------------------------------------------+

---delete last selection
---@param visual boolean
local function del_lsel(visual)
  if not visual then
    return
  end
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")

  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, {})
end

local function get_comment_str()
  local cs = vim.bo.commentstring or "# %s"
  local pre = cs:match("^(.*)%%s") or ""
  local suf = cs:match("%%s(.*)$") or ""
  return pre, suf
end

---make comment block
---@param header string
---@param after boolean
---@param visual boolean
local function mkcmt(header, after, visual)
  local pre, suf = get_comment_str()
  local chs = config.chs
  local total_width = math.max(config.min_width, #header + config.padding * 2)

  -- Center the header
  local space = total_width - #header - #pre - #suf
  local left = math.floor(space / 2)
  local right = space - left
  local mdl = ("%s"):rep(7):format(
    pre,
    chs.m.l,
    (" "):rep(left - #chs.m.l),
    header,
    (" "):rep(right - #chs.m.r),
    chs.m.r,
    suf
  )

  local dashes = total_width - #pre - #suf - #chs.c.l - #chs.c.r
  local line = ("%s")
    :rep(5)
    :format(pre, chs.c.l, ("-"):rep(dashes), chs.c.r, suf)
  local lines = { line, mdl, line }

  del_lsel(visual)
  vim.api.nvim_put(lines, "l", after, true)
end

-- +-------------------------------------------------------+
-- [                        COMMENT                        ]
-- +-------------------------------------------------------+
--- @class mkcmt.comment.Opts
--- @field after? boolean If true insert after cursor (like `p`), or before (like `P`).
--- @field header? string set the header

---make a comment block
---@param opts? mkcmt.comment.Opts
function M.comment(opts)
  opts = opts or {}
  local after = opts.after == true
  local visual = vim.fn.mode() == "V"

  if opts.header then
    mkcmt(opts.header, after, visual)
  else
    vim.ui.input({ prompt = "header: " }, function(input)
      if not input then
        return
      end

      mkcmt(input == "" and config.default_header or input, after, visual)
    end)
  end
end

return M
