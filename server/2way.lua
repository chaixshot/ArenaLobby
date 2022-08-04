-- this file define some useful tools
local Tools = {}

-- ID generator

local IDGenerator = {}

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

-- return a new id
function IDGenerator:gen()
    if #self.ids > 0 then
        return table.remove(self.ids)
    else
        local r = self.max
        self.max = self.max+1
        return r
    end
end

-- free a previously generated id
function IDGenerator:free(id)
    table.insert(self.ids,id)
end

local Debug = {}

Debug.active = false
Debug.maxlen = 75
Debug.stack = {}

function Debug.pbegin(name)
  if Debug.active then
    if string.len(name) > Debug.maxlen then
      name = string.sub(name,1,Debug.maxlen).."..."
    end

    table.insert(Debug.stack, {name,os.clock()})
    print("[profile] => "..name)
  end
end

function Debug.pend()
  if Debug.active then
    local front = table.remove(Debug.stack)
    print("[profile] <= "..front[1].." "..(os.clock()-front[2]).."s")
  end
end

-- copy table without userdata
function Debug.safeTableCopy(t)
  local r = t

  if type(t) == "table" then
    r = {}
    for k,v in pairs(t) do
      if type(v) ~= "userdata" then
        r[k] = Debug.safeTableCopy(v)
      end
    end
  end

  return r
end

Tunnel = {}
Tunnel.delays = {}

function Tunnel.setDestDelay(dest, delay)
    Tunnel.delays[dest] = {delay, 0}
end

local function Tunnel_Resolve(itable,key)
    local mtable = getmetatable(itable)
    local iname = mtable.name
    local ids = mtable.tunnel_ids
    local callbacks = mtable.tunnel_callbacks
    local identifier = mtable.identifier

    local fcall = function(dest, args, callback)
        if args == nil then
            args = {}
        end

        local delay_data = Tunnel.delays[dest]
        if delay_data == nil then
            delay_data = {0,0}
        end

        local add_delay = delay_data[1]
        delay_data[2] = delay_data[2]+add_delay

        if delay_data[2] > 0 then
            SetTimeout(delay_data[2], function()
                delay_data[2] = delay_data[2]-add_delay
                if type(callback) == "function" then
                    local rid = ids:gen()
                    callbacks[rid] = callback
                    TriggerClientEvent(iname..":tunnel_request", dest, args, key, identifier, rid)
                else
                    TriggerClientEvent(iname..":tunnel_request", dest, args, key, "", -1)
                end
            end)
        else
            if type(callback) == "function" then
				local rid = ids:gen()
				callbacks[rid] = callback
				TriggerClientEvent(iname..":tunnel_request", dest, args, key, identifier, rid)
			else
				TriggerClientEvent(iname..":tunnel_request", dest, args, key, "", -1)
			end
        end
    end

    itable[key] = fcall
    return fcall
end

-- local BanTest = {}
function Tunnel.BindeInherFaced(name,interface)
    RegisterServerEvent(name..":tunnel_request")
    AddEventHandler(name..":tunnel_request",function(member, args, resourcename, identifier, rid)
		local source = source
        
        local delayed = false

        if Debug.active then
            Debug.pbegin("tunnelreq#"..rid.."_"..name..":"..member.." "..json.encode(Debug.safeTableCopy(args)))
        end

        local f = interface[member]

        local rets = {}
        if type(f) == "function" then
            TUNNEL_DELAYED = function()
                delayed = true
                return function(rets)
                    rets = rets or {}
                    if rid >= 0 then
                        TriggerClientEvent(name..":"..identifier..":tunnel_request", source, rets, rid)
                    end
                end
            end

            rets = {f(table.unpack(args))} -- call function
        end

        if not delayed and rid >= 0 then
            TriggerClientEvent(name..":"..identifier..":tunnel_request", source, rets, rid)
        end

        if Debug.active then
            Debug.pend()
        end
    end)
end

function Tunnel.GedInthrFaced(name, identifier)
    local ids = Tools.newIDGenerator()
    local callbacks = {}

    local r = setmetatable({},{ __index = Tunnel_Resolve, name = name, tunnel_ids = ids, tunnel_callbacks = callbacks, identifier = identifier })

    RegisterServerEvent(name..":"..identifier..":tunnel_request")
    AddEventHandler(name..":"..identifier..":tunnel_request",function(rid, args, resourcename)
		
        if Debug.active then
            Debug.pbegin("tunnelres#"..rid.."_"..name.." "..json.encode(Debug.safeTableCopy(args)))
        end

        local callback = callbacks[rid]
        if callback ~= nil then
            ids:free(rid)
            callbacks[rid] = nil

            callback(table.unpack(args))
        end

        Debug.pend()
    end)

    return r
end

local Debug = {}

Debug.active = false
Debug.maxlen = 75
Debug.stack = {}

function Debug.pbegin(name)
  if Debug.active then
    if string.len(name) > Debug.maxlen then
      name = string.sub(name,1,Debug.maxlen).."..."
    end

    table.insert(Debug.stack, {name,os.clock()})
    print("[profile] => "..name)
  end
end

function Debug.pend()
  if Debug.active then
    local front = table.remove(Debug.stack)
    print("[profile] <= "..front[1].." "..(os.clock()-front[2]).."s")
  end
end

-- copy table without userdata
function Debug.safeTableCopy(t)
  local r = t

  if type(t) == "table" then
    r = {}
    for k,v in pairs(t) do
      if type(v) ~= "userdata" then
        r[k] = Debug.safeTableCopy(v)
      end
    end
  end

  return r
end

Proxy = {}
local proxy_rdata = {}

local function Proxy_Callback(rvalues)
    proxy_rdata = rvalues
end

local function Proxy_Resolve(itable,key)
    local iname = getmetatable(itable).name
    local fcall = function(args,callback)
        if args == nil then
            args = {}
        end

        TriggerEvent(iname..":proxy_request", key, json.encode(args), Proxy_Callback)
        return table.unpack(proxy_rdata)
    end

    itable[key] = fcall
    return fcall
end

function Proxy.AddInthrFaced(name, itable)
    AddEventHandler(name..":proxy_request",function(member, args, callback)
        if Debug.active then
            Debug.pbegin("proxy_"..name..":"..member.." "..json.encode(Debug.safeTableCopy(args)))
        end

        local f = itable[member]
		local args = json.decode(args)

        if type(f) == "function" then
            callback({f(table.unpack(args))})
        end

        if Debug.active then
            Debug.pend()
        end
    end)
end

function Proxy.GedInthrFaced(name)
    local r = setmetatable({},{ __index = Proxy_Resolve, name = name })
    return r
end
