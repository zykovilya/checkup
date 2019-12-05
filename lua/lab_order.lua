local cjson = require "cjson"
local auth = require "lua.modules.telemed_auth"
local smtp = require "lua.modules.telemed_smtp"
local utils = require "lua.modules.utils"


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
local clientProductId = utils.checkNotNull(params.clientProductId, "need clientProductId")
local laboratoryOfficeId = utils.checkNotNull(params.laboratoryOfficeId, "need laboratoryOfficeId")

local patientInfo = auth.patientInfo(ngx, os.getenv("TMP_SERVER_URL").."/api/auth/person", personId)
-----------
local subject = string.format("Пользователь %s %s %s(%s) записался в лабораторию %s.", patientInfo.firstName, patientInfo.middleName, patientInfo.lastName, patientInfo.id, laboratoryOfficeId)
local message = string.format("%s \n Продукт:%s, \n Заказ:%s. \n %s", subject, productId, clientProductId, cjson.encode(patientInfo))
local to = string.format("<%s>",os.getenv("SMTP_TO"))
smtp.sendMail(ngx, to, subject, message)
-------



local dirName="/files/lab_orders/";
utils.checkAndCreateDirs(dirName);

local file = io.open(string.format(dirName.."%s", os.clock()), 'w')
file:write(ngx.req.get_body_data())
file:close()

return 201



