local wezterm = require 'wezterm'

local M = {}

-- Print the cwd of the foreground process of the remote pty typed in last,
-- other than the pty the script runs on. Inside tmux, herdr and the like both
-- the ssh session's pty and the inner pane's pty see the input, so prefer the
-- inner one. Linux only updates a pty's input time every 8 seconds. This needs
-- nothing on the remote.
M.script = [=[
{ stat -c 'S %X %U %n' /dev/pts/[0-9]*; ps -eo pid=,ppid=,sid=,tpgid=,tty=,comm=; } | awk -v me="$(id -un)" -v self="$(tty)" '
$1 == "S" { if ($3 == me && $4 != self) { t = $4; sub("^/dev/", "", t); atime[t] = $2 }; next }
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

-- Make the ssh command (up to the destination) share one connection per host,
-- so that later connections skip the SSH handshake.
function M.shareConnection(command)
  local args = {
    command[1], '-o', 'ControlMaster=auto',
    '-o', 'ControlPath=' .. wezterm.home_dir .. '/.ssh/wezterm-%C', '-o', 'ControlPersist=10m',
  }
  for i = 2, #command do
    table.insert(args, command[i])
  end
  return args
end

-- Return the remote directory for the ssh command up to the destination.
function M.remote(command)
  local args = M.shareConnection(command)
  table.insert(args, 2, '-o')
  table.insert(args, 3, 'BatchMode=yes')
  table.insert(args, M.script)
  local ok, stdout = wezterm.run_child_process(args)
  return ok and stdout:match('^(/[^\n]*)')
end

return M
