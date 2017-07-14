--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2017/7/13 0013
-- Time: 下午 4:01
-- To change this template use File | Settings | File Templates.
--
--白名单列表
local whitelist = {
    'test1',
    'user/login',
    'user/register'
}
--路由重写列表
local rewritelist = {
    ['user/([-_a-zA-Z0-9]+)/login'] = 'user/login',
    ['user/([a-zA-Z0-9]+)/register'] = 'user/register'
}
return {
    whitelist = whitelist,
    rewritelist = rewritelist
}