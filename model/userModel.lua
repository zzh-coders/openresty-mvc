--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/7/14 0014
-- Time: 下午 2:38
-- To change this template use File | Settings | File Templates.
--
local _usermodel = {}
local model = require("model.model"):new("db_test"):connect()



_usermodel.addUser = function(name)
    return model:insert({ name = name, create_at = get_now_date(), update_at = get_now_date() })
end

return _usermodel