local wezterm = require 'wezterm'

local sshOptionsWithArgument = 'BbcDEeFIiJLlmOoPpQRSWw'

local function basename(path)
  return path and path:match('([^/]+)$')
end

-- `ssh -p 2222 myserver ls` -> 4 (the index of `myserver`), and whether -T
-- disables the tty, as in background connections such as herdr's.
local function destinationIndex(argv)
  local i = 2
  local noTTY = false
  while i <= #argv do
    local arg = argv[i]
    if arg == '--' then
      return i + 1, noTTY
    elseif arg:sub(1, 1) ~= '-' then
      return i, noTTY
    end
    for j = 2, #arg do
      local option = arg:sub(j, j)
      if option == 'T' then
        noTTY = true
      end
      if sshOptionsWithArgument:find(option, 1, true) then
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
  if basename(info.executable) == 'ssh' and not select(2, destinationIndex(info.argv)) then
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

-- With a local herdr, ssh runs in the focused pane of the herdr server.
local function herdrFocusedPanePID(client)
  local function query(...)
    local ok, stdout = wezterm.run_child_process { client.executable, ... }
    local parsed = ok and wezterm.json_parse(stdout)
    return parsed and parsed.result
  end
  local list = query('pane', 'list')
  for _, herdrPane in ipairs(list and list.panes or {}) do
    if herdrPane.focused then
      local result = query('pane', 'process-info', '--pane', herdrPane.pane_id)
      return result and result.process_info and result.process_info.shell_pid
    end
  end
end

-- herdr titles the window "<server hostname>: <workspace>". When it shows a
-- remote machine, the panes run there and herdr reaches it through its own
-- background ssh, whose destination is a plain ssh destination.
local function herdrRemoteSSH(pane, client)
  local shown = pane:get_title():match('^([^:]+): ')
  local hostname = wezterm.hostname()
  if not shown or shown == hostname or shown == hostname:match('^[^.]+') then
    return nil
  end
  local found
  for _, child in pairs(client.children or {}) do
    local i = basename(child.executable) == 'ssh' and destinationIndex(child.argv)
    if i and child.argv[i] then
      found = { child.argv[i], child.executable }
      if child.argv[i] == shown then
        break
      end
    end
  end
  return found
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
  local client = basename(info.executable)
  if not ssh and client == 'herdr' then
    local remote = herdrRemoteSSH(pane, info)
    if remote then
      return remote[1], { remote[2], remote[1] }
    end
  end
  if not ssh then
    local pid = client == 'tmux' and tmuxActivePanePID(pane, info)
      or client == 'herdr' and herdrFocusedPanePID(info)
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
