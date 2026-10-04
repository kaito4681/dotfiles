-- Toggle an application's visibility.
local launchTimers = {}

local function launch(bundleID)
  local startedAt = hs.timer.absoluteTime()
  launchTimers[bundleID] = hs.timer.doEvery(0.1, function()
    local app = hs.application.get(bundleID)
    if (app and app:mainWindow())
      or hs.timer.absoluteTime() - startedAt >= 30 * 1e9 then
      launchTimers[bundleID]:stop()
      launchTimers[bundleID] = nil
    end
  end)
  hs.application.launchOrFocusByBundleID(bundleID)
end

local M = {}

function M.bind(mods, key, bundleID)
  hs.hotkey.bind(mods, key, function()
    if launchTimers[bundleID] then
      return
    end

    local app = hs.application.get(bundleID)
    if not app or not app:mainWindow() then
      launch(bundleID)
    elseif not app:isHidden() then
      app:hide()
    else
      -- Activate the existing application without sending another open request.
      app:unhide()
      app:activate()
    end
  end)
end

return M
