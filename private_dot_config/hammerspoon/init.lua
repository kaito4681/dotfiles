require('reload').start()

local appToggle = require('app_toggle')
appToggle.bind({ 'cmd' }, 'space', 'com.github.wez.wezterm')
appToggle.bind({ 'cmd', 'shift' }, 'space', 'com.mitchellh.ghostty')
