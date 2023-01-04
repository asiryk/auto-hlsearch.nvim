# auto-hlsearch.nvim
Automatically manage hlsearch setting.

## Preview

Enables the `hlsearch` option after the search started. Disables the `hlsearch` when cursor moved.

## Getting Started

### Installation

[Neovim >=0.8.0](https://github.com/neovim/neovim/releases/tag/v0.8.0) is recommended.

The plugin can be installed using any plugin manager. An example using packer.nvim:

[packer.nvim:](https://github.com/wbthomason/packer.nvim)

```lua
use("asiryk/auto-hlsearch.nvim")
```

### Usage

In order to use the plugin it is required to call `setup()`. The following line will use default settings:

```lua
require("auto-hlsearch").setup()
```

The default configuration options:

```lua
require("auto-hlsearch").setup({
  remap_keys = { "/", "?", "*", "#" },
})
```

The plugin introduces a user command `:AutoHlsearch` which would be prepended to the provided `remap_keys`.

For more information reed [help](./doc/auto-hlsearch.txt) `:h auto-hlsearch.nvim`.
