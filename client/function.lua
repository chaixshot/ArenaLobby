function RequestStreamedTextureDictC(textureDict)
	if not HasStreamedTextureDictLoaded(textureDict) then
		local timer = 1000
		RequestStreamedTextureDict(textureDict, true)
		while not HasStreamedTextureDictLoaded(textureDict) and timer > 0 do
			timer = timer-1
			Citizen.Wait(100)
		end
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

function GetSkillStaminaDescription(value)
	if value > 81 then
		return "Tri-Athlete"
	elseif value > 61 then
		return "Athlete"
	elseif value > 41 then
		return "Healthy"
	elseif value > 21 then
		return "Out of Shape"
	else
		return "Lethargic"
	end
end

function GetSkillShootingDescription(value)
	if value > 81 then
		return "Dead-Eye"
	elseif value > 61 then
		return "Military Training"
	elseif value > 41 then
		return "Police Training"
	elseif value > 21 then
		return "Spray-and-Pray"
	else
		return "Untrained"
	end
end

function GetSkillStrengthDescription(value)
	if value > 81 then
		return "Bodybuilder"
	elseif value > 61 then
		return "Tough"
	elseif value > 41 then
		return "Average"
	elseif value > 21 then
		return "Weak"
	else
		return "Fragile"
	end
end

function GetSkillStealthDescription(value)
	if value > 81 then
		return "Ninja"
	elseif value > 61 then
		return "Hunter"
	elseif value > 41 then
		return "Sneaky"
	elseif value > 21 then
		return "Loud"
	else
		return "Clumsy"
	end
end

function GetSkillFlyingDescription(value)
	if value > 81 then
		return "Ace"
	elseif value > 61 then
		return "Fighter Pilot"
	elseif value > 41 then
		return "Commercial Pilot"
	elseif value > 21 then
		return "RC Pilot"
	else
		return "Dangerous"
	end
end

function GetSkillDrivingDescription(value)
	if value > 81 then
		return "Pro-Racer"
	elseif value > 61 then
		return "Street Racer"
	elseif value > 41 then
		return "Commuter"
	elseif value > 21 then
		return "Sunday Driver"
	else
		return "Unlicensed"
	end
end

function GetSkillMentalStateDescription(value)
	if value > 81 then
		return "Psychopath"
	elseif value > 61 then
		return "Maniac"
	elseif value > 41 then
		return "Deranged"
	elseif value > 21 then
		return "Unstable"
	else
		return "Normal"
	end
end

function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
        end
        setmetatable(copy, table.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end