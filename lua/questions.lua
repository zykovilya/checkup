ngx.req.read_body()
local body = ngx.req.get_body_data()
local file = io.open(string.format("/usr/share/nginx/html/files/questions/%s",os.clock()), 'w')
file:write(body)
file:close()
return ngx.redirect("https://test-telemed.drclinics.ru/msa/api/questions/success.html",301)

