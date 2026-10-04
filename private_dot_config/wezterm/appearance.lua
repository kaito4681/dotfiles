local wezterm = require 'wezterm'

local M = {}

function M.apply_to_config(config)
  config.colors = {
    foreground = '#f0f3f6',
    background = '#0a0c10',
    selection_fg = '#0a0c10',
    selection_bg = '#f0f3f6',
    ansi = {
      '#7a828e', '#ff9492', '#26cd4d', '#f0b72f',
      '#71b7ff', '#cb9eff', '#39c5cf', '#d9dee3',
    },
    brights = {
      '#9ea7b3', '#ffb1af', '#4ae168', '#f7c843',
      '#91cbff', '#dbb7ff', '#56d4dd', '#ffffff',
    },
  }

  local function fonts(weight, ja_weight)
    local list = {
      { family = 'JetBrains Mono', weight = weight },
      'Symbols Nerd Font Mono',
    }
    if wezterm.target_triple:find('apple') then
      table.insert(list, { family = 'Hiragino Sans', weight = ja_weight or weight })
    end
    return list
  end

  config.font = wezterm.font_with_fallback(fonts('Regular'))
  -- The default bold weight (ExtraBold) is too heavy.
  config.font_rules = {
    {
      intensity = 'Bold',
      italic = false,
      font = wezterm.font_with_fallback(fonts('Bold', 'DemiBold')),
    },
    {
      intensity = 'Bold',
      italic = true,
      font = wezterm.font_with_fallback(fonts('Bold', 'DemiBold'), { italic = true }),
    },
  }
  config.font_size = 18
  config.window_background_opacity = 0.75
  config.window_padding = {
    left = '10pt',
    right = '10pt',
    top = '10pt',
    bottom = '10pt',
  }
  config.hide_tab_bar_if_only_one_tab = true

  config.default_cursor_style = 'SteadyBlock'
  config.force_reverse_video_cursor = true
end

return M
