--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/7/18 0018
-- Time: 下午 3:18
-- To change this template use File | Settings | File Templates.
--
local _Common = {
    time = function()
        success(ngx.time())
    end,
    date = function()
        success(os.date("%Y-%m-%d %X", ngx.time()))
    end
}
return _Common

