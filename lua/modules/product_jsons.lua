local _M = {}
local http = require "resty.http"
local cjson = require "cjson"
local utils = require "lua.modules.utils"


-- returtn product Info or exception
function _M.getJson(jsonUrl)
    utils.checkNotNull(jsonUrl, "jsonUrl is null")

    local httpc = http.new()
    local cookie = ngx.req.get_headers()["cookie"]

    if (cookie == nil) then
        return utils.ngxReturnExit(403, "FORBIDDEN", "required Cookie")
    end

    local res, err = httpc:request_uri(jsonUrl, {
        method = "GET",
        headers = {
            ["Content-Type"] = "application/json",
            ["Cookie"] = string.format("%s", cookie)
        },
        ssl_verify = false,
        keepalive_timeout = 60,
        keepalive_pool = 3
    })
    local json;
    if err  or res.status ~= 200  then
        utils.logError(string.format("Error get json(%s): %s", jsonUrl, err))
    else
        json = cjson.decode(res.body)
    end
    utils.log("GET JSON: " .. jsonUrl .. "\n" .. res.body)

    return json
end

return _M