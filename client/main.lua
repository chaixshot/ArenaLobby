ArenaAPI = exports.ArenaAPI
local object

function OpenGameMenu()
	if not IsPlayerDead(PlayerId()) then
		SendNUIMessage({
			message = "show",
			clear = true
		})
		for k,v in pairs(ArenaAPI:GetAllArena()) do
			if v.MaximumCapacity > 0 and v.CurrentCapacity > 0 then
				SendNUIMessage({
					message = "add",
					item = v.ArenaIdentifier,
					ownername = v.ownername,
					image = string.gsub(k, "%d+", ""),
					label = v.ArenaLabel,
					state = (v.CanJoinAfterStart and "" or v.ArenaState),
					players = v.CurrentCapacity.."/"..v.MaximumCapacity,
					password = v.Password,
				})
			end
		end
		SetNuiFocus(true, true)
	end
end

RegisterNetEvent("ArenaAPI:sendStatus")
AddEventHandler("ArenaAPI:sendStatus", function(type, data)
	SendNUIMessage({
		message = "clear",
	})
	for k,v in pairs(ArenaAPI:GetAllArena()) do
		if v.MaximumCapacity > 0 and v.CurrentCapacity > 0 then
			SendNUIMessage({
				message = "add",
				item = v.ArenaIdentifier,
				ownername = v.ownername,
				image = string.gsub(k, "%d+", ""),
				label = v.ArenaLabel,
				state = (v.CanJoinAfterStart and "" or v.ArenaState),
				players = v.CurrentCapacity.."/"..v.MaximumCapacity,
				password = v.Password,
			})
		end
	end
end)

RegisterNetEvent("ArenaLobby:PlayerCreateGame")
AddEventHandler("ArenaLobby:PlayerCreateGame", function(ownername, gamename, gameLabel)
	if object and not ArenaAPI:IsPlayerInAnyArena() then
		SendNUIMessage({
			message = "notify",
			ownername = ownername,
			gamename = gamename,
			gameLabel = gameLabel,
		})
	end
end)

-- Create Blips
CreateThread(function()
	local checkpoint = CreateCheckpoint(47, Config.Zones.shop.Pos.x, Config.Zones.shop.Pos.y, Config.Zones.shop.Pos.z, 0.0, 0.0, 0.0, 10.0, 0, 255, 128, 200, 0)
	SetCheckpointCylinderHeight(checkpoint, 0.5, 0.5, 0.5)
	local blip = AddBlipForCoord(Config.Zones.shop.Pos.x, Config.Zones.shop.Pos.y, Config.Zones.shop.Pos.z)
	SetBlipSprite (blip, Config.Zones.shop.blip)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.7)
	SetBlipColour(blip, Config.Zones.shop.color)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName("Game Room")
	EndTextCommandSetBlipName(blip)

	while true do
		local sleep = 500
		local coords = Config.Zones.shop.Pos
		local dist =GetDistanceBetweenCoords(coords.x, coords.y, coords.z, GetEntityCoords(PlayerPedId()), true)
		
		if dist < 100 then
			if not object then
				object = SpawnLocalObject("ch_prop_arcade_claw_01a", Config.Zones.shop.Pos)
				FreezeEntityPosition(object, true)
				SetEntityHeading(object, 250.0)
			end
		elseif object then
			SetEntityAsNoLongerNeeded(object)
			SetObjectAsNoLongerNeeded(object)
			DetachEntity(object, true, false)
			DeleteEntity(object)
			DeleteObject(object)
			object = nil
		end
		
		if dist < 10 then
			if dist < 6 then
				if not InPoint then
					InPoint = true
					SendNUIMessage({message = "playsound_MainRoom"})
				end
				ShowFloatingHelpNotification('Press ~g~E ~w~to play.', vector3(coords.x, coords.y, coords.z + 1))
			else
				ShowFloatingHelpNotification('~g~Game Room', vector3(coords.x, coords.y, coords.z + 1))
			end
			DisablePlayerFiring(PlayerPedId(), true)
			DisableControlAction(2, 37, true) -- Disable Weaponwheel
			DisableControlAction(0, 45, true) -- Disable reloading
			DisableControlAction(0, 24, true) -- Disable attacking
			DisableControlAction(0, 263, true) -- Disable melee attack 1
			DisableControlAction(0, 140, true) -- Disable light melee attack (r)
			DisableControlAction(0, 142, true) -- Disable left mouse button (pistol whack etc)
			sleep = 0
		elseif InPoint then
			InPoint = false
			SendNUIMessage({message = "stopsound_MainRoom"})
			SendNUIMessage({message = "hide"})
			SetNuiFocus(false, false)
		end
		Citizen.Wait(sleep)
	end
end)

RegisterCommand('+ArenaLobby', function()
	if InPoint then
		OpenGameMenu()
	end
end, false)
RegisterCommand('-ArenaLobby', function()
end, false)
RegisterKeyMapping('+ArenaLobby', 'ArenaLobby_Menu', 'keyboard', 'e')

RegisterNUICallback('quit', function(data, cb)
	SendNUIMessage({message = "hide"})
	SetNuiFocus(false, false)
	cb('ok')
end)

RegisterNUICallback('join', function(data, cb)
	if ArenaAPI:IsPlayerInAnyArena() then
		ExecuteCommand("minigame leave")
		Wait(500)
	end
	ExecuteCommand("minigame join " .. data.item)
	cb('ok')
end)

RegisterNUICallback('create', function(data, cb)
	if ArenaAPI:IsPlayerInAnyArena() then
		ExecuteCommand("minigame leave")
		Wait(500)
	end
	TriggerServerEvent("ArenaLobby:CreateGame", data)
	cb('ok')
end)