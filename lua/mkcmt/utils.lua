local Utils = {}
Utils.__index = Utils

function Utils:new()
  local utils = setmetatable({}, self)
  return utils
end

---delete last selection
---@param visual boolean
---@return nil
function Utils:del_lsel(visual)
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

function Utils:get_cmt_str()
  local cs = vim.bo.commentstring or "# %s"
  local pre, suf = cs:match("^(.*)%%s(.*)$")
  return pre or "", suf or ""
end

function Utils:get_borders(str)
  return {
    { str:sub(1, 1), str:sub(2, 2), str:sub(3, 3) },
    { str:sub(4, 4), str:sub(5, 5) },
    { str:sub(6, 6), str:sub(7, 7), str:sub(8, 8) },
  }
end

return Utils:new()
