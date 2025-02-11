local isMenuOpen = false
local Object
ArenaAPI = exports.ArenaAPI

local timeUI = {}
local function CheckUiTime(type, time)
	if not timeUI[type] then
		timeUI[type] = GetGameTimer()
		return true
	end

	if GetGameTimer() - timeUI[type] > time then
		timeUI[type] = GetGameTimer()
		return true
	end

	return false
end

function OpenGameMenu(withXbox)
	if isMenuOpen or not InPoint or IsPlayerDead(PlayerId()) or not CheckUiTime("ArenaLobby_Menu_Open", 100) or DecorGetInt(PlayerPedId(), "GameRoom") ~= 0 or IsPauseMenuActive() or IsPlayerSwitchInProgress() then
		return
	end

	DisableControlAction(0, 36, true)

	local GameList = {
		"DarkRP_Aimlab",
		"DarkRP_Bloodbowl",
		"DarkRP_Bomb",
		"DarkRP_Deathmacth",
		"DarkRP_Derby",
		"DarkRP_CaptureTheFlag",
		"DarkRP_Racing",
		"DarkRP_Squidglass",
		"DarkRP_Squidlight",
		"DarkRP_Teamdeathmacth",
		"DarkRP_ZombieSurvival",
	}
	for k, v in pairs(GameList) do
		SendNUIMessage({
			message = "hideGame",
			name = v,
			isHide = GetResourceState(v) ~= "started",
		})
	end

	SendNUIMessage({message = "clear"})
	for k, v in pairs(ArenaAPI:GetArenaList()) do
		if v.MaximumCapacity > 0 and v.CurrentCapacity > 0 then
			SendNUIMessage({
				message = "add",
				item = v.ArenaIdentifier,
				ownerName = v.ownerName,
				image = string.gsub(k, "%d+", ""),
				imageUrl = v.ArenaImageUrl,
				label = v.ArenaLabel,
				state = (v.CanJoinAfterStart and "" or v.ArenaState),
				players = v.CurrentCapacity.."/"..v.MaximumCapacity,
				password = tostring(v.Password),
				PlayerAvatar = v.PlayerAvatar,
			})
		end
	end

	SendNUIMessage({
		message = "show",
		withXbox = withXbox,
	})

	CheckUiTime("ArenaLobby_Menu_Xbox_Right", 100)
	isMenuOpen = true
	if withXbox then
		SetCursorLocation(0.1, 0.1)
		SetNuiFocus(true, false)

		local form = Scaleform.Request("instructional_buttons")
		form:CallFunction("CLEAR_ALL")
		form:CallFunction("SET_DATA_SLOT", 0, GetControlInstructionalButton(1, 194, true), "Back")
		form:CallFunction("SET_DATA_SLOT", 1, GetControlInstructionalButton(1, 191, true), "Select")
		form:CallFunction("SET_DATA_SLOT", 2, "~INPUTGROUP_FRONTEND_DPAD_ALL~", "Change")
		form:CallFunction("DRAW_INSTRUCTIONAL_BUTTONS")
		form:CallFunction("SET_BACKGROUND_COLOUR", 0, 0, 0, 80)

		while isMenuOpen do
			form:Draw2D()

			Citizen.Wait(0)
		end
		form:Dispose()
	else
		SetCursorLocation(0.5, 0.5)
		SetNuiFocus(true, true)
	end
end

RegisterNetEvent("ArenaAPI:sendStatus")
AddEventHandler("ArenaAPI:sendStatus", function(eType, data)
	Citizen.Wait(500)

	SendNUIMessage({message = "clear"})
	for k, v in pairs(ArenaAPI:GetArenaList()) do
		if v.MaximumCapacity > 0 and v.CurrentCapacity > 0 then
			SendNUIMessage({
				message = "add",
				item = v.ArenaIdentifier,
				ownerName = v.ownerName,
				image = string.gsub(k, "%d+", ""),
				imageUrl = v.ArenaImageUrl,
				label = v.ArenaLabel,
				state = (v.CanJoinAfterStart and "" or v.ArenaState),
				players = v.CurrentCapacity.."/"..v.MaximumCapacity,
				password = tostring(v.Password),
				PlayerAvatar = v.PlayerAvatar,
			})
		end
	end

	SendNUIMessage({
		message = "refresh_controller_index",
	})
end)

RegisterNetEvent("ArenaAPI:sendStatus")
AddEventHandler("ArenaAPI:sendStatus", function(eType, data)
	if eType == "create" then
		if Object and not ArenaAPI:IsPlayerInAnyArena() then
			SendNUIMessage({
				message = "notify",
				ownerName = data.ownerName,
				gameName = data.ArenaIdentifier:gsub("[0-9]", ""),
				gameLabel = data.ArenaLabel,
				ArenaImageUrl = data.ArenaImageUrl,
			})
		end
	end
end)

-- Create Blips
Citizen.CreateThread(function()
	local checkpoint = CreateCheckpoint(47, Config.Location.x, Config.Location.y, Config.Location.z, 0.0, 0.0, 0.0, Config.DrawDistance * 2.0, Config.Color.red, Config.Color.green, Config.Color.blue, Config.Color.alpha, 0)
	SetCheckpointCylinderHeight(checkpoint, Config.Height, Config.Height, Config.Height)

	local blip = AddBlipForCoord(Config.Location.x, Config.Location.y, Config.Location.z)
	SetBlipSprite(blip, Config.Blip)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.7)
	SetBlipColour(blip, Config.BlipColor)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName("Game Room")
	EndTextCommandSetBlipName(blip)

	DecorRegister("GameRoom", 2)
	DecorRegister("GameRoomTeam", 2)

	while true do
		local sleep = 500
		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed, false)
		local dist = GetDistanceBetweenCoords(Config.Location.x, Config.Location.y, Config.Location.z, playerCoords, true)

		if dist < Config.DrawDistance * 5.0 then
			if not Object then
				Object = SpawnLocalObject(Config.Prop, Config.Location)
				FreezeEntityPosition(Object, true)
				SetEntityHeading(Object, 250.0)
			end

			if dist < Config.DrawDistance and not ArenaAPI:IsPlayerInAnyArena() then
				if not InPoint then
					InPoint = true
					SendNUIMessage({message = "music_play"})
				end
				ShowFloatingHelpNotification('Press  ~INPUT_CONTEXT~to play.', playerCoords + vector3(0.0, 0.0, 1.0))
			else
				if InPoint then
					InPoint = false
					isMenuOpen = false

					SendNUIMessage({message = "music_stop"})
					SendNUIMessage({message = "hide"})
					SetNuiFocus(false, false)
				end

				ShowFloatingHelpNotification('~g~Game Room', vector3(Config.Location.x, Config.Location.y, Config.Location.z + 2.3))
			end

			DisablePlayerFiring(playerPed, true)
			DisableControlAction(2, 37, true) -- Disable Weaponwheel
			DisableControlAction(0, 45, true) -- Disable reloading
			DisableControlAction(0, 24, true) -- Disable attacking
			DisableControlAction(0, 263, true) -- Disable melee attack 1
			DisableControlAction(0, 140, true) -- Disable light melee attack (r)
			DisableControlAction(0, 142, true) -- Disable left mouse button (pistol whack etc)

			sleep = 0
		elseif Object then
			SetObjectAsNoLongerNeeded(Object)
			SetEntityAsNoLongerNeeded(Object)
			SetEntityAsMissionEntity(Object, true, true)
			DeleteEntity(Object)
			DeleteObject(Object)

			Object = nil
		end

		Citizen.Wait(sleep)
	end
end)

RegisterNUICallback('quit', function(data, cb)
	SendNUIMessage({message = "hide"})
	isMenuOpen = false
	SetNuiFocus(false, false)
	cb('ok')
end)

RegisterNUICallback('join', function(data, cb)
	if ArenaAPI:IsPlayerInAnyArena() then
		Citizen.Wait(500)
	end
	ExecuteCommand("minigame join "..data.item)
	cb('ok')
end)

RegisterNUICallback('create', function(data, cb)
	if ArenaAPI:IsPlayerInAnyArena() then
		ExecuteCommand("minigame leave")
		Citizen.Wait(500)
	end
	TriggerServerEvent("ArenaLobby:CreateGame", data)
	cb('ok')
end)

RegisterCommand('+ArenaLobby_Menu_Keyboard', function()
	OpenGameMenu(false)
end, false)
RegisterCommand('-ArenaLobby_Menu_Keyboard', function()
end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Keyboard', 'ArenaLobby Open', 'KEYBOARD', 'E')

RegisterCommand('+ArenaLobby_Menu_Xbox_Open', function()
	OpenGameMenu(true)
end, false)
RegisterCommand('-ArenaLobby_Menu_Xbox_Open', function()
end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Xbox_Open', 'ArenaLobby Xbox Open', 'PAD_ANALOGBUTTON', 'LRIGHT_INDEX')

RegisterCommand('+ArenaLobby_Menu_Xbox_A', function()
	if isMenuOpen and CheckUiTime("ArenaLobby_Menu_Xbox_A", 100) then
		SendNUIMessage({message = "control_a"})
	end
end, false)
RegisterCommand('-ArenaLobby_Menu_Xbox_A', function()
end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Xbox_A', 'ArenaLobby Xbox A', 'PAD_ANALOGBUTTON', 'RDOWN_INDEX')

RegisterCommand('+ArenaLobby_Menu_Xbox_B', function()
	if isMenuOpen and CheckUiTime("ArenaLobby_Menu_Xbox_B", 100) then
		SendNUIMessage({message = "control_b"})
	end
end, false)
RegisterCommand('-ArenaLobby_Menu_Xbox_B', function()
end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Xbox_B', 'ArenaLobby Xbox B', 'PAD_ANALOGBUTTON', 'RRIGHT_INDEX')

RegisterCommand('+ArenaLobby_Menu_Xbox_Right', function()
	if isMenuOpen and CheckUiTime("ArenaLobby_Menu_Xbox_Right", 100) then
		SendNUIMessage({message = "control_right"})
	end
end, false)
RegisterCommand('-ArenaLobby_Menu_Xbox_Right', function()
end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Xbox_Right', 'ArenaLobby Xbox Right', 'PAD_ANALOGBUTTON', 'LRIGHT_INDEX')

RegisterCommand('+ArenaLobby_Menu_Xbox_Left', function()
	if isMenuOpen and CheckUiTime("ArenaLobby_Menu_Xbox_Left", 100) then
		SendNUIMessage({message = "control_left"})
	end
end, false)
RegisterCommand('-ArenaLobby_Menu_Xbox_Left', function()
end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Xbox_Left', 'ArenaLobby Xbox Left', 'PAD_ANALOGBUTTON', 'LLEFT_INDEX')

RegisterCommand('+ArenaLobby_Menu_Xbox_Up', function()
	if isMenuOpen and CheckUiTime("ArenaLobby_Menu_Xbox_Up", 100) then
		SendNUIMessage({message = "control_left"})
	end
end, false)
RegisterCommand('-ArenaLobby_Menu_Xbox_Up', function()
end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Xbox_Up', 'ArenaLobby Xbox Up', 'PAD_ANALOGBUTTON', 'LUP_INDEX')

RegisterCommand('+ArenaLobby_Menu_Xbox_Down', function()
	if isMenuOpen and CheckUiTime("ArenaLobby_Menu_Xbox_Down", 100) then
		SendNUIMessage({message = "control_right"})
	end
end, false)
RegisterCommand('-ArenaLobby_Menu_Xbox_Down', function()
end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Xbox_Down', 'ArenaLobby Xbox Down', 'PAD_ANALOGBUTTON', 'LDOWN_INDEX')
