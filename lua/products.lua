local cjson = require "cjson"
local auth = require "lua.modules.telemed_auth"
local utils = require "lua.modules.utils"



local contentType = ngx.req.get_headers()["content-type"];
if(contentType=='application/json') then
    local files = utils.scandir('/usr/share/nginx/html/msa/api/products');
    local contents = {}
    local i = 0

    for key, val in pairs(files) do
        i = i + 1
        contents[i]={[val]=utils.scandir('/usr/share/nginx/html/msa/api/products/'..val)};
    end

    local products =cjson.encode({["products"]=contents});
    ngx.print(products);
    return ngx.exit(200);
else
    ngx.exec("@share_files");
end


