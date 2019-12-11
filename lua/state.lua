local cjson = require "cjson"
local auth = require "lua.modules.telemed_auth"
local utils = require "lua.modules.utils"


local personId  = ngx.var.personId
local productOrderId  = ngx.var.productOrderId


local patientInfo = auth.patientInfo(ngx,os.getenv("TMP_SERVER_URL").."/api/auth/person",personId)

ngx.header["firstName"] = patientInfo.firstName


local function getFileName(dirName, personId,productOrderId)
    return string.format(dirName .. "%s_%s.json",personId,productOrderId)
end

local dirName = '/files/state/'
utils.checkAndCreateDirs(dirName);

if ngx.req.get_method() == "POST" or ngx.req.get_method() == "PUT"  then

    ngx.req.read_body()
    local body = ngx.req.get_body_data()
    utils.checkNotNull(body, 'Required request body content is missing');
    body = cjson.decode(body)

    local file = io.open(getFileName(dirName, personId,productOrderId), 'w')
    file:write(cjson.encode(body))
    file:close()
    return 200
else
    local stateFile = getFileName(dirName, personId, productOrderId);
    if utils.fileExists(stateFile) then
        local file = io.open(stateFile);
        local body = file:read("*all");
        ngx.say(body);
        file:close()
    else
        ngx.status = 404
        ngx.print(utils.getErrorResponse("NOT_FOUND","state not found"))
        return ngx.exit(404)
    end
end


