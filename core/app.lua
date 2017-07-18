--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/7/18 0018
-- Time: 下午 2:57
-- To change this template use File | Settings | File Templates.
--

local _M = { _VERSION = '0.1' }
local mt = { __index = _M }
function _M.new(self, uri, debug)
    local tab = {}
    local m, err = ngx.re.match(uri, "([a-zA-Z0-9-]+)/*([a-zA-Z0-9-]+)*")
    local moduleName = m[1] -- 模块名
    local method = m[2] -- 方法名

    if not method then
        method = "index" -- 默认访问index方法
    else
        method = ngx.re.gsub(method, "-", "_")
    end

    tab.method = method
    tab.moduleName = moduleName
    tab.debug = debug
    return setmetatable(tab, mt)
end

function _M.run(self, prefix)
    prefix = prefix or "controller"
    local path = prefix .. "." .. self.moduleName

    -- 尝试引入模块，不存在则报错
    local ret, ctrl, err = pcall(require, path)

    local is_debug = self.debug -- 调试阶段，会输出错误信息到页面上

    if ret == false then
        if is_debug then
            ngx.status = 404
            ngx.say("<p style='font-size: 50px'>Error: <span style='color:red'>" .. ctrl .. "</span> module not found !</p>")
        end
        ngx.exit(404)
    end

    -- 尝试获取模块方法，不存在则报错
    local req_method = ctrl[self.method]

    if req_method == nil then
        if is_debug then
            ngx.status = 404
            ngx.say("<p style='font-size: 50px'>Error: <span style='color:red'>" .. method .. "()</span> method not found in <span style='color:red'>" .. moduleName .. "</span> lua module !</p>")
        end
        ngx.exit(404)
    end

    -- 执行模块方法，报错则显示错误信息，所见即所得，可以追踪lua报错行数
    ret, err = pcall(req_method)

    if ret == false then
        if is_debug then
            ngx.status = 404
            ngx.say("<p style='font-size: 50px'>Error: <span style='color:red'>" .. err .. "</span></p>")
        else
            ngx.exit(500)
        end
    end
end

return _M