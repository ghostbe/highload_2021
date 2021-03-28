local function load_config(config_file)
    local fh, err = require('fio').open(config_file, {O_RDONLY})
    if fh == nil then
        print(err)
        return nil
    end

    local file_data = fh:read()
    if file_data == nil then
        print(err)
        return nil
    end
    
    fh:close()

    local config = require('yaml').decode(file_data)
    if config == nil then
        print('Something went wrong while decoding!')
        return nil
    end

    return config
end

local function handler(req)
    local client = require('http.client').new({max_connections = 1})
    local url = config.proxy.bypass.host .. ':' .. config.proxy.bypass.port
    local responce = client:request(req:method(), url, nil, { 
        verify_host=false,
        verify_peer=false
    })
    return responce
end

config = load_config('config.yml')
if config == nil then return end

local router = require('http.router').new()
router:route({path = '/'}, handler)
router:route({path = '/.*'}, handler)

local server = require('http.server').new('localhost', config.proxy.port)
server:set_router(router)

server:start()
