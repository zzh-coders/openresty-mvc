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
    return self
end


function _Model.formatQuery(self, _data, sprit_string)
    sprit_string = sprit_string or ","
    local result = {}
    for k, v in pairs(_data) do
        table.insert(result, "`" .. k .. "`=" .. (type(v) == "number" and v or "'" .. v .. "'"))
    end
    return table.concat(result, sprit_string)
end


--插入一条数据，返回last_insert_id
function _Model.insert(self, _data)
    if type(_data) ~= "table" then
        return result(500, {}, "格式错误")
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
        return result(501, {}, "添加失败" .. err .. ';sql:' .. sql)
    else
        return result(200, res.insert_id)
    end
end

--插入多条数据
function _Model.insertAll(self, _data)
    if type(_data) ~= "table" then
        return result(500, {}, "格式错误")
    end
    local name = {}
    local value = {}
    --获取插入的name值
    for k, v in pairs(_data[1]) do
        table.insert(name, "`" .. k .. "`")
    end

    for k, v in pairs(_data) do
        local sub_value = {}
        for k_i, v_i in pairs(v) do
            if type(v) == "number" then
                table.insert(sub_value, v_i)
            else
                table.insert(sub_value, "'" .. v_i .. "'")
            end
        end
        table.insert(value, "(" .. table.concat(sub_value, ", ") .. ")")
    end

    local sql = 'INSERT INTO ' .. self.table_name .. '(' .. table.concat(name, ", ") .. ') VALUES ' .. table.concat(value, ",")
    local res, err, errno, sqlstate = self.db:query(sql)
    if not res then
        return result(501, {}, "添加失败" .. err .. ';sql:' .. sql)
    else
        return result(200, res.insert_id)
    end
end

--先判断是否存在，再进行更新或则插入
function _Model.insertOrUpdate(self, _data, condition)
    if type(_data) ~= "table" then
        return result(500, {}, "格式错误")
    end
    local result = self:selectOne(condition)
    if result.code == 200 then
        return self:update(_data, condition)
    else
        for k, v in pairs(condition) do
            _data[k] = v
        end
        return self:insert(_data)
    end
end

--执行sql语句
function _Model.query(self, sql)
    local res, err, errno, sqlstate = self.db:query(sql)
    return {
        res = res,
        err = err,
        errno = errno,
        sqlstate = sqlstate
    }
end

--更新数据
function _Model.update(self, _data, condition)
    if type(_data) ~= "table" then
        return result(500, {}, "插入数据格式错误")
    end
    if type(condition) ~= "table" then
        return result(500, {}, "条件数据格式错误")
    end

    local where = self:formatQuery(condition, "AND")
    local set = self:formatQuery(_data)

    local sql = 'UPDATE ' .. self.table_name .. ' SET ' .. set .. ' WHERE ' .. where
    local res, err, errno, sqlstate = self.db:query(sql)
    if not res or res.affected_rows < 1 then
        return result(501, {}, "修改失败" .. err .. ';sql:' .. sql)
    else
        return result(200, res.affected_rows)
    end
end

--数据统计
function _Model.count(self, condition)
    if type(condition) ~= "table" then
        return result(500, {}, "条件数据格式错误")
    end
    local where = self:formatQuery(condition, "AND")

    local sql = 'SELECT COUNT(*) as row_counts FROM ' .. self.table_name .. ' WHERE ' .. where
    local data, err, errno, sqlstate = self.db:query(sql)
    return data.row_counts
end

--查询一条数据
function _Model.selectOne(self, condition)
    if type(condition) ~= "table" then
        return result(500, {}, "条件数据格式错误")
    end
    local where = "1=1"
    if not isEmpty(condition) then
        where = self:formatQuery(condition, "AND")
    end
    local sql = 'SELECT * FROM ' .. self.table_name .. ' WHERE ' .. where .. ' LIMIT 1'
    local data, err, errno, sqlstate = self.db:query(sql)
    if not isEmpty(data) then
        return result(200, data[1])
    end
    return result(404, {}, '数据不存在')
end

function _Model.selectAll(self, condition, orderBy, limit)
    if type(condition) ~= "table" then
        return result(500, {}, "条件数据格式错误")
    end
    local where = "1=1"
    if not isEmpty(condition) then
        where = self:formatQuery(condition, "AND")
    end

    if not isEmpty(orderBy) then
        orderBy = " ORDER BY " .. orderBy
    else
        orderBy = ""
    end
    if not isEmpty(limit) then
        limit = " LIMIT " .. limit
    else
        limit = " LIMIT 15"
    end
    local sql = 'SELECT * FROM ' .. self.table_name .. ' WHERE ' .. where .. orderBy .. limit

    local data, err, errno, sqlstate = self.db:query(sql)
    if not isEmpty(data) then
        return result(200, data)
    end
    return result(404, {}, '数据为空')
end

--删除数据
function _Model.delete(self, condition)
    if type(condition) ~= "table" then
        return result(500, {}, "条件数据格式错误")
    end
    local where = self:formatQuery(condition, "AND")
    local sql = 'DELETE FROM ' .. self.table_name .. ' WHERE ' .. where
    local res, err, errno, sqlstate = self.db:query(sql)
    if not res or res.affected_rows < 1 then
        return result(0)
    end

    return result(200)
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

function _Model.close(self)
    local sock = self.sock
    if not sock then
        return nil, "not initialized"
    end
    if self.subscribed then
        return nil, "subscribed state"
    end
    return sock:setkeepalive(10000, 50)
end

return _Model

