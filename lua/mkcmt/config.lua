local Config = {
  default_header = "HELLO WORLD",
  cmd = true,
  min_width = 60, -- minimum width of the block
  padding = 10, -- extra spacing around header
  border = "+-+[]+-+",

  -- oneline mode
  oneline = false, -- render divider instead of block
  oneline_char = nil, -- override fill char (nil = use border)
}

--- @class MkcmtConfig
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
---
--- Render a single-line divider (ignores header)
--- @field oneline? boolean
---
--- Override fill character for one-line mode
--- @field oneline_char? string

return Config
