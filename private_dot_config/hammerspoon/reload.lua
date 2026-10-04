local M = {}

-- Reload when a .lua file changes.
function M.start()
  M.watcher = hs.pathwatcher.new(hs.configdir, function(files)
    for _, file in ipairs(files) do
      if file:sub(-4) == '.lua' then
        hs.reload()
        return
      end
    end
  end):start()
end

return M
