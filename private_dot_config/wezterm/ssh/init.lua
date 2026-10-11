local M = {}

function M.apply_to_config(config)
  require('ssh.vscode').apply_to_config(config, { key = 'o', mods = 'SUPER|SHIFT' })
  require('ssh.tab').apply_to_config(config)
end

return M
