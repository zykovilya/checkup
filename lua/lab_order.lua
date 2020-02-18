local cjson = require "cjson"
local auth = require "lua.modules.telemed_auth"
local products = require "lua.modules.product_info"
local labOffices = require "lua.modules.get_office"
local patients = require "lua.modules.patient_info"
local utils = require "lua.modules.utils"
local productJsons = require "lua.modules.product_jsons"


ngx.req.read_body()

-------
local params, err = ngx.req.get_post_args()

if err then
    ngx.status = 400
    ngx.print(utils.getErrorResponse("BAD_REQUEST","need body"))
    return ngx.exit(400)
end

local tmpServer = os.getenv("TMP_SERVER_URL");
local tmpExternalServer = os.getenv("TMP_SERVER_EXTERNAL_URL");
local msaServer = os.getenv("MSA_SERVER_URL");

local personId = utils.checkNotNull(params.personId, "need personId")
local productId = utils.checkNotNull(params.productId, "need productId")
local productOrderId = utils.checkNotNull(params.productOrderId, "need productOrderId")
local laboratoryOfficeId = utils.checkNotNull(params.laboratoryOfficeId, "need laboratoryOfficeId")
local oldLaboratoryOfficeId = params.oldLaboratoryOfficeId
local personInfo = auth.personInfo(ngx, tmpServer.."/api/auth/person", personId)
local complexName = params.complexName

-----------
local fio = string.format("%s %s %s", personInfo.firstName, personInfo.middleName, personInfo.lastName);

local office = labOffices.getLabOffice(msaServer, laboratoryOfficeId)
local oldOffice
if(oldLaboratoryOfficeId~=nil) then
    oldOffice = labOffices.getLabOffice(msaServer, oldLaboratoryOfficeId)
end

local productInfo = products.getProductInfo(tmpServer, productId)
local productFullName

----------------------------------------
----- получение диагностической панели--
----------------------------------------
if complexName == nil then
    local analysesUrl
    if productInfo ~= nil then
        productFullName = productInfo["fullName"]
        for key, val in pairs(productInfo.conditions) do
            if val.additionalAttributes ~= nil  then
                 for k, v in pairs(val.additionalAttributes) do
                       if v.name == 'ANALYSES_URL' and analysesUrl == nil then
                                      analysesUrl = v.value
                       end
                 end
            end
        end
    end
    if analysesUrl ~= nil then
        -- todo разобраться с путями
        analysesUrl = string.gsub(analysesUrl, tmpExternalServer, msaServer)
        local json = productJsons.getJson(analysesUrl)
        if json ~= nul then
            complexName = json.complexName
        end
    end
end
----------------------------------------


if office == nil then office = {} end
if oldOffice == nil then oldOffice = {} end


local patientInfo = patients.getPatientInfo(tmpServer);
local patientId = nil ;
if patientInfo ~= nil then
    patientId = patientInfo["id"];
end

local bodyPattern = [=[
Пользователь %s(patientId=%s, email=%s, phone=%s, username=%s)  записался в лабораторию "%s"
офис(id=%s):
  адрес: %s
  ссылка: %s
в рамках заказа(productOrderId=%s) продукта "%s" (productId=%s).
Диагностическая панель: "%s".
]=]

local subject ="ЗАПИСЬ В ЛАБОРАТОРИЮ: " .. fio
local message = string.format(bodyPattern, fio, patientId, personInfo.email, personInfo.formattedPhone , personInfo.username,
                                           office.laboratory, laboratoryOfficeId, office.address, office.url,
                                           productOrderId, productFullName, productId, complexName)

if(oldLaboratoryOfficeId~=nil) then
    message = message .. string.format([=[

Внимание! Ранее он был записан в лабораторию "%s"
          офис(id=%s):
             адрес: %s
             ссылка: %s
    ]=],oldOffice.laboratory, oldLaboratoryOfficeId, oldOffice.address, oldOffice.url)
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



