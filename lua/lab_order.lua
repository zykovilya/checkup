local cjson = require "cjson"
local auth = require "lua.modules.telemed_auth"
local smtp = require "lua.modules.telemed_smtp"

local function checkNotNull(val, message)

    if not val then
        ngx.status = 400
        ngx.print(message)
        return ngx.exit(400)
    end
    return val
end

ngx.req.read_body()

-------
local params, err = ngx.req.get_post_args()

if err then
    ngx.status = 400
    ngx.print("need body")
    return ngx.exit(400)
end

local patientId = checkNotNull(params.patientId, "need patientId")
local productId = checkNotNull(params.productId, "need productId")
local clientProductId = checkNotNull(params.clientProductId, "need clientProductId")
local laboratoryOfficeId = checkNotNull(params.laboratoryOfficeId, "need laboratoryOfficeId")

local patientInfo = auth.patientInfo(ngx, "https://test-telemed.drclinics.ru/api/auth/person", patientId)
-----------
local subject = string.format("Пользователь %s %s %s(%s) записался в лабораторию %s.", patientInfo.firstName, patientInfo.middleName, patientInfo.lastName, patientInfo.id, laboratoryOfficeId)
local message = string.format("%s \n Продукт:%s, \n Заказ:%s. \n %s", subject, productId, clientProductId, cjson.encode(patientInfo))
local to = string.format("<%s>",os.getenv("SMTP_TO"))
smtp.sendMail(ngx, to, subject, message)
-------
local body = ngx.req.get_body_data()
local file = io.open(string.format("/files/lab_orders/%s", os.clock()), 'w')
file:write(body)
file:close()

return 201



