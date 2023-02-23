# auto-hlsearch.nvim
Automatically manage hlsearch setting.

## Preview

Activates the `hlsearch` option when you start searching e.g. with key `/`. Deactivates the `hlsearch`
when you move the cursor, so you don't have to think about enabling/disabling it manually.

It creates subscriptions only when necessary and removes them when the search is done.

https://user-images.githubusercontent.com/61456651/210617006-8d1dc836-695f-44bd-b62f-63b1dea56f09.mp4

> Note: it is possible to turn off the plugin with `:AutoHlsearchDisable` and turn on with `:AutoHlsearchEnable` commands

## Getting Started

### Installation

[Neovim >=0.8.0](https://github.com/neovim/neovim/releases/tag/v0.8.0) is recommended.

The plugin can be installed using any plugin manager. An example using
[packer.nvim:](https://github.com/wbthomason/packer.nvim):

```lua
use({ "asiryk/auto-hlsearch.nvim", tag = "1.0.0" })
```

> Note: It is recommended to specify the tag.

### Usage

In order to use the plugin, it is required to call `setup()`. The following line will use default settings:

```lua
require("auto-hlsearch").setup()
```

The default configuration options:

```lua
require("auto-hlsearch").setup({
  remap_keys = { "/", "?", "*", "#", "n", "N" },
  create_commands = true,
  pre_hook = function() end,
  post_hook = function() end,
})
```

The plugin introduces a user command `:AutoHlsearch` which would be prepended to the provided `remap_keys`.
`pre_hook` and `post_hook` functions will activate before/after searching.

For more information read [help](./doc/auto-hlsearch.txt) `:h auto-hlsearch.nvim`.
