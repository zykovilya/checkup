local cookie = ngx.req.get_headers()["Cookie"]
ngx.log(ngx.NOTICE, string.format("Cookie: %s", cookie))
ngx.header["Cookie"] = cookie


ngx.req.read_body()
local body = ngx.req.get_body_data()
local file = io.open(string.format("/files/questions/%s",os.clock()), 'w')
file:write(body)
file:close()
return ngx.redirect("https://test-telemed.drclinics.ru/msa/api/questions/success.html",301)

