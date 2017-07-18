--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/7/13 0013
-- Time: 下午 3:05
-- To change this template use File | Settings | File Templates.
--

local ROOT_PATH = ngx.var.ROOT_PATH
--require加载需要的lua脚本路径
package.path = package.path .. ROOT_PATH .. "/?.lua;;"
require("common.helper")
local uri = ngx.var.uri

-- 默认首页
if uri == "" or uri == "/" then
    local res = ngx.location.capture("/index.html", {})
    if res.status == 200 then
        success(res.body)
    end
    return
end

local config = require("common.config")
--进行黑白名单过滤
--local api_route = require("core.app_route"):new("common.route_config")
--
--api_route:route_verify()


--将请求转发到controller上面
local app = require("core.app")
app:new(uri, config.app.debug):run(config.app.controllerName)


--
--
--
--
--local uri_table = lua_string_split(uri, "/")
--
--- -请求参数为空，默认用index/index
-- if uri_table[1] == nil then
-- table.insert(uri_table, 'index')
-- end
--
-- if uri_table[2] == nil then
-- table.insert(uri_table, 'index')
-- end
--
-- local controller_name = uri_table[1]
-- local method_name = uri_table[2]
--
-- ngx.ctx.root_path = ROOT_PATH
-- ngx.ctx.time = os.time() + 8 * 3600
--
-- try(function()
-- require("controller." .. controller_name .. "." .. method_name)
-- end):catch(function(err)
-- ngx.say(err)
-- end):finally(function()
-- -- ngx.say("Finally!")
-- end)






