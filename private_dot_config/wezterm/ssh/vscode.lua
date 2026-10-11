local wezterm = require 'wezterm'
local ssh = require 'ssh.detect'
local directory = require 'ssh.directory'

-- Run `code` from PATH. A login shell adds the directories that a WezTerm
-- started from the Dock lacks.
local function code(...)
  wezterm.background_child_process { '/bin/zsh', '-lc', 'exec code "$@"', 'code', ... }
end

local function openRemote(host, path)
  if not host or not host:match('^[%w_][%w_.@:+%-]*$') then
    wezterm.log_error('OPEN_VSCODE: could not determine the SSH host')
    return
  end
  code('--remote', 'ssh-remote+' .. host, '--', path)
end

-- Open the directory of the local foreground process. OSC 7 may still hold a
-- directory from an SSH session that has ended.
local function openLocal(window, pane)
  local info = pane:get_foreground_process_info()
  if not info or not info.cwd or info.cwd == '' then
    window:toast_notification('VS Code', 'Could not determine the directory', nil, 3000)
    return
  end
  code('--', info.cwd)
end

-- Open the current directory in VS Code, via Remote - SSH when connected.
local openCurrent = wezterm.action_callback(function(window, pane)
  local host, command = ssh.detect(pane)
  if not host then
    openLocal(window, pane)
    return
  end
  local path = directory.remote(command)
  if not path then
    window:toast_notification('VS Code', 'Could not determine the remote directory', nil, 3000)
    return
  end
  openRemote(host, path)
end)

local M = {}

-- `openKey` ({ key = ..., mods = ... }) binds opening the current directory.
function M.apply_to_config(config, openKey)
  local lastRequestID

  -- Open a path sent by the remote `code` function via Remote - SSH.
  wezterm.on('user-var-changed', function(window, pane, name, value)
    if name ~= 'OPEN_VSCODE' or value == '' then
      return
    end
    local id, host, path = value:match('^(%w+)\t([^\t\r\n]*)\t(/[^\t\r\n]*)$')
    if not id then
      wezterm.log_error('Invalid OPEN_VSCODE request')
      return
    end
    -- Ignore copies sent for other tmux nesting levels.
    if id == lastRequestID then
      return
    end
    lastRequestID = id

    if host == '' then
      host = ssh.detect(pane)
    end
    openRemote(host, path)
  end)

  if openKey then
    config.keys = config.keys or {}
    table.insert(config.keys, { key = openKey.key, mods = openKey.mods, action = openCurrent })
  end
end

return M
