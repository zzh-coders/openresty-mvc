--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/7/18 0018
-- Time: 下午 3:12
-- To change this template use File | Settings | File Templates.
--
local _Index = {
    index = function()
        view("index/index.html", { message = "你好呀" })
    end
}

return _Index