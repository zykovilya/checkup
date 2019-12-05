local _M = {}
local cjson = require "cjson"


function _M.checkNotNull(val, message)
    if not val then
        ngx.status = 400
        ngx.print(_M.getErrorResponse("BAD_REQUEST", message));
        return ngx.exit(400)
    end
    return val
end

function _M.getErrorResponse(errorCode, errorMessage)
       local response = {["message"]=errorMessage, ["code"]=errorCode};
       return cjson.encode(response);
end

function _M.scandir(directory)
    local i, t, popen = 0, {}, io.popen
    local pfile = popen('ls "'..directory..'"')
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function _M.fileExists(name)
    local f=io.open(name,"r")
    if f~=nil then io.close(f) return true else return false end
end


function _M.checkAndCreateDirs(path)
    if(not _M.fileExists(path)) then
        os.execute('mkdir -p "' .. path ..'"')
    end
end


function _M.split(s, sep)
    local fields = {}

    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)

    return fields
end




return _M