--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/7/13 0013
-- Time: 下午 6:01
-- To change this template use File | Settings | File Templates.
--
function lua_string_split(str, split_char)
    local sub_str_tab = {};

    for w in string.gmatch(str, "([^'" .. split_char .. "']+)") do --按照“,”分割字符串
        table.insert(sub_str_tab, w)
    end

    return sub_str_tab;
end

--- @brief 调试时打印变量的值
--- @param data 要打印的字符串
function var_dump(data)
    if type(data) ~= "table" then
        ngx.say(data)
    else
        for k, v in ipairs(data) do
            ngx.say(k .. ":" .. v)
        end
    end
end

function api_success(data, message)
    local _table = {}
    _table.code = 200
    _table.data = data
    _table.msg = message or "成功"
    return json_encode(_table)
end

function api_error(code, message)
    local _table = {}
    _table.code = code or "1001"
    _table.data = {}
    _table.msg = message or "系统错误"
    return json_encode(_table)
end

function json_encode(data)
    ngx.header['Content-Type'] = 'application/json; charset=utf-8'
    local cjson = require "cjson"
    return cjson.encode(data)
end

function try(func)
    local ok, err = pcall(func)
    return {
        catch = function(self, handle)
            if not ok then
                handle(err)
            end
            return self
        end,
        finally = function(self, handle)
            handle()
            return self -- Optional
        end
    }
end

function get_timezone()
    local now = os.time()
    return os.difftime(now, os.time(os.date("!*t", now)))
end

function get_now_date()
    return os.date("%Y-%m-%d %X", ngx.time())
end
