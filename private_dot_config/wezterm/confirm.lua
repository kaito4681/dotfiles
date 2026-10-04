local wezterm = require 'wezterm'

local isMac = wezterm.target_triple:find('apple') ~= nil

local function appleScriptString(s)
  return '"' .. s:gsub('[\\"]', '\\%0') .. '"'
end

-- Return true/false for the user's choice, or nil when no dialog is available.
local function ask(title, message, button)
  local commands
  if isMac then
    commands = { {
      'osascript', '-e', ('display alert %s message %s as warning buttons {"Cancel", %s} '
        .. 'default button %s cancel button "Cancel"'):format(
        appleScriptString(title), appleScriptString(message),
        appleScriptString(button), appleScriptString(button)),
    } }
  else
    commands = {
      { 'zenity', '--question', '--title', title, '--text', message,
        '--ok-label', button, '--cancel-label', 'Cancel' },
      { 'kdialog', '--title', title, '--continue-label', button,
        '--warningcontinuecancel', message },
    }
  end
  for _, command in ipairs(commands) do
    local spawned, ok = pcall(wezterm.run_child_process, command)
    if spawned then
      return ok
    end
  end
end

local shells = { bash = true, fish = true, sh = true, zsh = true }

-- Like Ghostty, only ask when something other than a shell prompt is running.
local function isBusy(panes)
  for _, pane in ipairs(panes) do
    local name = (pane:get_foreground_process_name() or ''):match('([^/]*)$')
    if not shells[name] then
      return true
    end
  end
  return false
end

local function allPanes()
  local panes = {}
  for _, window in ipairs(wezterm.mux.all_windows()) do
    for _, tab in ipairs(window:tabs()) do
      for _, pane in ipairs(tab:panes()) do
        table.insert(panes, pane)
      end
    end
  end
  return panes
end

local closeTab = wezterm.action_callback(function(window, pane)
  local confirmed = true
  if isBusy(pane:tab():panes()) then
    confirmed = ask('Close Tab?', 'All terminal sessions in this tab will be terminated.', 'Close')
  end
  if confirmed ~= false then
    -- Fall back to WezTerm's own prompt when no dialog is available.
    window:perform_action(wezterm.action.CloseCurrentTab { confirm = confirmed == nil }, pane)
  end
end)

local quit = wezterm.action_callback(function(window, pane)
  local confirmed = true
  if isBusy(allPanes()) then
    confirmed = ask('Quit WezTerm?', 'All terminal sessions will be terminated.', 'Quit')
  end
  if confirmed == false then
    return
  elseif confirmed then
    local overrides = window:get_config_overrides() or {}
    local previousConfirmation = overrides.window_close_confirmation
    overrides.window_close_confirmation = 'NeverPrompt'
    window:set_config_overrides(overrides)
    window:perform_action(wezterm.action.QuitApplication, pane)
    overrides.window_close_confirmation = previousConfirmation
    window:set_config_overrides(overrides)
  else
    window:perform_action(wezterm.action.QuitApplication, pane)
  end
end)

local M = {}

function M.apply_to_config(config)
  local mods = isMac and 'SUPER' or 'CTRL|SHIFT'
  config.keys = config.keys or {}
  table.insert(config.keys, { key = 'q', mods = mods, action = quit })
  table.insert(config.keys, { key = 'w', mods = mods, action = closeTab })
end

return M
