local _NewSet = {}

local mt = { __index = _NewSet }

function _NewSet:insert (value)
	local index = self:find(value)
	if not index then
		return false
	end
    table.insert(self.set,value)
end

function _NewSet:remove (value) 
	if self:isEmpty()then
		return false
	end
	
    local index = self:find(value)  
    if index then  
        local top = table.remove(self.set,index)
    end
end
		  
function _NewSet:find (value)
	if self:isEmpty() then
		return false
	end
	local index = 0
	for k,v in pairs(self.set) do
		if v == value then
		    index = k
		    break
	    end
	end
    return (index>0 and true or false)
end

function _NewSet:isEmpty ()
	local len = #(self.set)
	return (len<1 and true or false)
end

function _NewSet.new (self,set)
	set = set or {}
    return setmetatable({set = set}, mt)
end

return _NewSet