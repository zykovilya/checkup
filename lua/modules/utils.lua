local _M = {}

function _M.checkNotNull(val, message)
    if not val then
        ngx.status = 400
        ngx.print(message)
        return ngx.exit(400)
    end
    return val
end

return _M