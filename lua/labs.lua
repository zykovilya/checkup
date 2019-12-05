local cjson = require "cjson"
--local auth = require "lua.modules.telemed_auth"
local utils = require "lua.modules.utils"


--local args = ngx.req.ngx.req.get_uri_args()


local dirName = '/labs/'
local server=os.getenv("TMP_SERVER_URL");

local file, err = io.open(dirName .. "invitro.json")
assert(file and not err);
local inviroOfficesSrc = cjson.decode(file:read("*all"));


local offices={}
for i, v in pairs(inviroOfficesSrc) do
    local coords= utils.split(v.coord, ",");
    offices[i] = {
        ["id"] = v.guid,
        ["city"] = v.city_name,
        ["title"] = v.title,
        ["address"] = v.address,
        ["title"] = v.title,
        ["url"] = string.format("https://www.invitro.ru/offices/%s/clinic.php?ID=%s", v.city_code, v.xml_id),
        ["coordinates"] = { ["lat"] = coords[1], ["long"] = coords[2] },
        ["workingTime"]= {["weekdays"]={["start"]= "08:00",["end"]= "20:00"},["weekend"]= {["start"]= "10:00", ["end"]= "18:00" }
    }}
end

file:close();


local inviroOffices ={["id"]="invitro",
    ["name"]= "Инвитро",
    ["logo"]= server.."/msa/api/labs/images/invitro.png",
    ["color"]= "#0058FF",
    ["offices"]=offices}


ngx.say(cjson.encode(inviroOffices))
return 200



