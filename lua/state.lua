local cjson = require "cjson"
local auth = require "lua.modules.telemed_auth"

local patientId  = ngx.var.patientId
local clientProductId  = ngx.var.clientProductId


local patientInfo = auth.patientInfo(ngx,os.getenv("TMP_SERVER_URL").."/api/auth/person",patientId)

ngx.header["firstName"] = patientInfo.firstName


local function getFileName(patientId,clientProductId)
   return string.format("/files/state/%s_%s.json",patientId,clientProductId)
end


if ngx.req.get_method() == "POST" or ngx.req.get_method() == "PUT"  then

    ngx.req.read_body()
    local body = cjson.decode(ngx.req.get_body_data())

    local file = io.open(getFileName(patientId,clientProductId), 'w')
    file:write(cjson.encode(body))
    file:close()
    return 200
else
    local file = io.open(getFileName(patientId,clientProductId), 'r')
    local body = file:read()
    ngx.say(body)
    file:close()
end


