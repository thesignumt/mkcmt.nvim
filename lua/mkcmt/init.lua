local M = {}

-- +-------------------------------------------------------+
-- [                        config                         ]
-- +-------------------------------------------------------+
local config = {
  default_header = "HELLO WORLD",
  cmd = true,
  min_width = 60, -- minimum width of the block
  padding = 10, -- extra spacing around header
  border = "+-+[]+-+",
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
--- Borders..
--- @field border? string

--- Setup MkCmt user preferences
--- @param opts? mkcmt.setup.Opts
--- @return nil
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
---@return nil
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

local function get_borders(str)
  local result = {
    { str:sub(1, 3):byte(1, 3) },
    { str:sub(4, 5):byte(1, 2) },
    { str:sub(6, 8):byte(1, 3) },
  }

  -- convert bytes back to characters
  for _, t in ipairs(result) do
    for j = 1, #t do
      t[j] = string.char(t[j])
    end
  end

  return result
end

---make comment block
---@param header string
---@param opts mkcmt.comment.Opts
---@param data table
---@return nil
local function mkcmt(header, opts, data)
  local get = function(str, default)
    return opts[str] or config[str] or default
  end
  local pre, suf = get_comment_str()
  local min_width = get("min_width")
  ---@cast min_width integer
  local total_width = math.max(min_width, #header + get("padding") * 2)

  local b = get_borders(get("border", "+-+[]+-+"))

  -- Center the header
  local space = total_width - #header - #pre - #suf
  local left = math.floor(space / 2)
  local right = space - left
  local mid = b[2]
  local mdl = ("%s"):rep(7):format(
    pre,
    mid[1],
    (" "):rep(left - #mid[1]),
    header:upper(),
    (" "):rep(right - #mid[2]),
    mid[2],
    suf
  )

  local function mkline(chs)
    local mdls = total_width - #pre - #suf - #chs[1] - #chs[3]
    return ("%s"):rep(5):format(pre, chs[1], chs[2]:rep(mdls), chs[3], suf)
  end
  local ul = mkline(b[1])
  local dl = mkline(b[3])

  local lines = { ul, mdl, dl }
  del_lsel(data.visual)
  vim.api.nvim_put(lines, "l", data.after, true)
end

-- +-------------------------------------------------------+
-- [                        COMMENT                        ]
-- +-------------------------------------------------------+
--- @class mkcmt.comment.Opts
--- @field after? boolean If true insert after cursor (like `p`), or before (like `P`).
--- @field border? string border. e.g. default: '+-+[]+-+'
--- @field header? string set the header
--- @field upper? boolean force upper the header

---make a comment block
---@param opts? mkcmt.comment.Opts
---@return nil
function M.comment(opts)
  opts = opts or {}
  local visual = vim.fn.mode() == "V"
  local after = opts.after == true
  local upper = opts.upper == true

  local data = { after = after, visual = visual, upper = upper }

  if opts.header then
    mkcmt(opts.header, opts, data)
  else
    vim.ui.input(
      { prompt = upper and "(upper) " or "" .. "header: " },
      function(input)
        if not input then
          return
        end

        local header = input == "" and config.default_header or input
        mkcmt(header, opts, data)
      end
    )
  end
end

return M
