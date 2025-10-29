local api = vim.api
local Config = require("mkcmt.Config") ---@type MkcmtConfig
local Utils = require("mkcmt.utils")

local M = {}

--- Setup MkCmt user preferences
--- @param opts? MkcmtConfig
--- @return nil
function M.setup(opts)
  Config = vim.tbl_extend("force", Config, opts or {})

  vim.validate("default_header", Config.default_header, "string", true)
  vim.validate("cmd", Config.cmd, "boolean", true)
  vim.validate("min_width", Config.min_width, "number", true)
  vim.validate("padding", Config.padding, "number", true)
  vim.validate("border", Config.border, function(v)
    return type(v) == "string" and #v == 8
  end, true, "border must be a string of length 8")

  if Config.cmd then
    api.nvim_create_user_command(
      "MkCmt",
      M.comment,
      { desc = "Make comment block" }
    )
  end
end

---make comment block
---@param header string
---@param opts mkcmt.comment.Opts
---@param data table
---@return nil
local function mkcmt(header, opts, data)
  local function get(opt, fallback)
    return vim.F.if_nil(opts[opt], Config[opt]) or fallback
  end
  local pre, suf = Utils:get_cmt_str()
  local min_width = get("min_width")
  local total_width = math.max(min_width, #header + get("padding") * 2)

  local b = Utils:get_borders(get("border", "+-+[]+-+"))

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
  Utils:del_lsel(data.visual)
  api.nvim_put(lines, "l", data.after, true)
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
        local header = input == "" and Config.default_header or input
        mkcmt(header, opts, data)
      end
    end)
  end
end

return M
