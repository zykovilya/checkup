local _M = {}
local http = require "resty.http"
local cjson = require "cjson"
local utils = require "lua.modules.utils"


-- returtn product Info or exception
function _M.getProductInfo(serverUrl, productId)
    utils.checkNotNull(serverUrl, "serverUrl is null")
    utils.checkNotNull(productId, "productId is null")

    local httpc = http.new()
    local cookie = ngx.req.get_headers()["cookie"]

    if (cookie == nil) then
        return utils.ngxReturnExit(403, "FORBIDDEN", "required Cookie")
    end

    local res, err = httpc:request_uri(serverUrl .. "/api/product/patient/"..productId, {
        method = "GET",
        headers = {
            ["Content-Type"] = "application/json",
            ["Cookie"] = string.format("%s", cookie)
        },
        ssl_verify = false,
        keepalive_timeout = 60,
        keepalive_pool = 5
    })
    local productInfo;
    if err  or res.status ~= 200  then
        utils.logError(string.format("Error get product(%s) info:  %s", productId, err))
    else
        productInfo = cjson.decode(res.body)
    end
    --utils.log("PRODUCT INFO" .. res.body)

    return productInfo
end

return _M