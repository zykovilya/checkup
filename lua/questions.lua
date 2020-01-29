local auth = require "lua.modules.telemed_auth"
local utils = require "lua.modules.utils"
local attacher = require "lua.modules.file_attacher"
local smtp = require "lua.modules.telemed_smtp"
local cjson = require "cjson"
local products = require "lua.modules.product_info"

local tmpServer = os.getenv("TMP_SERVER_URL");


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

local body = {}
for k,v in pairs(params) do
    if(k~='personId' and k~='productId' and k~='productOrderId' and k~='laboratoryOfficeId') then
        local strVal
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
        body[k] = strVal
    end
end

local fio = string.format("%s %s %s", patientInfo.firstName, patientInfo.middleName, patientInfo.lastName);
local productInfo = products.getProductInfo(tmpServer, productId)
local productFullName = ""
if productInfo ~= nil then
    productFullName = productInfo["fullName"]
else
    productFullName = productId
end

----------------

if productFullName ~= nil then  productFullName = string.gsub(productFullName, " ", "_") end
local dirName = utils.checkAndCreateDirs('/files/questions/');
local filePath = string.format(dirName.."анкета_%s_%s.xlsx",productFullName, productOrderId);

-------
local Workbook = require "xlsxwriter.workbook"

local workbook  = Workbook:new(filePath)
local worksheet = workbook:add_worksheet()

-- Widen the first column to make the text clearer.
worksheet:set_column("A:A", 80)
worksheet:set_column("B:B", 100)

-- Add a bold format to use to highlight cells.
local bold = workbook:add_format({bold = true})

worksheet:write("A1", "Вопросы анкеты", bold)
worksheet:write("B1", "Ответы", bold)
worksheet:write("A2", "ФИО")
worksheet:write("B2", string.format("%s %s %s", patientInfo.firstName, patientInfo.middleName, patientInfo.lastName))
worksheet:write("A3", "Продукт")
worksheet:write("B3", productFullName)

local i=3
for k,v in pairs(body) do
    worksheet:write(i, 0, k)
    worksheet:write(i, 1, v)
    i=i+1
end

workbook:close()

----------------
local attachId= attacher.attachFileToPatient(tmpServer, ngx.req.get_headers()["cookie"],filePath, "LAB_RESULT")
if(attachId~=nil and attachId~="") then
    utils.log("WITH ORDER "..productOrderId .. " [ATTACH_ID]= ".. cjson.encode(attachId))
else
    utils.logError("WITH ORDER "..productOrderId .. " not attach file")
    local subject = string.format("Пользователь %s %s %s(%s) заполнил анкету.", patientInfo.firstName, patientInfo.middleName, patientInfo.lastName, patientInfo.id)
    local message = string.format("%s \n Продукт:%s, \n Заказ:%s. \n %s \n\n\n АНКЕТА:\n %s", subject, productId, productOrderId, cjson.encode(patientInfo), xlsx)
    local to = string.format("<%s>",os.getenv("SMTP_TO"))
    smtp.sendMail(ngx, to, subject, message)
end
----------------
return ngx.redirect(os.getenv("TMP_SERVER_EXTERNAL_URL").."/msa/api/questions/success.html",301)

