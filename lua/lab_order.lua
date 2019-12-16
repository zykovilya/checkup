
    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    local file = io.open(string.format("/usr/share/nginx/html/files/lab_orders/%s",os.clock()), 'w')
    file:write(body)
    file:close()

    return 201



