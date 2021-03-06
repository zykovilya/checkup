local _M = {}
local utils = require "lua.modules.utils"
local shell = require "resty.shell"


function _M.attachFileToPatient(url, cookie, filePath, fileType)
    local stdin = ""
    local timeout = 2000  -- ms
    local max_size = 10000  -- byte


    local command = [[curl '%s/api/file/upload' --form 'file=@%s' -H 'Content-Type: multipart/form-data' -H 'Cookie: %s' ]] --;filename=%s
    command = string.format(command,url, filePath--[[, name]], cookie)
    utils.log("exec add file: " .. command)

    local ok, stdout, stderr, reason, status =  shell.run(command, stdin, timeout, max_size)
    utils.log("exec add file result = : " .. stdout)


    command = [[curl -X POST '%s/api/patient/document/%s' -H 'Content-Type: application/json' -H 'Cookie: %s' -d '{"fileType":"%s"}']]
    utils.log("exec attach: " .. command)
    command = string.format(command, url, stdout, cookie, fileType)

    ok, stdout, stderr, reason, status =  shell.run(command, stdin, timeout, max_size)
    utils.log("exec attach result: " .. stdout)

   return stdout

end

return _M