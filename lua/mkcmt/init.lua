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
    return type(v) == "string" and #v == 8 and not v:find("%s")
  end, true, "border must be a string of length 8")

  vim.validate("oneline", Config.oneline, "boolean", true)
  vim.validate("oneline_char", Config.oneline_char, "string", true)

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
    return opts[opt] ~= nil and opts[opt] or Config[opt] or fallback
  end
  local cfg = {
    min_width = get("min_width") or vim.api.nvim_win_get_width(0),
    padding = get("padding"),
    border = get("border", "+-+[]+-+"),
    oneline_char = get("oneline_char"),
  }

  local pre, suf = Utils:get_cmt_str()
  local b = Utils:get_borders(cfg.border)

  -- oneline mode (ignore header entirely)
  if data.oneline then
    local fill = cfg.oneline_char or b[2][1]
    local width = cfg.min_width

    local line = table.concat({
      pre,
      fill:rep(width),
      suf,
    })

    Utils:del_lsel(data.visual)
    api.nvim_put({ line }, "l", data.put_after, true)
    return
  end

  local min_width = cfg.min_width
  local width = vim.fn.strdisplaywidth(header)
  local total_width = math.max(min_width, width + cfg.padding * 2)

  -- Center the header
  local space = total_width - #header
  local left = math.floor(space / 2)
  local right = space - left
  local mid = b[2]

  local lpad = math.max(0, left - #mid[1])
  local rpad = math.max(0, right - #mid[2])

  local mdl = table.concat({
    pre,
    mid[1],
    (" "):rep(lpad),
    data.upper and header:upper() or header,
    (" "):rep(rpad),
    mid[2],
    suf,
  })

  local function mkline(chs)
    local inner = total_width - #chs[1] - #chs[3]
    return pre .. chs[1] .. chs[2]:rep(inner) .. chs[3] .. suf
  end

  local ul = mkline(b[1])
  local dl = mkline(b[3])

  local lines = { ul, mdl, dl }
  Utils:del_lsel(data.visual)
  api.nvim_put(lines, "l", data.put_after, true)
end

-- +-------------------------------------------------------+
-- [                        COMMENT                        ]
-- +-------------------------------------------------------+

--- @class mkcmt.comment.Opts
--- @field put_after? boolean If true insert after cursor (like `p`), or before (like `P`).
--- @field border? string border. e.g. default: '+-+[]+-+'
--- @field header? string set the header
--- @field upper? boolean force upper the header
--- @field oneline? boolean render a single-line divider (ignores header)
--- @field oneline_char? string override fill character

---make a comment block
---@param opts? mkcmt.comment.Opts
---@return nil
function M.comment(opts)
  opts = opts or {}

  local mode = vim.fn.mode()
  local visual = mode:match("^V") or mode == "\22"
  local put_after = opts.put_after == true
  local upper = opts.upper == true
  local oneline = vim.F.if_nil(opts.oneline, Config.oneline) == true

  local data = {
    put_after = put_after,
    visual = visual,
    upper = upper,
    oneline = oneline,
  }

  local prompt = (upper and "(upper) " or "") .. "header: "

  if oneline then
    mkcmt("", opts, data)
    return
  end

  if opts.header then
    mkcmt(opts.header, opts, data)
  else
    vim.ui.input({ prompt = prompt }, function(input)
      if input then
        input = vim.trim(input)
        local header = input == "" and Config.default_header or input
        mkcmt(header, opts, data)
      end
    end)
  end
end

return M
