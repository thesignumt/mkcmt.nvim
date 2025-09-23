local Config = require("mkcmt.config")
local Utils = require("mkcmt.utils")

---@class Mkcmt
---@field config MkcmtConfig
local Mkcmt = {}

Mkcmt.__index = {}

---@return Mkcmt
function Mkcmt:new()
  local mkcmt = setmetatable({
    config = Config,
  }, self)
  return mkcmt
end

---make comment block
---@param header string
---@param opts mkcmt.comment.Opts
---@param data table
---@return Mkcmt
function Mkcmt:_mkcmt(header, opts, data)
  local function get(opt, fallback)
    return vim.F.if_nil(opts[opt], self.config[opt]) or fallback
  end
  local pre, suf = Utils:get_comment_str()
  local min_width = get("min_width")
  ---@cast min_width integer
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
  vim.api.nvim_put(lines, "l", data.after, true)

  return self
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
---@return Mkcmt
function Mkcmt:comment(opts)
  opts = opts or {}
  local visual = vim.fn.mode() == "V"
  local after = opts.after == true
  local upper = opts.upper == true

  local data = { after = after, visual = visual, upper = upper }
  local prompt = (upper and "(upper) " or "") .. "header: "

  if opts.header then
    self:_mkcmt(opts.header, opts, data)
  else
    vim.ui.input({ prompt = prompt }, function(input)
      local header = input == "" and self.config.default_header or input
      if input then
        self:_mkcmt(header, opts, data)
      end
    end)
  end

  return self
end

local the_mkcmt = Mkcmt:new()

--- Setup MkCmt
--- @param opts? MkcmtConfig
--- @return Mkcmt
function Mkcmt:setup(opts)
  self.config = vim.tbl_extend("force", self.config, opts or {})

  if self.config.cmd then
    -- TODO: extend this. maybe :Mkcmt upper... etc
    vim.api.nvim_create_user_command("MkCmt", function()
      self:comment()
    end, {})
  end

  return self
end

return the_mkcmt
