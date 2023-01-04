local M = {}

local config = {
  remap_keys = { "/", "?", "*", "#" },
  clear_register = false,
}

function M.setup(opts)
  if not opts then return end
  if vim.tbl_islist(opts.remap_keys) then config.remap_keys = opts.remap_keys end
  if opts.clear_register ~= nil then config.clear_register = opts.clear_register end
end

-- not using the nvim lua api since it causes flickering
local function enable_hlsearch() vim.cmd("set hlsearch") end

local function disable_hlsearch() vim.cmd("set nohlsearch") end

local function clear_register() vim.cmd(":let @/ = ''") end

local function set_keymaps(search_keys)
  for _, key in ipairs(search_keys) do
    vim.keymap.set("n", key, string.format("%s%s", ":AutoHlsearch<cr>", key))
  end
end

local function init(search_keys)
  local group = vim.api.nvim_create_augroup("auto-hlsearch", {})
  local namespace = vim.api.nvim_create_namespace("auto-hlsearch")
  local autocmd_id = nil

  local function clear_subscriptions()
    vim.on_key(nil, namespace)
    vim.api.nvim_del_autocmd(autocmd_id)
    autocmd_id = nil
  end

  local function deactivate()
    disable_hlsearch()
    clear_subscriptions()
    if config.clear_register then clear_register() end
  end

  return function()
    -- if switched from one type of search to another e.g. / -> *
    -- it is required to remove previous subscription
    if autocmd_id then clear_subscriptions() end

    local last_key = nil
    autocmd_id = vim.api.nvim_create_autocmd("CursorMoved", {
      group = group,
      callback = function()
        -- TODO - ignore <CR> only for the first time. Next presses should disable highlight
        local ignore_keys = vim.list_extend({ "<CR>", ":", "n", "N" }, search_keys)
        if not vim.tbl_contains(ignore_keys, last_key) then deactivate() end
      end,
    })

    -- the on_key subscription is required in order to know
    -- the character which triggered "CursorMoved" autocmd
    vim.on_key(function(char)
      if vim.api.nvim_get_mode()["mode"] == "n" then
        ---
        last_key = vim.fn.keytrans(char)
      end
    end, namespace)
  end
end

set_keymaps(config.remap_keys)

local activate = init(config.remap_keys)

vim.api.nvim_create_user_command("AutoHlsearch", function()
  enable_hlsearch()
  activate()
end, {})

return M

