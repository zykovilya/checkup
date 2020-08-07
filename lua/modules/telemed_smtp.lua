local _M = {}
local smtp = require("resty.mail")
local utils = require "lua.modules.utils"

-- https://github.com/GUI/lua-resty-mail
-- returtn personInfo or exception
function _M.sendMail(ngx, to, subject, message)

    local from = string.format("<%s>", os.getenv("SMTP_FROM"))
    local mailer, error = mail.new({
      host = os.getenv("SMTP_SERVER"),
      port = os.getenv("SMTP_PORT"),
      starttls = os.getenv("SMTP_STARTTLS")=='true',
      ssl = os.getenv("SMTP_SSL")=='true',
      username = os.getenv("SMTP_USER"),
      password = os.getenv("SMTP_PASSWORD"),
    })

    if error then
       ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
       local message = string.format("Error while send mail(%s) ", to);
       ngx.print(utils.getErrorResponse("ERROR", "Ошибка при отправке сообщения"))
       ngx.log(ngx.ERR, message .. error)
       return ngx.exit(500)
    end

    local res, error = mailer:send({
      from = from,
      to = { to },
      subject = subject,
      text = message
    })

    ngx.log(ngx.NOTICE, string.format("Send mail: %s, %s, %s, %s, %s, %s", to, from, os.getenv("SMTP_USER"), os.getenv("SMTP_SERVER"), os.getenv("SMTP_PORT"), os.getenv("SMTP_PASSWORD")))
    if not res or error then
        ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
        local message = string.format("Error while send mail(%s) ", to);
        ngx.print(utils.getErrorResponse("ERROR", "Ошибка при отправке сообщения"))
        ngx.log(ngx.ERR, message .. error)
        return ngx.exit(500)
    end


    ngx.log(ngx.NOTICE, string.format("Send mail to %s: /n %s /n %s", to, subject, message))
end

return _M