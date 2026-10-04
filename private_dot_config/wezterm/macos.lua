local wezterm = require 'wezterm'

local M = {}

function M.apply_to_config(config)
  config.macos_forward_to_ime_modifier_mask = 'SHIFT'

  local keys = {
    { key = 'Backspace', mods = 'SUPER', action = wezterm.action.SendString '\x01\x0b' },
    { key = 'k', mods = 'SUPER', action = wezterm.action.ClearScrollback 'ScrollbackAndViewport' },
    { key = 'LeftArrow', mods = 'SUPER|ALT', action = wezterm.action.ActivateTabRelative(-1) },
    { key = 'RightArrow', mods = 'SUPER|ALT', action = wezterm.action.ActivateTabRelative(1) },
  }
  config.keys = config.keys or {}
  for _, key in ipairs(keys) do
    table.insert(config.keys, key)
  end
end

return M
