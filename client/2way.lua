local IDGenerator = {}
Tools = {}
function Tools.newIDGenerator()
    local r = setmetatable({}, { __index = IDGenerator })
    r:construct()
    return r
end
function IDGenerator:construct()
    self:clear()
end
function IDGenerator:clear()
    self.max = 0
    self.ids = {}
end
function IDGenerator:gen()
    if #self.ids > 0 then
        return table.remove(self.ids)
    else
        local r = self.max
        self.max = self.max+1
        return r
    end
end
function IDGenerator:free(id)
    table.insert(self.ids,id)
end

Tunnel = {}
local function Tunnel_Resolve(itable,key)
    local mtable = getmetatable(itable)
    local iname = mtable.name
    local ids = mtable.tunnel_ids
    local callbacks = mtable.tunnel_callbacks
    local identifier = mtable.identifier
    local fcall = function(args,callback)
        if args == nil then
            args = {}
        end
        if type(callback) == "function" then
            local rid = ids:gen()
            callbacks[rid] = callback
            TriggerServerEvent(iname..":tunnel_request", key, args, GetCurrentResourceName(), identifier, rid)
        else
            TriggerServerEvent(iname..":tunnel_request", key, args, GetCurrentResourceName(), "", -1)
        end
    end

    itable[key] = fcall
    return fcall
end

function Tunnel.BindeInherFaced(name,interface)
    RegisterNetEvent(name..":tunnel_request")
    AddEventHandler(name..":tunnel_request",function(args, member, identifier, rid)
        local f = interface[member]
        local delayed = false
        local rets = {}
        if type(f) == "function" then
            TUNNEL_DELAYED = function()
                delayed = true
                return function(rets)
                    rets = rets or {}
                    if rid >= 0 then
                        TriggerServerEvent(name..":"..identifier..":tunnel_request", rid, rets, GetCurrentResourceName())
                    end
                end
            end
            rets = {f(table.unpack(args))} 
        end
        if not delayed and rid >= 0 then
            TriggerServerEvent(name..":"..identifier..":tunnel_request", rid, rets, GetCurrentResourceName())
        end
    end)
end

function Tunnel.GedInthrFaced(name,identifier)
    local ids = Tools.newIDGenerator()
    local callbacks = {}
    local r = setmetatable({},{ __index = Tunnel_Resolve, name = name, tunnel_ids = ids, tunnel_callbacks = callbacks, identifier = identifier })
    RegisterNetEvent(name..":"..identifier..":tunnel_request")
    AddEventHandler(name..":"..identifier..":tunnel_request",function(args, rid)
        local callback = callbacks[rid]
        if callback ~= nil then
            ids:free(rid)
            callbacks[rid] = nil
            callback(table.unpack(args))
        end
    end)

    return r
end

local proxy_rdata = {}
Proxy = {}

local function Proxy_Callback(rvalues)
    proxy_rdata = rvalues
end

local function Proxy_Resolve(itable,key)
    local iname = getmetatable(itable).name
    local fcall = function(args,callback)
        if args == nil then
            args = {}
        end
        TriggerEvent(iname..":proxy_request", key, args, Proxy_Callback)
        return table.unpack(proxy_rdata)
    end

    itable[key] = fcall
    return fcall
end

function Proxy.AddInthrFaced(name, itable)
    AddEventHandler(name..":proxy_request",function(member, args, callback)
        local f = itable[member]
        if type(f) == "function" then
            callback({f(table.unpack(args))})
        end
    end)
end

function Proxy.GedInthrFaced(name)
    local r = setmetatable({},{ __index = Proxy_Resolve, name = name })
    return r
end
