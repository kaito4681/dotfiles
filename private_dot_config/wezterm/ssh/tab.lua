local wezterm = require 'wezterm'
local ssh = require 'ssh.detect'

local function shellQuote(s)
  return "'" .. s:gsub("'", [['\'']]) .. "'"
end

-- While connected over SSH, open the new tab on the same host and directory.
-- ssh runs inside a local shell, so leaving it (e.g. Ctrl+D) drops back to a
-- local shell instead of closing the tab.
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
  local quoted = {}
  for _, arg in ipairs(command) do
    table.insert(quoted, shellQuote(arg))
  end
  local shell = os.getenv('SHELL') or '/bin/zsh'
  window:perform_action(wezterm.action.SpawnCommandInNewTab {
    args = { shell, '-lc', table.concat(quoted, ' ') .. '; exec "$SHELL" -l' },
  }, pane)
end)

local M = {}

function M.apply_to_config(config)
  config.keys = config.keys or {}
  table.insert(config.keys, { key = 't', mods = 'SUPER', action = spawnTab })
end

return M
