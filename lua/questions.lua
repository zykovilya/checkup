local auth = require "lua.modules.telemed_auth"
local utils = require "lua.modules.utils"
local smtp = require "lua.modules.telemed_smtp"
local cjson = require "cjson"


ngx.req.read_body()

-------
local params, err = ngx.req.get_post_args()

if err then
    ngx.status = 400
    ngx.print("need body")
    return ngx.exit(400)
end

local patientId = utils.checkNotNull(params.patientId, "need patientId")
local productId = utils.checkNotNull(params.productId, "need productId")
local clientProductId = utils.checkNotNull(params.clientProductId, "need clientProductId")
local patientInfo = auth.patientInfo(ngx, "https://test-telemed.drclinics.ru/api/auth/person", patientId)

local buff = ""
for k,v in pairs(params) do
    if(k~='patientId' and k~='productId' and k~='clientProductId') then
        buff =buff .. k .. ": " .. v .."\n"
    end
end

----------------
local file = io.open(string.format("/files/questions/%s_%s_%s",productId,patientId,clientProductId), 'w')
file:write(buff)
file:close()
-----
local subject = string.format("Пользователь %s %s %s(%s) заполнил анкету.", patientInfo.firstName, patientInfo.middleName, patientInfo.lastName, patientInfo.id)
local message = string.format("%s \n Продукт:%s, \n Заказ:%s. \n %s \n\n\n АНКЕТА:\n %s", subject, productId, clientProductId, cjson.encode(patientInfo), buff)
local to = string.format("<%s>",os.getenv("SMTP_TO"))
smtp.sendMail(ngx, to, subject, message)
-----
return ngx.redirect("https://test-telemed.drclinics.ru/msa/api/questions/success.html",301)

