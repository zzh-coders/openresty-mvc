# openresty-mvc
nginx.conf
http模块增加

...
    lua_package_path '$prefix/lua/?.lua;/usr/local/share/lua/5.1/?.lua;';
    resolver 8.8.8.8;
    lua_code_cache off;
    init_by_lua_file /data/lua_code/project/init.lua;
...


vhost-conf文件配置
server {
        listen       8081;
        server_name  127.0.0.1;
        set $ROOT_PATH /data/lua_code/project;
        set $template_root $ROOT_PATH/html;
        error_log /data/log/nginx/project_error.log;
        location ~ ^([-_a-zA-Z0-9/]+) {
                set $api_uri $1;
                default_type 'text/html';
                content_by_lua_file $ROOT_PATH/index.lua;
        }

}
