--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/7/14 0014
-- Time: 上午 9:27
-- To change this template use File | Settings | File Templates.
--
-- 获取当前请求的args
local args = ngx.req.get_uri_args()

--如果不存在opt参数请求，报参数请求错误
if not args.opt then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
    return
end
local opt = args.opt

local switch = {
    ["time"] = function()
        return os.date("%Y-%m-%d %X", ngx.time())
    end,
    ["api_success"] = function()
        return api_success(ngx.req.get_uri_args(), '返回成功')
    end,
    ["api_error"] = function()
        return api_error(10002, "返回失败了")
    end,
    ["test"] = function()
        local name = {}
        table.insert(name, "a")

        return api_success({b=table.concat(name, ", ")})
    end
}

local f = switch[opt]
if (f) then
    var_dump(f())
    return true
else -- for case default
    ngx.say("opt not found")
    return false
end

