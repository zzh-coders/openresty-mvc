local _config = {}

_config.db = {
    host = '192.168.50.128',
    port = 3306,
    database = 'test',
    user = 'root',
    password = '123456'
}

_config.redis = {
    host = "192.168.50.128",
    port = 6379
}
return _config

