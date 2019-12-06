local _M = {}
local http = require "resty.http"
local cjson = require "cjson"
local utils = require "lua.modules.utils"


-- returtn patientInfo or exception
function _M.patientInfo(ngx, url, referencepersonId)
    local httpc = http.new()
    local cookie = ngx.req.get_headers()["cookie"]
    --ngx.header["Cookie"] = cookie


    if (not cookie) then
        ngx.status = 403
        ngx.print(utils.getErrorResponse("FORBIDDEN","required Cookie"))
        return ngx.exit(403)
    end


    local res, err = httpc:request_uri(url, {
        method = "GET",
        headers = {
            ["Content-Type"] = "application/json",
            ["Cookie"] = string.format("%s", cookie)
        },
        ssl_verify = false,
        keepalive_timeout = 60,
        keepalive_pool = 5
    })
    if not res then
        ngx.print(utils.getErrorResponse("ERROR",err))
        ngx.log(ngx.ERR, string.format("Auth failed: %s", err))
        return ngx.exit(500)
    elseif res.status ~= 200 then
        ngx.status = 500
        local errorMessage;
        if res.body ~= nil and res.body ~= '' then
            errorMessage = res.body;
            ngx.log(ngx.ERR, string.format("Auth failed: %s", res.body))
        else
            errorMessage = string.format("{error: \"%s\"}", err)
            ngx.log(ngx.ERR, string.format("Auth failed: %s", err))
        end
        -- res.status
        ngx.print(utils.getErrorResponse("ERROR",errorMessage))
        return ngx.exit(500)
    end

    local patientInfo = cjson.decode(res.body)

    if (referencepersonId ~= nil and patientInfo.id ~= referencepersonId) then
        ngx.status = 403
        ngx.print(utils.getErrorResponse("FORBIDDEN",string.format("Auth failed: persons is not equals (%s,%s) ", referencepersonId, patientInfo.id)))
        ngx.log(ngx.ERR, message)
        return ngx.exit(403)
    end


    ngx.log(ngx.NOTICE, string.format("Patient is auth: id = %s, lastName=%s", patientInfo.id, patientInfo.lastName))

    return patientInfo
end

return _M