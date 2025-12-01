# mkcmt.nvim

> 📝 A simple Neovim plugin to create decorative comment blocks around headers.

`mkcmt.nvim` helps you quickly generate centered, bordered comment blocks with customizable headers.
It integrates with `vim.ui.input` for prompts, respects your buffer's `commentstring`, and can be configured to match your style.

---

## 🎥 Demo

https://github.com/user-attachments/assets/bc073187-6e3e-4c96-9ff3-2774be539811

---

## ✨ Features

- Create neat, bordered comment blocks.
- Center headers with configurable padding.
- Supports **uppercasing** headers.
- Respects buffer `commentstring` (`#`, `//`, `--`, etc.).
- Optional `:MkCmt` command.
- Works with **visual selections** (replaces last selection with comment block).
- **Optional:** For enhanced visuals of `vim.ui.input`, it is recommended to use [`snacks.nvim`](https://github.com/folke/snacks.nvim) with its **input** feature enabled.

---

## 📦 Installation

Use your favorite plugin manager:

[`lazy.nvim`](https://github.com/folke/lazy.nvim)

```lua
{
  "thesignumt/mkcmt.nvim",
  config = function()
    require("mkcmt").setup()
  end,
}
```

[`packer.nvim`](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "thesignumt/mkcmt.nvim",
  config = function()
    require("mkcmt").setup()
  end,
}
```

**vim.pack**

```lua
vim.pack.add({
    'https://github.com/thesignumt/mkcmt.nvim'
})
```

---

## ⚙️ Configuration

Default configuration:

```lua
require("mkcmt").setup({
  default_header = "HELLO WORLD", -- fallback header
  cmd = true,                     -- create :MkCmt user command
  min_width = 60,                  -- minimum block width
  padding = 10,                    -- spacing around header
  border = "+-+[]+-+",             -- border characters
})
```

### Example keymaps

```lua
local mkcmt = require("mkcmt")

-- simple mappings
vim.keymap.set({ "n", "v" }, "<leader>cc", function()
  mkcmt.comment({ after = true, upper = false })
end, { desc = "MkCmt after cursor" })

vim.keymap.set({ "n", "v" }, "<leader>cC", function()
  mkcmt.comment({ after = false, upper = false })
end, { desc = "MkCmt before cursor" })

vim.keymap.set({ "n", "v" }, "<leader>cx", function()
  mkcmt.comment({ after = true, upper = true })
end, { desc = "MkCmt AFTER (upper)" })

vim.keymap.set({ "n", "v" }, "<leader>cX", function()
  mkcmt.comment({ after = false, upper = true })
end, { desc = "MkCmt BEFORE (upper)" })
```

---

## 🖊️ Usage

- `:MkCmt` → prompts for a header, inserts a comment block.
- `require("mkcmt").comment(opts)`:
  - `after = true` → insert after cursor.
  - `upper = true` → uppercase header.
  - `header = "Custom"` → provide a header directly.
  - `border = "+-+[]+-+"` → override border style.

**Example**

```lua
:lua require("mkcmt").comment({ header = "Section", after = true })
```

---

## 📜 License

MIT
