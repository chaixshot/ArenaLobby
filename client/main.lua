local object
ArenaAPI = exports.ArenaAPI

function OpenGameMenu()
	if not IsPlayerDead(PlayerId()) then
		SendNUIMessage({
			message = "show",
			clear = true
		})
		local GameList = {
			"DarkRP_Aimlab",
			"DarkRP_Bloodbowl",
			"DarkRP_Bomb",
			"DarkRP_Boxing",
			"DarkRP_Deathmacth",
			"DarkRP_Derby",
			"DarkRP_CaptureTheFlag",
			"DarkRP_Racing",
			"DarkRP_Squidglass",
			"DarkRP_Squidlight",
			"DarkRP_Teamdeathmacth",
			"DarkRP_ZombieInfection",
		}
		for k, v in pairs(GameList) do
			if GetResourceState(v) ~= "started" then
				SendNUIMessage({
					message = "hidegame",
					name = v,
				})
			end
		end
		
		for k,v in pairs(ArenaAPI:GetAllArena()) do
			if v.MaximumCapacity > 0 and v.CurrentCapacity > 0 then
				SendNUIMessage({
					message = "add",
					item = v.ArenaIdentifier,
					ownername = v.ownername,
					image = string.gsub(k, "%d+", ""),
					imageUrl =v.ArenaImageUrl,
					label = v.ArenaLabel,
					state = (v.CanJoinAfterStart and "" or v.ArenaState),
					players = v.CurrentCapacity.."/"..v.MaximumCapacity,
					password = tostring(v.Password),
					PlayerAvatar = v.PlayerAvatar,
				})
			end
		end
		SetNuiFocus(true, true)
	end
end

RegisterNetEvent("ArenaAPI:sendStatus")
AddEventHandler("ArenaAPI:sendStatus", function(type, data)
	Wait(500)
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
				imageUrl =v.ArenaImageUrl,
				label = v.ArenaLabel,
				state = (v.CanJoinAfterStart and "" or v.ArenaState),
				players = v.CurrentCapacity.."/"..v.MaximumCapacity,
				password = tostring(v.Password),
				PlayerAvatar = v.PlayerAvatar,
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
	local checkpoint = CreateCheckpoint(47, Config.Location.x, Config.Location.y, Config.Location.z, 0.0, 0.0, 0.0, Config.DrawDistance, Config.Color.r, Config.Color.g, Config.Color.b, Config.Color.a, 0)
	SetCheckpointCylinderHeight(checkpoint, Config.Height, Config.Height, Config.Height)
	local blip = AddBlipForCoord(Config.Location.x, Config.Location.y, Config.Location.z)
	SetBlipSprite (blip, Config.Blip)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.7)
	SetBlipColour(blip, Config.BlipColor)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName("Game Room")
	EndTextCommandSetBlipName(blip)

	DecorRegister("GameRoom", 2)
	while true do
		local sleep = 500
		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed)
		local dist =GetDistanceBetweenCoords(Config.Location.x, Config.Location.y, Config.Location.z, playerCoords, true)

		if dist < Config.DrawDistance*1.5 then
			if not object then
				object = SpawnLocalObject(Config.Prop, Config.Location)
				FreezeEntityPosition(object, true)
				SetEntityHeading(object, 250.0)
			end
			
			if dist < Config.DrawDistance then
				if not InPoint then
					InPoint = true
					SendNUIMessage({message = "playsound_MainRoom"})
				end
				ShowFloatingHelpNotification('Press ~g~E ~w~to play.', playerCoords+vector3(0.0, 0.0, 1.0))
			else
				ShowFloatingHelpNotification('~g~Game Room', vector3(Config.Location.x, Config.Location.y, Config.Location.z+1))
			end
			
			DisablePlayerFiring(playerPed, true)
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
			
			if object then
				SetEntityAsNoLongerNeeded(object)
				SetObjectAsNoLongerNeeded(object)
				DetachEntity(object, true, false)
				DeleteEntity(object)
				DeleteObject(object)
				object = nil
			end
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