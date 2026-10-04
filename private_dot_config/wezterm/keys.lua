local wezterm = require 'wezterm'

local M = {}

function M.apply_to_config(config)
  local keys = {
    { key = 'a', mods = 'CTRL', action = wezterm.action.DisableDefaultAssignment },
    { key = 'k', mods = 'CTRL', action = wezterm.action.DisableDefaultAssignment },
    { key = 'u', mods = 'CTRL', action = wezterm.action.DisableDefaultAssignment },
    { key = 'e', mods = 'CTRL', action = wezterm.action.DisableDefaultAssignment },
    { key = 'w', mods = 'CTRL', action = wezterm.action.DisableDefaultAssignment },
  }
  config.keys = config.keys or {}
  for _, key in ipairs(keys) do
    table.insert(config.keys, key)
  end
end

return M
