local wezterm = require 'wezterm'

local M = {}

local pendingQuit
local doublePressQuit = wezterm.action_callback(function(window, pane)
  local now = tonumber(wezterm.time.now():format('%s%.3f'))
  local windowID = window:window_id()
  local activePane = window:active_pane()
  if pendingQuit and pendingQuit.windowID == windowID
    and activePane and activePane:pane_id() == pendingQuit.overlayID then
    local confirmed = now - pendingQuit.startedAt <= 1
    pendingQuit = nil
    if confirmed then
      local overrides = window:get_config_overrides() or {}
      local previousConfirmation = overrides.window_close_confirmation
      overrides.window_close_confirmation = 'NeverPrompt'
      window:set_config_overrides(overrides)
      window:perform_action(wezterm.action.QuitApplication, activePane)
      overrides.window_close_confirmation = previousConfirmation
      window:set_config_overrides(overrides)
    else
      window:perform_action(wezterm.action.SendKey { key = 'Escape', mods = 'NONE' }, activePane)
    end
    return
  end

  pendingQuit = nil
  local originalPaneID = pane:pane_id()
  local dimensions = pane:get_dimensions()
  local left = math.floor(dimensions.cols * 0.1)
  local top = math.max(0, math.floor((dimensions.viewport_rows - 3) / 2))
  local message = '🛑 Press ⌘Q again to quit'
  local shortcuts = ' [⌘Q] Quit        [Esc] Cancel '
  local hideCursor = '\27[?25l'
  local budget = math.max(0, dimensions.cols - 6 - wezterm.column_width(hideCursor))
  left = math.min(left, math.max(0, math.floor(
    (budget - wezterm.column_width(message) - wezterm.column_width(shortcuts)) / 2
  )))
  local description = hideCursor .. string.rep('\r\n', top) .. string.rep(' ', left)
    .. message .. '\r\n\r\n' .. string.rep(' ', left) .. shortcuts
  window:perform_action(wezterm.action.InputSelector {
    title = 'Quit WezTerm',
    description = description,
    alphabet = '',
    choices = {},
    action = wezterm.action_callback(function(cancelWindow)
      if pendingQuit and pendingQuit.windowID == cancelWindow:window_id() then
        pendingQuit = nil
      end
    end),
  }, pane)
  local overlay = window:active_pane()
  if not overlay or overlay:pane_id() == originalPaneID then
    return
  end
  local request = {
    windowID = windowID,
    overlayID = overlay:pane_id(),
    startedAt = now,
  }
  pendingQuit = request
  wezterm.time.call_after(1, function()
    if pendingQuit ~= request then
      return
    end
    pendingQuit = nil
    local currentPane = window:active_pane()
    if currentPane and currentPane:pane_id() == request.overlayID then
      window:perform_action(wezterm.action.SendKey { key = 'Escape', mods = 'NONE' }, currentPane)
    end
  end)
end)

function M.apply_to_config(config)
  config.keys = config.keys or {}
  table.insert(config.keys, { key = 'q', mods = 'SUPER', action = doublePressQuit })
end

return M
