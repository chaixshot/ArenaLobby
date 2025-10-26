local isMenuOpen = false
local isInZone = false
local isInPoint = false
local Controls = {}
ArenaAPI = exports.ArenaAPI

local timeUI = {}
local function checkPressDelay(type, time)
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

local function checkAllowSetPassword()
	return true
end

local function refreshGamesList(resourceName)
	local GameList = {
		["DarkRP_Aimlab"] = true,
		["DarkRP_Bloodbowl"] = true,
		["DarkRP_Bomb"] = true,
		["DarkRP_Deathmacth"] = true,
		["DarkRP_Derby"] = true,
		["DarkRP_CaptureTheFlag"] = true,
		["DarkRP_Racing"] = true,
		["DarkRP_Squidglass"] = true,
		["DarkRP_Squidlight"] = true,
		["DarkRP_Teamdeathmacth"] = true,
		["DarkRP_ZombieSurvival"] = true,
	}

	if GameList[resourceName] or not resourceName then
		for name, bool in pairs(GameList) do
			SendNUIMessage({
				message = "hideGame",
				name = name,
				isHide = GetResourceState(name) ~= "started",
			})
		end
	end
end

local function refreshLobbyList()
	SendNUIMessage({message = "lobbyClear"})

	for k, v in pairs(ArenaAPI:GetArenaList()) do
		if v.MaximumCapacity > 0 and v.CurrentCapacity > 0 then
			SendNUIMessage({
				message = "lobbyAdd",
				item = v.ArenaIdentifier,
				ownerName = v.ownerName,
				image = string.gsub(k, "%d+", ""),
				imageUrl = v.ArenaImageUrl,
				label = v.ArenaLabel,
				state = (v.CanJoinAfterStart and "" or v.ArenaState),
				players = v.CurrentCapacity.."/"..v.MaximumCapacity,
				password = checkAllowSetPassword() and tostring(v.Password) or "",
				PlayerAvatar = v.PlayerAvatar,
			})
		end
	end
end

function OpenGameMenu(isXbox)
	if isMenuOpen
		 or not isInPoint
		 or not checkPressDelay("ArenaLobby_Menu_Open", 100)
		 or IsPlayerDead(PlayerId())
		 or IsPauseMenuActive()
		 or IsPlayerSwitchInProgress()
		 or ArenaAPI:IsPlayerInAnyArena()
	then
		return
	end

	isMenuOpen = true
	checkPressDelay("ArenaLobby_Menu_Xbox_Right", 100) -- Anti double pressing D-Pad right

	-- Cancel crouch animation
	DisableControlAction(0, 36, true)

	-- Show installed game list
	refreshGamesList()

	-- Add arena lobby list
	refreshLobbyList()

	SendNUIMessage({
		message = "menuShow",
		allowSetPassword = checkAllowSetPassword(),
		isXbox = isXbox,
	})

	if isXbox then
		-- Hide mouse cursor
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
	if isMenuOpen then
		Citizen.Wait(300)

		refreshLobbyList()

		SendNUIMessage({
			message = "refresh_controller_index",
		})
	end
end)

-- Lobby created notification
RegisterNetEvent("ArenaAPI:sendStatus")
AddEventHandler("ArenaAPI:sendStatus", function(eType, data)
	if eType == "create" then
		if isInZone and not ArenaAPI:IsPlayerInAnyArena() then
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

AddEventHandler("onClientResourceStart", function(resourceName)
	refreshGamesList(resourceName)
end)

AddEventHandler("onClientResourceStop", function(resourceName)
	refreshGamesList(resourceName)
end)

-- Create Blips
Citizen.CreateThread(function()
	local object
	local checkpoint

	local blip = AddBlipForCoord(Config.Location.x, Config.Location.y, Config.Location.z)
	SetBlipSprite(blip, Config.Blip)
	SetBlipDisplay(blip, 4)
	SetBlipScale(blip, 0.7)
	SetBlipColour(blip, Config.BlipColor)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName("Game Room")
	EndTextCommandSetBlipName(blip)

	-- Decor for supported scripts, let them know what is your current game
	DecorRegister("GameRoom", 2)
	DecorRegister("GameRoomTeam", 2)

	while true do
		local sleep = 500
		local playerPed = PlayerPedId()
		local playerCoords = GetEntityCoords(playerPed, false)
		local dist = #(vector3(Config.Location.x, Config.Location.y, Config.Location.z) - vector3(playerCoords.x, playerCoords.y, playerCoords.z))

		-- Handle zone green cylinder
		if dist < Config.DrawDistance * 30.0 then
			if not checkpoint then
				checkpoint = CreateCheckpoint(47, Config.Location.x, Config.Location.y, Config.Location.z, 0.0, 0.0, 0.0, Config.DrawDistance * 2.0, Config.Color.red, Config.Color.green, Config.Color.blue, Config.Color.alpha, 0)
				SetCheckpointCylinderHeight(checkpoint, Config.Height, Config.Height, Config.Height)
			end
		elseif checkpoint then
			DeleteCheckpoint(checkpoint)
			checkpoint = nil
		end

		if dist < Config.DrawDistance * 5.0 then
			sleep = 0

			if not isInZone then
				isInZone = true
				object = SpawnLocalObject(Config.Prop, Config.Location)
				FreezeEntityPosition(object, true)
				SetEntityHeading(object, 250.0)
			end

			if dist < Config.DrawDistance and not ArenaAPI:IsPlayerInAnyArena() then
				if not isInPoint then
					isInPoint = true

					SendNUIMessage({message = "music_play"})
				end

				ShowFloatingHelpNotification('Press  ~INPUT_CONTEXT~to play.', playerCoords + vector3(0.0, 0.0, 1.0))
			else
				if isInPoint then
					isInPoint = false
					isMenuOpen = false

					SendNUIMessage({message = "music_stop"})
					SendNUIMessage({message = "menuHide"})
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
		elseif isInZone then
			SetObjectAsNoLongerNeeded(object)
			SetEntityAsNoLongerNeeded(object)
			SetEntityAsMissionEntity(object, true, true)
			DeleteEntity(object)
			DeleteObject(object)

			object = nil
			isInZone = false
		end

		Citizen.Wait(sleep)
	end
end)

RegisterNUICallback('menuClose', function(data, cb)
	SendNUIMessage({message = "menuHide"})
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
RegisterCommand('-ArenaLobby_Menu_Keyboard', function() end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Keyboard', 'ArenaLobby Open', 'KEYBOARD', 'E')

RegisterCommand('+ArenaLobby_Menu_Xbox_Open', function()
	OpenGameMenu(true)
end, false)
RegisterCommand('-ArenaLobby_Menu_Xbox_Open', function() end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Xbox_Open', 'ArenaLobby Xbox Open', 'PAD_ANALOGBUTTON', 'LRIGHT_INDEX')

RegisterCommand('+ArenaLobby_Menu_Xbox_A', function()
	if isMenuOpen and checkPressDelay("ArenaLobby_Menu_Xbox_A", 100) then
		SendNUIMessage({message = "control_a"})
	end
end, false)
RegisterCommand('-ArenaLobby_Menu_Xbox_A', function() end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Xbox_A', 'ArenaLobby Xbox A', 'PAD_ANALOGBUTTON', 'RDOWN_INDEX')

RegisterCommand('+ArenaLobby_Menu_Xbox_B', function()
	if isMenuOpen and checkPressDelay("ArenaLobby_Menu_Xbox_B", 100) then
		SendNUIMessage({message = "control_b"})
	end
end, false)
RegisterCommand('-ArenaLobby_Menu_Xbox_B', function() end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Xbox_B', 'ArenaLobby Xbox B', 'PAD_ANALOGBUTTON', 'RRIGHT_INDEX')

RegisterCommand('+ArenaLobby_Menu_Xbox_Right', function()
	if isMenuOpen and checkPressDelay("ArenaLobby_Menu_Xbox_Right", 100) then
		Controls.Right = true

		SendNUIMessage({message = "control_right"})
		local timer = GetGameTimer()
		while Controls.Right do
			if GetTimeDifference(GetGameTimer(), timer) > 300 then
				SendNUIMessage({message = "control_right"})
			end
			Citizen.Wait(50)
		end
	end
end, false)
RegisterCommand('-ArenaLobby_Menu_Xbox_Right', function()
	Controls.Right = false
end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Xbox_Right', 'ArenaLobby Xbox Right', 'PAD_ANALOGBUTTON', 'LRIGHT_INDEX')

RegisterCommand('+ArenaLobby_Menu_Xbox_Left', function()
	if isMenuOpen and checkPressDelay("ArenaLobby_Menu_Xbox_Left", 100) then
		Controls.Left = true

		SendNUIMessage({message = "control_left"})
		local timer = GetGameTimer()
		while Controls.Left do
			if GetTimeDifference(GetGameTimer(), timer) > 300 then
				SendNUIMessage({message = "control_left"})
			end
			Citizen.Wait(50)
		end
	end
end, false)
RegisterCommand('-ArenaLobby_Menu_Xbox_Left', function()
	Controls.Left = false
end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Xbox_Left', 'ArenaLobby Xbox Left', 'PAD_ANALOGBUTTON', 'LLEFT_INDEX')

RegisterCommand('+ArenaLobby_Menu_Xbox_Up', function()
	if isMenuOpen and checkPressDelay("ArenaLobby_Menu_Xbox_Up", 100) then
		Controls.Up = true

		SendNUIMessage({message = "control_left"})
		local timer = GetGameTimer()
		while Controls.Up do
			if GetTimeDifference(GetGameTimer(), timer) > 300 then
				SendNUIMessage({message = "control_left"})
			end
			Citizen.Wait(50)
		end
	end
end, false)
RegisterCommand('-ArenaLobby_Menu_Xbox_Up', function()
	Controls.Up = false
end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Xbox_Up', 'ArenaLobby Xbox Up', 'PAD_ANALOGBUTTON', 'LUP_INDEX')

RegisterCommand('+ArenaLobby_Menu_Xbox_Down', function()
	if isMenuOpen and checkPressDelay("ArenaLobby_Menu_Xbox_Down", 100) then
		Controls.Down = true

		SendNUIMessage({message = "control_right"})
		local timer = GetGameTimer()
		while Controls.Down do
			if GetTimeDifference(GetGameTimer(), timer) > 300 then
				SendNUIMessage({message = "control_right"})
			end
			Citizen.Wait(50)
		end
	end
end, false)
RegisterCommand('-ArenaLobby_Menu_Xbox_Down', function()
	Controls.Down = false
end, false)
RegisterKeyMapping('+ArenaLobby_Menu_Xbox_Down', 'ArenaLobby Xbox Down', 'PAD_ANALOGBUTTON', 'LDOWN_INDEX')
