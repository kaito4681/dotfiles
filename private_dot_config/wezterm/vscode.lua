local wezterm = require 'wezterm'

local sshOptionsWithArgument = 'BbcDEeFIiJLlmOoPpQRSWw'

local function basename(path)
  return path and path:match('([^/]+)$')
end

-- `ssh -p 2222 myserver ls` -> `myserver`
local function sshDestination(argv)
  local i = 2
  while i <= #argv do
    local arg = argv[i]
    if arg == '--' then
      return argv[i + 1]
    elseif arg:sub(1, 1) ~= '-' then
      return arg
    end
    for j = 2, #arg do
      if sshOptionsWithArgument:find(arg:sub(j, j), 1, true) then
        if j == #arg then
          i = i + 1
        end
        break
      end
    end
    i = i + 1
  end
end

local function findSSH(info)
  if not info then
    return nil
  end
  if basename(info.executable) == 'ssh' then
    return info
  end
  for _, child in pairs(info.children or {}) do
    local found = findSSH(child)
    if found then
      return found
    end
  end
end

-- With a local tmux, ssh runs in the active pane of the attached client.
local function tmuxActivePanePID(pane, client)
  local command = { client.executable }
  for i = 2, #client.argv do
    local option, value = client.argv[i]:match('^%-([LS])(.*)$')
    if option then
      table.insert(command, '-' .. option)
      table.insert(command, value ~= '' and value or client.argv[i + 1])
    end
  end
  table.insert(command, 'list-clients')
  table.insert(command, '-F')
  table.insert(command, '#{client_tty}\t#{pane_pid}')

  local ok, stdout = wezterm.run_child_process(command)
  if not ok then
    return nil
  end
  local tty = pane:get_tty_name()
  for line in stdout:gmatch('[^\n]+') do
    local clientTTY, pid = line:match('^([^\t]+)\t(%d+)$')
    if clientTTY == tty then
      return tonumber(pid)
    end
  end
end

local function detectHost(pane)
  local info = pane:get_foreground_process_info()
  if not info then
    return nil
  end
  local ssh = findSSH(info)
  if not ssh and basename(info.executable) == 'tmux' then
    local pid = tmuxActivePanePID(pane, info)
    ssh = pid and findSSH(wezterm.procinfo.get_info_for_pid(pid))
  end
  return ssh and sshDestination(ssh.argv)
end

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
      host = detectHost(pane)
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
