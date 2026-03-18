# mkcmt.nvim

> 📝 A simple Neovim plugin to create decorative comment blocks around headers.

`mkcmt.nvim` lets you quickly generate **centered, bordered comment blocks** with customizable headers.
It integrates with `vim.ui.input` for prompts, respects your buffer's `commentstring`, and can be configured to match your coding style.

> [!NOTE]
> i haven't fully finished the oneline feature so expect some bugs
> reason: i don't have the motivation and courage to finish it 😢

---

## 🎥 Demo

[https://github.com/user-attachments/assets/bc073187-6e3e-4c96-9ff3-2774be539811](https://github.com/user-attachments/assets/bc073187-6e3e-4c96-9ff3-2774be539811)

---

## ✨ Features

- Create neat, bordered comment blocks.
- Center headers with configurable padding.
- Supports **uppercasing** headers.
- Respects buffer `commentstring` (`#`, `//`, `--`, etc.).
- Optional `:MkCmt` user command.
- Works with **visual selections** (replaces last selection with comment block).
- **Oneline mode:** render a single-line divider instead of a block.
- **Custom fill character:** override the oneline divider character with `oneline_char`.
- Recommended for enhanced `vim.ui.input` visuals: requires [`snacks.nvim`](https://github.com/folke/snacks.nvim) with its **input** feature enabled.
  Otherwise it will fallback to vim.fn.input

**Dependencies:**

```lua
-- Lazy.nvim example
{
  "thesignumt/mkcmt.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {},
  config = function(_, opts)
    require("mkcmt").setup(opts)
  end,
}
```

Make sure `snacks.nvim` is installed and its `input` feature is enabled for a better prompt experience.

---

## 📦 Installation

Use your favorite plugin manager:

### [`lazy.nvim`](https://github.com/folke/lazy.nvim)

```lua
{
  "thesignumt/mkcmt.nvim",
  dependencies = { "folke/snacks.nvim" },
  opts = {},
  config = function(_, opts)
    require("mkcmt").setup(opts)
  end,
}
```

### [`packer.nvim`](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "thesignumt/mkcmt.nvim",
  requires = { "folke/snacks.nvim" },
  config = function()
    require("mkcmt").setup {}
  end,
}
```

### `vim.pack`

```lua
vim.pack.add({
  'https://github.com/thesignumt/mkcmt.nvim'
})
vim.pack.add({
  'https://github.com/folke/snacks.nvim'
})
```

### [`mini.deps`](https://github.com/nvim-mini/mini.deps)

```lua
local add = MiniDeps.add
add({
  source = "https://github.com/thesignumt/mkcmt.nvim",
  dependencies = { "folke/snacks.nvim" },
})
```

---

## ⚙️ Configuration

Default setup:

```lua
require("mkcmt").setup({
  default_header = "HELLO WORLD",  -- fallback header when prompt is empty
  cmd = true,                      -- create :MkCmt user command
  min_width = 60,                  -- minimum block width
  padding = 10,                    -- spacing around header
  border = "+-+[]+-+",             -- border characters
  oneline = false,                 -- render a single-line divider
  oneline_char = nil,              -- optional custom divider character
})
```

---

## 🔑 Keymaps Example

```lua
local mkcmt = require("mkcmt")

-- simple mappings
vim.keymap.set({ "n", "v" }, "<leader>cc", function()
  mkcmt.comment({ put_after = true, uppercase = false })
end, { desc = "MkCmt after cursor" })

vim.keymap.set({ "n", "v" }, "<leader>cC", function()
  mkcmt.comment({ put_after = false, uppercase = false })
end, { desc = "MkCmt before cursor" })

vim.keymap.set({ "n", "v" }, "<leader>cx", function()
  mkcmt.comment({ put_after = true, uppercase = true })
end, { desc = "MkCmt after cursor (uppercase)" })

vim.keymap.set({ "n", "v" }, "<leader>cX", function()
  mkcmt.comment({ put_after = false, uppercase = true })
end, { desc = "MkCmt before cursor (uppercase)" })
```

---

## 🖊️ Usage

- `:MkCmt` → prompts for a header, inserts a comment block.
- `require("mkcmt").comment(opts)` accepts:

| Option         | Type    | Description                                               |
| -------------- | ------- | --------------------------------------------------------- |
| `put_after`    | boolean | Insert **after** cursor (`true`) or **before** (`false`). |
| `uppercase`    | boolean | Uppercase the header text.                                |
| `header`       | string  | Provide a header directly, skipping the prompt.           |
| `border`       | string  | Override border style, e.g., `"+-+[]+-+"`.                |
| `oneline`      | boolean | Render a single-line divider instead of a block.          |
| `oneline_char` | string  | Override the character used in oneline mode.              |

**Example:**

```lua
:lua require("mkcmt").comment({ header = "Section", put_after = true })
```

**Oneline example:**

```lua
:lua require("mkcmt").comment({ oneline = true, put_after = true, oneline_char = "-" })
```

---

## 📜 License

MIT
