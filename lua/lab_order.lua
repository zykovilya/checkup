local cjson = require "cjson"
local auth = require "lua.modules.telemed_auth"
local products = require "lua.modules.product_info"
local labOffices = require "lua.modules.get_office"
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

local tmpServer = os.getenv("TMP_SERVER_URL");
local msaServer = os.getenv("MSA_SERVER_URL");

local personId = utils.checkNotNull(params.personId, "need personId")
local productId = utils.checkNotNull(params.productId, "need productId")
local clientProductId = utils.checkNotNull(params.clientProductId, "need clientProductId")
local laboratoryOfficeId = utils.checkNotNull(params.laboratoryOfficeId, "need laboratoryOfficeId")
local oldLaboratoryOfficeId = params.oldLaboratoryOfficeId
local patientInfo = auth.patientInfo(ngx, tmpServer.."/api/auth/person", personId)

-----------
local fio = string.format("%s %s %s", patientInfo.firstName, patientInfo.middleName, patientInfo.lastName);

local office = labOffices.getLabOffice(msaServer, laboratoryOfficeId)
local oldOffice
if(oldLaboratoryOfficeId~=nil) then
    oldOffice = labOffices.getLabOffice(msaServer, oldLaboratoryOfficeId)
end

local productInfo = products.getProductInfo(tmpServer, productId)
local productFullName
if productInfo ~= nil then
    productFullName = productInfo["fullName"]
end


if office == nil then office = {} end
if oldOffice == nil then oldOffice = {} end

local bodyPattern = [=[
Пользователь %s(id=%s, email=%s, phone=%s, username=%s)  записался в лабораторию "%s"
офис(id=%s):
  адрес: %s
  ссылка: %s
в рамках заказа(productOrderId=%s) продукта "%s" (productId=%s).
]=]

local subject ="ЗАПИСЬ В ЛАБОРАТОРИЮ" .. fio
local message = string.format(bodyPattern, fio, patientInfo.id, patientInfo.email, patientInfo.formattedPhone , patientInfo.username,
                                           office.laboratory, office.id, office.address, office.url,
                                           clientProductId, productFullName, productId)

if(oldLaboratoryOfficeId~=nil) then
    message = message .. string.format([=[

Внимание! Ранее он был записан в лабораторию "%s"
          офис(id=%s):
             адрес: %s
             ссылка: %s
    ]=],oldOffice.laboratory, oldOffice.id, oldOffice.address, oldOffice.url)
end

local to = string.format("<%s>",os.getenv("SMTP_TO"))
smtp.sendMail(ngx, to, subject, message)
-------



local dirName="/files/lab_orders/";
utils.checkAndCreateDirs(dirName);

local file = io.open(string.format(dirName.."%s", os.clock()), 'w')
file:write(ngx.req.get_body_data())
file:close()

return 201



