local _M = {}
local http = require "resty.http"
local cjson = require "cjson"
local utils = require "lua.modules.utils"

function _M.getLabOffice(serverUrl, laboratoryOfficeId)
    if laboratoryOfficeId ==nil then return nil end
    utils.checkNotNull(serverUrl, "serverUrl is null")
    utils.checkNotNull(laboratoryOfficeId, "laboratoryOfficeId is null")

    local httpc = http.new()
    local res, err = httpc:request_uri(serverUrl .. "/msa/api/labs/", {
        method = "GET",
        headers = {
            ["Content-Type"] = "application/json"
        },
        ssl_verify = false,
        keepalive_timeout = 60,
        keepalive_pool = 5
    })

    if err~=nil  then
        utils.logError(string.format("Error get office(%s) info:  %s", laboratoryOfficeId, err))
    end

    --utils.log("OFFICE INFO" .. res.body)

    if res~=nil and res.status == 200 then
         local labs = cjson.decode(res.body)
         for k, v in pairs(labs) do
            -- utils.log(cjson.encode(v))
             for k, office in pairs(v.offices) do
                if office.id == laboratoryOfficeId then
                    --utils.log("OFFICE INFO" .. laboratoryOfficeId)
                    office["laboratory"] = v.name
                    return office
                end
             end
         end
    end

    return nil

end

return _M