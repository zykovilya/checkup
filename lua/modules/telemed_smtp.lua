local _M = {}
local smtp = require("resty.smtp")
local utils = require "lua.modules.utils"

-- https://github.com/GUI/lua-resty-mail
-- returtn personInfo or exception
function _M.sendMail(ngx, to, subject, message)

    -- Загружаем библиотеку для работы с SMTP
    local from = string.format("<%s>", os.getenv("SMTP_FROM"))

    -- Формируем данные письма
    local mesgt = {
        headers = {
            to = to,
            from = from,
            subject = subject,
            ["content-type"] = "text/plain; charset='utf-8'"
        },
        body = message
    }

    local source = smtp.message(mesgt)
    -- Выполняем отправку письма
    local res, error = smtp.send {
        from = from,
        rcpt = to,
        source = source,
        user = os.getenv("SMTP_USER"),
        password = os.getenv("SMTP_PASSWORD"),
        server = os.getenv("SMTP_SERVER"),
        port = os.getenv("SMTP_PORT"),
        ssl = { enable = os.getenv("SMTP_SSL")=='true', verify_cert = false }
    }

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