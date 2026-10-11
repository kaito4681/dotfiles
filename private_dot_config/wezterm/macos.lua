local wezterm = require 'wezterm'

local M = {}

function M.apply_to_config(config)
  config.macos_forward_to_ime_modifier_mask = 'SHIFT'

  local keys = {
    { key = 'Backspace', mods = 'SUPER', action = wezterm.action.SendString '\x01\x0b' },
    -- herdr and tmux keep each pane's contents themselves, so ask them to clear
    -- the focused pane (bound to prefix+ctrl+k in both). Clearing the viewport
    -- under any other full-screen app leaves it blank until the app redraws,
    -- so only drop the scrollback there.
    {
      key = 'k',
      mods = 'SUPER',
      action = wezterm.action_callback(function(window, pane)
        local process = pane:get_foreground_process_name()
        local name = process and process:match('([^/]+)$')
        if name == 'herdr' or name == 'tmux' then
          window:perform_action(wezterm.action.SendString '\x02\x0b', pane)
          return
        end
        local scope = pane:is_alt_screen_active() and 'ScrollbackOnly' or 'ScrollbackAndViewport'
        window:perform_action(wezterm.action.ClearScrollback(scope), pane)
      end),
    },
    { key = 'LeftArrow', mods = 'SUPER|ALT', action = wezterm.action.ActivateTabRelative(-1) },
    { key = 'RightArrow', mods = 'SUPER|ALT', action = wezterm.action.ActivateTabRelative(1) },
  }
  config.keys = config.keys or {}
  for _, key in ipairs(keys) do
    table.insert(config.keys, key)
  end
end

return M
