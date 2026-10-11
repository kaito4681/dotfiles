local wezterm = require 'wezterm'
local ssh = require 'ssh.detect'

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

-- Print the cwd of the foreground process of the remote pty typed in last.
-- Inside tmux, herdr and the like both the ssh session's pty and the inner
-- pane's pty see the input, so prefer the inner one. Linux only updates a
-- pty's input time every 8 seconds. This needs nothing on the remote.
local directoryScript = [=[
{ stat -c 'S %X %U %n' /dev/pts/[0-9]*; ps -eo pid=,ppid=,sid=,tpgid=,tty=,comm=; } | awk -v me="$(id -un)" '
$1 == "S" { if ($3 == me) { t = $4; sub("^/dev/", "", t); atime[t] = $2 }; next }
{ ppid[$1] = $2; comm[$1] = $6; if ($5 ~ /^pts\//) { fg[$5] = $4; if ($1 == $3) leader[$5] = $1 } }
END {
  for (t in atime) if (fg[t] > 0 && atime[t] > latest) latest = atime[t]
  for (t in atime) {
    if (fg[t] <= 0 || atime[t] <= latest - 8) continue
    outer = comm[ppid[leader[t]]] ~ /^sshd/
    if (best == "" || (bestOuter && !outer) || (bestOuter == outer && atime[t] > atime[best])) { best = t; bestOuter = outer }
  }
  if (best != "") print fg[best]
}' | { read -r pid && readlink "/proc/$pid/cwd"; }
]=]

-- Reuse one connection so that later lookups skip the SSH handshake.
local function remoteDirectory(command)
  local args = {
    command[1], '-o', 'BatchMode=yes', '-o', 'ControlMaster=auto',
    '-o', 'ControlPath=' .. wezterm.home_dir .. '/.ssh/wezterm-%C', '-o', 'ControlPersist=10m',
  }
  for i = 2, #command do
    table.insert(args, command[i])
  end
  table.insert(args, directoryScript)
  local ok, stdout = wezterm.run_child_process(args)
  return ok and stdout:match('^(/[^\n]*)')
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
  local path = remoteDirectory(command)
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
