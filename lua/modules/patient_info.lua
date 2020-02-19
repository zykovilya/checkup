local _M = {}
local http = require "resty.http"
local cjson = require "cjson"
local utils = require "lua.modules.utils"


-- returtn patientInfo
function _M.getPatientInfo(serverUrl)
    utils.checkNotNull(serverUrl, "serverUrl is null")


    local httpc = http.new()
    local cookie = ngx.req.get_headers()["cookie"]

    if (cookie == nil) then
        return utils.ngxReturnExit(403, "FORBIDDEN", "required Cookie")
    end

    utils.log("CALL" .. serverUrl .. "/api/patient")
    local res, err = httpc:request_uri(serverUrl .. "/api/patient", {
        method = "GET",
        headers = {
            ["Content-Type"] = "application/json",
            ["Cookie"] = string.format("%s", cookie)
        },
        ssl_verify = false,
        keepalive_timeout = 60,
        keepalive_pool = 5
    })
    local patientInfo;
    if err  or res.status ~= 200  then
        utils.logError(string.format("Error get patient info:  %s", err))
    else
        patientInfo = cjson.decode(res.body)
    end
    utils.log("PATIENT INFO" .. res.body)

    return patientInfo
end

return _M