local auth = require "lua.modules.telemed_auth"
local utils = require "lua.modules.utils"
local smtp = require "lua.modules.telemed_smtp"
local cjson = require "cjson"


ngx.req.read_body()

-------
local params, err = ngx.req.get_post_args()

if err then
    ngx.status = 400
    ngx.print(utils.getErrorResponse("BAD_REQUEST","need body"))
    return ngx.exit(400)
end

local personId = utils.checkNotNull(params.personId, "need personId")
local productId = utils.checkNotNull(params.productId, "need productId")
local productOrderId = utils.checkNotNull(params.productOrderId, "need productOrderId")
local patientInfo = auth.patientInfo(ngx, os.getenv("TMP_SERVER_URL").."/api/auth/person", personId)

local buff = ""
for k,v in pairs(params) do
    if(k~='personId' and k~='productId' and k~='productOrderId') then
        local strVal = nil
        if type(v) == "table" then
            for k2, v2 in pairs(v) do
                if(strVal==nil) then
                    strVal = v2
                else
                    strVal = strVal ..  ", " .. v2
                end
            end
        else
            strVal = v
        end
        buff = buff .. k .. ": " .. strVal .. "\n"
    end
end

----------------
local dirName = '/files/questions/';
utils.checkAndCreateDirs(dirName);

local file = io.open(string.format(dirName.."%s_%s_%s",productId,personId,productOrderId), 'w')
file:write(buff)
file:close()
-----
local subject = string.format("Пользователь %s %s %s(%s) заполнил анкету.", patientInfo.firstName, patientInfo.middleName, patientInfo.lastName, patientInfo.id)
local message = string.format("%s \n Продукт:%s, \n Заказ:%s. \n %s \n\n\n АНКЕТА:\n %s", subject, productId, productOrderId, cjson.encode(patientInfo), buff)
local to = string.format("<%s>",os.getenv("SMTP_TO"))
smtp.sendMail(ngx, to, subject, message)
-----
return ngx.redirect(os.getenv("TMP_SERVER_URL").."/msa/api/questions/success.html",301)

