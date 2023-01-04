local defaults = {
  remap_keys = { "/", "?", "*", "#" },
}

local function remap_search_keys(keys)
  for _, key in ipairs(keys) do
    vim.keymap.set("n", key, string.format("%s%s", ":AutoHlsearch<CR>", key))
  end
end

-- Keep user keymaps for n and N keys
local function remap_n_keys()
  local function set(user_map, key)
    local cmd = ":AutoHlsearch<CR>"
    if user_map then
      local opts = {
        expr = user_map.expr,
        noremap = user_map.noremap,
        nowait = user_map.nowait,
        script = user_map.script,
        silent = user_map.silent,
      }
      vim.api.nvim_set_keymap("n", key, string.format("%s%s", cmd, user_map.rhs), opts)
    else
      vim.keymap.set("n", key, string.format("%sn", cmd))
    end
  end

  local keymaps = vim.api.nvim_get_keymap("n")
  local n_map = vim.tbl_filter(function(t) return t.lhs == "n" end, keymaps)[1]
  local N_map = vim.tbl_filter(function(t) return t.lhs == "N" end, keymaps)[1]
  set(n_map, "n")
  set(N_map, "N")
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
    -- There is no need to activate AutoHlsearch again
    -- if subscription is still present
    if autocmd_id then return end

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
    vim.cmd("set hlsearch") -- enable hlsearch in case it's disabled in user's config
    local config = apply_user_config(user_config)
    local activate = init(config)
    vim.api.nvim_create_user_command("AutoHlsearch", function() activate() end, {})
    remap_search_keys(config.remap_keys)
    remap_n_keys()
  end,
}
