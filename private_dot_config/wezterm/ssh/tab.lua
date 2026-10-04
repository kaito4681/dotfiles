local wezterm = require 'wezterm'
local ssh = require 'ssh.detect'

local function shellQuote(s)
  return "'" .. s:gsub("'", [['\'']]) .. "'"
end

-- While connected over SSH, open the new tab on the same host and directory.
local spawnTab = wezterm.action_callback(function(window, pane)
  local _, command = ssh.detect(pane)
  if not command then
    window:perform_action(wezterm.action.SpawnTab 'CurrentPaneDomain', pane)
    return
  end
  local cwd = pane:get_current_working_dir()
  local remoteCommand = 'exec "$SHELL" -l'
  if cwd and cwd.host ~= wezterm.hostname() and cwd.file_path ~= '' then
    remoteCommand = 'cd ' .. shellQuote(cwd.file_path) .. ' 2>/dev/null; ' .. remoteCommand
  end
  table.insert(command, 2, '-t')
  table.insert(command, remoteCommand)
  window:perform_action(wezterm.action.SpawnCommandInNewTab { args = command }, pane)
end)

local M = {}

function M.apply_to_config(config)
  config.keys = config.keys or {}
  table.insert(config.keys, { key = 't', mods = 'SUPER', action = spawnTab })
end

return M
