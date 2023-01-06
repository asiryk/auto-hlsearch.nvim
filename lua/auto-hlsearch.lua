local defaults = {
  remap_keys = { "/", "?", "*", "#", "n", "N" },
}

-- Remap provided keys in order to use :AutoHlsearch command
-- while keeping the user's keymap configuration
local function remap_keys(keys)
  local function set(lhs, keymap)
    local cmd = ":AutoHlsearch<CR>"
    if keymap then
      local opts = {
        expr = keymap.expr,
        noremap = keymap.noremap,
        nowait = keymap.nowait,
        script = keymap.script,
        silent = keymap.silent,
      }
      vim.api.nvim_set_keymap("n", lhs, string.format("%s%s", cmd, keymap.rhs), opts)
    else
      vim.keymap.set("n", lhs, string.format("%s%s", cmd, lhs), { silent = true })
    end
  end

  local keymaps = vim.tbl_filter(
    function(t) return vim.tbl_contains(keys, t.lhs) end,
    vim.api.nvim_get_keymap("n")
  )

  for _, lhs in ipairs(keys) do
    local keymap = vim.tbl_filter(function(t) return t.lhs == lhs end, keymaps)[1]
    set(lhs, keymap)
  end
end

local function init(config)
  local group = vim.api.nvim_create_augroup("auto-hlsearch", {})
  local namespace = vim.api.nvim_create_namespace("auto-hlsearch")
  local autocmd_ids = {}
  local is_plugin_disabled = false

  local function clear_subscriptions()
    vim.on_key(nil, namespace)
    for _, id in pairs(autocmd_ids) do
      vim.api.nvim_del_autocmd(id)
    end
    autocmd_ids = {}
  end

  local function deactivate()
    if is_plugin_disabled then return end

    -- need to schedule, since noh doesn't work with autocmd. :h noh
    vim.schedule(function() vim.o.hlsearch = false end)
    clear_subscriptions()
  end

  local function activate()
    -- there is no need to activate :AutoHlsearch again
    -- if the subscriptions are still present
    if #autocmd_ids ~= 0 then return end
    vim.o.hlsearch = true

    local last_key = nil
    table.insert(autocmd_ids, vim.api.nvim_create_autocmd("CursorMoved", {
      group = group,
      callback = function()
        -- TODO - ignore <CR> only for the first time. Next presses should disable highlight
        local ignore_keys = vim.list_extend({ "<CR>", ":", "*", "#", "n", "N" }, config.remap_keys)
        if not vim.tbl_contains(ignore_keys, last_key) then deactivate() end
      end,
    }))

    table.insert(autocmd_ids, vim.api.nvim_create_autocmd("InsertEnter", {
      group = group,
      callback = function() deactivate() end,
    }))

    -- the on_key subscription is required in order to know
    -- the character which triggered "CursorMoved" autocmd
    vim.on_key(function(char)
      if vim.api.nvim_get_mode()["mode"] == "n" then
        ---
        last_key = vim.fn.keytrans(char)
      end
    end, namespace)
  end

  local function enable_plugin() is_plugin_disabled = false end

  local function disable_plugin() is_plugin_disabled = true end

  return activate, enable_plugin, disable_plugin
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
    local activate, enable, disable = init(config)
    vim.api.nvim_create_user_command("AutoHlsearch", function() activate() end, {})
    vim.api.nvim_create_user_command("AutoHlsearchEnable", function() enable() end, {})
    vim.api.nvim_create_user_command("AutoHlsearchDisable", function() disable() end, {})
    remap_keys(config.remap_keys)
  end,
}
