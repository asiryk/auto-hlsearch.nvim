local defaults = {
  remap_keys = { "/", "?", "*", "#" },
}

local function set_keymaps(remap_keys)
  for _, key in ipairs(remap_keys) do
    vim.keymap.set("n", key, string.format("%s%s", ":AutoHlsearch<cr>", key))
  end
end

local function init(config)
  local group = vim.api.nvim_create_augroup("auto-hlsearch", {})
  local namespace = vim.api.nvim_create_namespace("auto-hlsearch")
  local autocmd_id = nil

  local function clear_subscriptions()
    vim.on_key(nil, namespace)
    vim.api.nvim_del_autocmd(autocmd_id)
    autocmd_id = nil
  end

  local function deactivate()
    -- need to schedule, since noh doesn't work with autocmd. :h noh
    vim.schedule(function() vim.cmd(":noh") end)
    clear_subscriptions()
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
        local ignore_keys = vim.list_extend({ "<CR>", ":", "n", "N" }, config.remap_keys)
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

local function apply_user_config(user_config)
  local config = vim.tbl_deep_extend("force", {}, defaults)

  if user_config then
    if vim.tbl_islist(user_config.remap_keys) then
      config.remap_keys = user_config.remap_keys
    end
  end

  return config
end

return {
  setup = function(user_config)
    local config = apply_user_config(user_config)
    set_keymaps(config.remap_keys)
    local activate = init(config)
    vim.api.nvim_create_user_command("AutoHlsearch", function() activate() end, {})
  end,
}
