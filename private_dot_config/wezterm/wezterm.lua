local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.automatically_reload_config = true

require('appearance').apply_to_config(config)
require('keys').apply_to_config(config)

if wezterm.target_triple:find('apple') then
  require('macos').apply_to_config(config)
  require('quit').apply_to_config(config)
  require('vscode').apply_to_config(config)
end

return config
