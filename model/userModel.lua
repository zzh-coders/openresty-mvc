--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/7/14 0014
-- Time: 下午 2:38
-- To change this template use File | Settings | File Templates.
--
local modelBase = require("model.model")
local _M = {}
function _M.new()
    local model = modelBase:new("user"):connect()
    return setmetatable({ model = model }, { __index = model })
end

function _M.addUser(self, name)
    return self.model:insert({ name = name, created_at = get_now_date(), update_at = get_now_date() })
end

return _M