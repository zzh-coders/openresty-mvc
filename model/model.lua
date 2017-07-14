--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/7/14 0014
-- Time: 下午 2:07
-- To change this template use File | Settings | File Templates.
local mysql = require 'resty.mysql'
local _Model = {}

local mt = { __index = _Model }

function _Model.connect(self)
    local ok, err, errno, sqlstate = self.db:connect({
        host = self.config.host,
        port = self.config.port,
        database = self.config.database,
        user = self.config.user,
        password = self.config.password
    })
    if not ok then
        ngx.say(api_error(500, 'mysql连接不上' .. err))
    end
    self.db:query("SET NAMES utf8")
end


function _Model.formatQuery(self, _data, sprit_string)
    if type(_data) ~= "table" then
        ngx.say(api_error(500, '格式错误'))
        ngx.exit()
    end
    sprit_string = sprit_string or ","
    local result = ""
    for k, v in ipairs(_data) do
        result = result .. sprit_string .. "`" .. k .. "`="
        if type(v) == "number" then
            result = result .. k
        else
            result = result .. "'" .. k .. "'"
        end
    end
    return string.gsub(result, sprit_string, '', 1)
end


--插入一条数据，返回last_insert_id
function _Model.insert(self, _data)
    if type(_data) ~= "table" then
        ngx.say(api_error(500, '格式错误'))
        ngx.exit()
    end
    local name = {}
    local value = {}
    for k, v in pairs(_data) do
        table.insert(name, "`" .. k .. "`")
        if type(v) == "number" then
            table.insert(value, "" .. v)
        else
            table.insert(value, "'" .. v .. "'")
        end
    end
    local sql = 'INSERT INTO ' .. self.table_name .. '(' .. table.concat(name, ", ") .. ') VALUES (' .. table.concat(value, ", ") .. ')'
    local res, err, errno, sqlstate = self.db:query(sql)
    if not res then
        ngx.say(api_error(501, "添加失败" .. err .. ';sql:' .. sql))
        return
    else
        return res.insert_id
    end
    return 0
end

--插入多条数据
function _Model.insertAll(self, _data)
    if type(_data) ~= "table" then
        ngx.say(api_error(500, '格式错误'))
        ngx.exit()
    end
    local name = ""
    --获取插入的name值
    for k, v in ipairs(_data[1]) do
        name = name .. ",`" .. k .. "`"
    end
    local value = ""
    for k, v in ipairs(_data) do
        value = value .. "("
        for k_i, v_i in ipairs(v) do
            if type(v) == "number" then
                value = value .. "," .. v_i
            else
                value = value .. ",'" .. v_i .. "'"
            end
        end
        value = value .. ")"
    end
    name = string.gsub(name, ",", "", 1)
    value = string.gsub(value, ",", "", 1)
    local sql = 'INSERT INTO ' .. self.table_name .. '(' .. name .. ') VALUES ' .. value
    local res, err, errno, sqlstate = self.db:query(sql)
    if not res then
        ngx.say(api_error(501, "添加失败" .. err .. ';sql:' .. sql))
        ngx.exit()
    else
        return res.insert_id
    end
    return 0
end

--先判断是否存在，再进行更新或则插入
function _Model.insertOrUpdate(self, _data, condition)
end

--更新数据
function _Model.update(self, _data, condition)
    if type(_data) ~= "table" then
        ngx.say(api_error(500, '插入数据格式错误'))
        ngx.exit()
    end
    if type(condition) ~= "table" then
        ngx.say(api_error(500, '条件数据格式错误'))
        ngx.exit()
    end

    local where self.formatQuery(condition, "AND")
    local set = self.formatQuery(_data)

    local sql = 'UPDATE ' .. self.table_name .. ' SET ' .. set .. ' WHERE ' .. where
    local res, err, errno, sqlstate = self.db:query(sql)
    if not res or res.affected_rows < 1 then
        ngx.say(api_error(501, "修改失败" .. err .. ';sql:' .. sql))
        ngx.exit()
    else
        return res.affected_rows
    end
    return true
end

--数据统计
function _Model.count(self, condition)
    if type(condition) ~= "table" then
        ngx.say(api_error(500, '条件数据格式错误'))
        ngx.exit()
    end
    local where self.formatQuery(condition, "AND")

    local sql = 'SELECT COUNT(*) as row_counts FROM ' .. self.table_name .. ' WHERE ' .. where
    local data, err, errno, sqlstate = self.db:query(sql)
    return data.row_counts
end

--查询一条数据
function _Model.selectOne(self, condition)
    if type(condition) ~= "table" then
        ngx.say(api_error(500, '条件数据格式错误'))
        ngx.exit()
    end
    local where self.formatQuery(condition, "AND")

    local sql = 'SELECT * FROM ' .. self.table_name .. ' WHERE ' .. where .. ' LIMIT 1'
    local data, err, errno, sqlstate = self.db:query(sql)
    if data ~= nil then
        return data
    end
    return {}
end

function _Model.selectAll(self, condition, orderBy, limit)
    if type(condition) ~= "table" then
        ngx.say(api_error(500, '条件数据格式错误'))
        ngx.exit()
    end
    local where self.formatQuery(condition, "AND")
    if orderBy then
        orderBy = " ORDER BY " .. orderBy
    end
    if limit then
        limit = " LIMIT " .. limit
    else
        limit = " LIMIT 15"
    end
    local sql = 'SELECT * FROM ' .. self.table_name .. ' WHERE ' .. where .. orderBy .. limit
    local data, err, errno, sqlstate = self.db:query(sql)
    if data ~= nil then
        return data
    end
    return {}
end

--删除数据
function _Model.delete(self, condition)
    if type(condition) ~= "table" then
        ngx.say(api_error(500, '条件数据格式错误'))
        ngx.exit()
    end
    local where self.formatQuery(condition, "AND")
    local sql = 'DELETE FROM ' .. self.table_name .. ' WHERE ' .. where
    local res, err, errno, sqlstate = self.db:query(sql)
    if not res or res.affected_rows < 1 then
        return false
    end

    return true
end

function _Model.new(self, table_name, db_config)
    if not db_config then
        local config = require("common.config")
        db_config = config.db
    end
    local db, err = mysql:new()
    if not db then
        var_dump(api_error(500, '未安装mysql客户端' .. err))
        return
    end

    return setmetatable({ config = db_config, db = db, table_name = table_name }, mt)
end

return _Model

