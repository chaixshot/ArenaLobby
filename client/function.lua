function RequestStreamedTextureDictC(textureDict, cb)
	if not HasStreamedTextureDictLoaded(textureDict) then
		local timer = 1000
		RequestStreamedTextureDict(textureDict, true)
		while not HasStreamedTextureDictLoaded(textureDict) and timer > 0 do
			timer = timer-1
			Citizen.Wait(100)
		end
	end
	SetTimeout(1000, function()
		SetStreamedTextureDictAsNoLongerNeeded(textureDict)
	end)

	if cb ~= nil then
		cb()
	end
end

function RequestModelC(model, cb)
	local RealName = model
	local model = (type(model) == 'number' and model or GetHashKey(model))

	if not HasModelLoaded(model) then
		if IsModelInCdimage(model) and IsModelValid(model) then
			local timer = 1000
			RequestModel(model)
			while not HasModelLoaded(model) and timer > 0 do
				timer = timer-1
				Citizen.Wait(100)
			end
		end
	end
	SetTimeout(1000, function()
		SetModelAsNoLongerNeeded(model)
	end)

	if cb ~= nil then
		cb()
	end
end

SpawnLocalObject = function(model, coords, cb)
	local model = (type(model) == 'number' and model or GetHashKey(model))
	RequestModelC(model)

	local object = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
	DisableCamCollisionForEntity(object)
	DisableCamCollisionForObject(object)
	if cb ~= nil then
		cb(object)
	else
		return object
	end
end

ShowFloatingHelpNotification = function(msg, coords)
	AddTextEntry('FloatingHelpNotification', msg)
    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp('FloatingHelpNotification')
    EndTextCommandDisplayHelp(2, false, false, -1)
end

function DecimalsToMinutes(dec)
	if dec then
		local ms = tonumber(dec)
		return math.floor(ms / 60) .. ":" .. (ms % 60)
	else
		return 0
	end
end

function string.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end