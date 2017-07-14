--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/7/13 0013
-- Time: 下午 3:42
-- To change this template use File | Settings | File Templates.
--
--- 定义NULL常量
_G.NULL = ngx.null

--- 已加载的包
local __loadedMods = {}

--- 加载模块
--
-- @param string namespace 模块名
-- @return table 模块
_G.loadMod = function(namespace)
    -- 查找系统模块
    local module = __loadedMods[namespace]

    if module then
        return module
    end

    -- 查找项目模块
    local pNamespace = ngx.var.ROOT_PATH .. ".lua." .. namespace
    local pModule = __loadedMods[pNamespace]

    if pModule then
        return pModule
    end

    -- 尝试加载系统模块
    local ok, module = pcall(require, namespace)

    if ok then
        __loadedMods[namespace] = module
        return module
    end

    -- 尝试加载项目模块
    local ok, module = pcall(require, pNamespace)

    if ok then
        __loadedMods[pNamespace] = module
        return module
    end

    -- 模块加载失败
    error(module, 2)
end

