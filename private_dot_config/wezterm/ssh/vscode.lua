local wezterm = require 'wezterm'
local ssh = require 'ssh.detect'

local M = {}

function M.apply_to_config(_config)
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
    if not host or not host:match('^[%w_][%w_.@:+%-]*$') then
      wezterm.log_error('OPEN_VSCODE: could not determine the SSH host')
      return
    end
    local cli = '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code'
    wezterm.background_child_process {
      cli, '--remote', 'ssh-remote+' .. host, '--', path,
    }
  end)
end

return M
