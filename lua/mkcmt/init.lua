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
  config = vim.tbl_extend("force", config, opts or {})

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

  vim.api.nvim_buf_set_lines(
    0,
    vim.fn.line("'<") - 1,
    vim.fn.line("'>"),
    false,
    {}
  )
end

local function get_comment_str()
  local cs = vim.bo.commentstring or "# %s"
  local pre, suf = cs:match("^(.*)%%s(.*)$")
  return pre or "", suf or ""
end

local function get_borders(str)
  return {
    { str:sub(1, 1), str:sub(2, 2), str:sub(3, 3) },
    { str:sub(4, 4), str:sub(5, 5) },
    { str:sub(6, 6), str:sub(7, 7), str:sub(8, 8) },
  }
end

---make comment block
---@param header string
---@param opts mkcmt.comment.Opts
---@param data table
---@return nil
local function mkcmt(header, opts, data)
  local function get(opt, fallback)
    return vim.F.if_nil(opts[opt], config[opt]) or fallback
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
  local mdl = table.concat({
    pre,
    mid[1],
    (" "):rep(left - #mid[1]),
    data.upper and header:upper() or header,
    (" "):rep(right - #mid[2]),
    mid[2],
    suf,
  })

  local function mkline(chs)
    local mdls = total_width - #pre - #suf - #chs[1] - #chs[3]
    return table.concat({ pre, chs[1], chs[2]:rep(mdls), chs[3], suf })
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
  local prompt = (upper and "(upper) " or "") .. "header: "

  if opts.header then
    mkcmt(opts.header, opts, data)
  else
    vim.ui.input({ prompt = prompt }, function(input)
      if input then
        mkcmt(input == "" and config.default_header or input, opts, data)
      end
    end)
  end
end

return M
