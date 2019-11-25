local _M = {}

-- returtn patientInfo or exception
function _M.sendMail(ngx, to, subject, message)

    local smtp = require("resty.smtp")
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
        port = os.getenv("SMTP_PORT")
    }

    ngx.log(ngx.NOTICE, string.format("Send mail: %s, %s, %s, %s, %s, %s", to, from, os.getenv("SMTP_USER"), os.getenv("SMTP_SERVER"), os.getenv("SMTP_PORT"), os.getenv("SMTP_PASSWORD")))


    if not res or error then
        ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
        local message = string.format("Error while send mail(%s) ", to);
        ngx.print(message)
        ngx.print(error)
        ngx.log(ngx.ERR, message)
        return ngx.exit(500)
    end


    ngx.log(ngx.NOTICE, string.format("Send mail to %s: /n %s /n %s", to, subject, message))
end

return _M