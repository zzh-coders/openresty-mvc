--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/7/18 0018
-- Time: 下午 3:32
-- To change this template use File | Settings | File Templates.
--
local _M = {
    index = function()
        local userModel = createModel("user")
        --        local result = userModel:addUser("zouzehua")
        --        local result = userModel:selectOne({ name = "zzh2" })
        --        local result = userModel:selectAll({})
        --        local result = userModel:delete({ id = 1 })
        --        local result = userModel:insertAll({
        --            { name = "zzh" },
        --            { name = "zzh1" }
        --        })
        --        local result = userModel:insertOrUpdate({ nickname = "nickname_zzh2" }, { name = "zzh2" })
        --
        --        if result.code == 200 then
        --            api_success(result.data)
        --        else
        --            api_error(result.code, result.msg)
        --        end
                local result = userModel:query("select * from user")

                if result.res then
                    api_success(result.res)
                else
                    api_error(result.errno, result.err)
                end
    end,
}
return _M

