local wezterm = require 'wezterm'

local sshOptionsWithArgument = 'BbcDEeFIiJLlmOoPpQRSWw'

local function basename(path)
  return path and path:match('([^/]+)$')
end

-- `ssh -p 2222 myserver ls` -> 4 (the index of `myserver`)
local function destinationIndex(argv)
  local i = 2
  while i <= #argv do
    local arg = argv[i]
    if arg == '--' then
      return i + 1
    elseif arg:sub(1, 1) ~= '-' then
      return i
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

local M = {}

-- Return the destination and the ssh command up to it, e.g.
-- `myserver`, { '/usr/bin/ssh', '-p', '2222', 'myserver' }.
function M.detect(pane)
  local info = pane:get_foreground_process_info()
  if not info then
    return nil
  end
  local ssh = findSSH(info)
  if not ssh and basename(info.executable) == 'tmux' then
    local pid = tmuxActivePanePID(pane, info)
    ssh = pid and findSSH(wezterm.procinfo.get_info_for_pid(pid))
  end
  local i = ssh and destinationIndex(ssh.argv)
  if not i or not ssh.argv[i] then
    return nil
  end
  local command = { ssh.executable }
  for j = 2, i do
    table.insert(command, ssh.argv[j])
  end
  return ssh.argv[i], command
end

return M
