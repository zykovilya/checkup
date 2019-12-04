local cjson = require "cjson"
local auth = require "lua.modules.telemed_auth"
local utils = require "lua.modules.utils"


local patientId  = ngx.var.patientId
local clientProductId  = ngx.var.clientProductId


local patientInfo = auth.patientInfo(ngx,os.getenv("TMP_SERVER_URL").."/api/auth/person",patientId)

ngx.header["firstName"] = patientInfo.firstName


local function getFileName(dirName, patientId,clientProductId)
    return string.format(dirName .. "%s_%s.json",patientId,clientProductId)
end

local dirName = '/files/state/'
utils.checkAndCreateDirs(dirName);

if ngx.req.get_method() == "POST" or ngx.req.get_method() == "PUT"  then

    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    utils.checkNotNull(body, 'Required request body content is missing');
    body = cjson.decode(body)

    local file = io.open(getFileName(dirName, patientId,clientProductId), 'w')
    file:write(cjson.encode(body))
    file:close()
    return 200
else
    local stateFile = getFileName(dirName, patientId, clientProductId);
    if utils.fileExists(stateFile) then
        local file = io.open(stateFile, 'r')
        local body = file:read()
        ngx.say(body)
        file:close()
    else
        ngx.status = 404
        ngx.print('state not found')
        return ngx.exit(404)
    end
end


