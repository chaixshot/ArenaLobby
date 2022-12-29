function UpdateDetails()
	RequestStreamedTextureDictC("ArenaLobby")
	local CurrentSize = ArenaAPI:GetArenaCurrentSize(ArenaAPI:GetPlayerArena())
	local MinimumSize = ArenaAPI:GetArenaMinimumSize(ArenaAPI:GetPlayerArena())
	local MaximumSize = ArenaAPI:GetArenaMaximumSize(ArenaAPI:GetPlayerArena())
	local MaximumArenaTime = ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).MaximumArenaTime
	local map = ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena()):match("%((.*)%)")
	local txd = string.gsub(ArenaAPI:GetPlayerArena(), "%d+", "")
	
	local ArenaLabel = string.split(ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena()):gsub("<br>", "|"), "|")
	
	TriggerEvent("ArenaLobby:lobbymenu:SetHeaderMenu", {
		Title = "DarkRP - GameRoom",
		Subtitle = (ArenaLabel[1] and ArenaLabel[1]:gsub("<b", "<p"):gsub("</b>", "</p>") or ""),
		SideTop = (ArenaLabel[2] and ArenaLabel[2]:gsub("<b", "<p"):gsub("</b>", "</p>") or ""),
		SideMid = (ArenaLabel[4] and ArenaLabel[4]:gsub("<b", "<p"):gsub("</b>", "</p>") or ""),
		SideBot = (ArenaLabel[3] and ArenaLabel[3]:gsub("<b", "<p"):gsub("</b>", "</p>"):gsub("%]", ""):gsub("%[", "") or ""),
		Col1 = "🕹️  Game",
		Col2 = "Players "..CurrentSize.." of "..MaximumSize,
		Col3 = "Info",
		ColColor1 = 116,
		ColColor2 = 116,
		ColColor3 = 116,
	})

	TriggerEvent("ArenaLobby:lobbymenu:SetInfoTitle", {
		Title = ArenaLabel[1],
	})
	
	
	if string.find(string.lower(ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena())), "racing") and exports["DarkRP_Racing"]:IsInGame() then
		exports["DarkRP_Racing"]:UpdateSettings()
	end
		
	local settingList = {
		{
			label = "⚙️ Setting",
			dec = "Open game setting menu.",
			callbackEvent = "ArenaLobby:PauseMenu.Setting",
		},
		{
			label = "🗺️  Map",
			dec = "Open map menu.",
			callbackEvent = "ArenaLobby:PauseMenu.Map",
		},
		{
			label = "Leave Game",
			dec = "Leave current lobby.",
			callbackEvent = "ArenaLobby:PauseMenu.leave",
			color = 6,
			Blink = true,
		},
	}
	
	TriggerEvent("ArenaLobby:lobbymenu:SettingsColumn", settingList)
end

local function UpdateInfos()
	if string.find(string.lower(ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena())), "racing") and exports["DarkRP_Racing"]:IsInGame() then
		exports["DarkRP_Racing"]:UpdateInfos()
	else
		local MinimumSize = ArenaAPI:GetArenaMinimumSize(ArenaAPI:GetPlayerArena())
		local MaximumArenaTime = ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).MaximumArenaTime
		local map = ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena()):match("%((.*)%)")
		local infoList = {
			{
				LeftLabel = "Map",
				RightLabel = map,
				BadgeStyle = nil,
				Colours = false,
			},
			{
				LeftLabel = "Min Player",
				RightLabel = MinimumSize,
				BadgeStyle = nil,
				Colours = false,
			},
			{
				LeftLabel = "Time Left",
				RightLabel = DecimalsToMinutes(MaximumArenaTime).." Minute",
				BadgeStyle = nil,
				Colours = false,
			},
		}
		TriggerEvent("ArenaLobby:lobbymenu:SetInfo", infoList)
	end
end

function UpdatePlayerList()
	if string.find(string.lower(ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena())), "racing") and exports["DarkRP_Racing"]:IsInGame() then
		exports["DarkRP_Racing"]:UpdatePlayerList()
	else
		local CurrentSize = ArenaAPI:GetArenaCurrentSize(ArenaAPI:GetPlayerArena())
		local MinimumSize = ArenaAPI:GetArenaMinimumSize(ArenaAPI:GetPlayerArena())
		local MaximumSize = ArenaAPI:GetArenaMaximumSize(ArenaAPI:GetPlayerArena())
		local ArenaBusy = ArenaAPI:IsCurrentArenaBusy()
		
		local playerList = {}
		for source,v in pairs(ArenaAPI:GetPlayerListArena(ArenaAPI:GetPlayerArena())) do
			local player = GetPlayerFromServerId(source)
			local ped = PlayerPedId()
			if player ~= -1 then
				ped = GetPlayerPed(player)
			end
			table.insert(playerList, {
				name = v.name,
				Colours = (ArenaBusy and 18 or 15),
				LobbyBadgeIcon = LobbyBadgeIcon.IS_PC_PLAYER,
				Status = (ArenaBusy and "PLAYING" or "WAITING"),
				CrewTag = "",
				lev = (Player(source).state.PlayerXP or 1),
				ped = ped,
				HasPlane = IsPedInAnyPlane(ped),
				HasHeli = IsPedInAnyHeli(ped),
				HasBoat = IsPedInAnyBoat(ped),
				HasVehicle = IsPedInAnyVehicle(ped),
			})
		end
		for i=1,MaximumSize-CurrentSize do
			table.insert(playerList, {
				name = "empty",
				Colours = 3,
				LobbyBadgeIcon = false,
				Status = false,
				CrewTag = "",
				lev = "",
				ped = false,
			})
		end
		
		TriggerEvent("ArenaLobby:lobbymenu:SetPlayerList", playerList)
	end
end

AddEventHandler("ArenaLobby:PauseMenu.Map", function(_buttonParams)
	TriggerEvent("ArenaLobby:lobbymenu:Hide")
	Wait(100)
	ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_MP_PAUSE"), false, 0)
end)

AddEventHandler("ArenaLobby:PauseMenu.Setting", function(_buttonParams)
	TriggerEvent("ArenaLobby:lobbymenu:Hide")
	Wait(100)
	ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_MP_PAUSE"), false, 6)
end)

AddEventHandler("ArenaLobby:PauseMenu.leave", function(_buttonParams)
	TriggerEvent("ArenaLobby:lobbymenu:Hide")
	ExecuteCommand("minigame leave")
end)

local function OpenPauseMenu()
	local txd = string.gsub(ArenaAPI:GetPlayerArena(), "%d+", "")
	TriggerEvent("ArenaLobby:lobbymenu:SetInfoTitle", {
		tex = "ArenaLobby",
		txd = txd
	})
	UpdateInfos()
	UpdateDetails()
	UpdatePlayerList()
	
	TriggerEvent("ArenaLobby:lobbymenu:Show")
end
AddEventHandler("ArenaLobby:OpenPauseMenu", function()
	OpenPauseMenu()
end)

RegisterCommand("+ArenaLobby_PauseMenu_ESC", function()
	if ArenaAPI and ArenaAPI:IsPlayerInAnyArena() then
		if string.find(string.lower(ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena())), "racing") then
			if exports["DarkRP_Racing"]:IsOnSpectate() then 
				return
			end
		end
		if not IsPauseMenuActive() then
			OpenPauseMenu()
		end
	end
end, false)
RegisterCommand("-ArenaLobby_PauseMenu_ESC", function()
end, false)
RegisterKeyMapping("+ArenaLobby_PauseMenu_ESC", "ArenaLobby PauseMenu ESC", "keyboard", "ESCAPE")

RegisterCommand("+ArenaLobby_PauseMenu_P", function()
	if ArenaAPI and ArenaAPI:IsPlayerInAnyArena() then
		if not IsPauseMenuActive() then
			OpenPauseMenu()
		end
	end
end, false)
RegisterCommand("-ArenaLobby_PauseMenu_P", function()
end, false)
RegisterKeyMapping("+ArenaLobby_PauseMenu_P", "ArenaLobby PauseMenu P", "keyboard", "P")

RegisterCommand("+ArenaLobby_PauseMenu_Xbox", function()
	if ArenaAPI and ArenaAPI:IsPlayerInAnyArena() then
		if not IsPauseMenuActive() then
			OpenPauseMenu()
		end
	end
end, false)
RegisterCommand("-ArenaLobby_PauseMenu_Xbox", function()
end, false)
RegisterKeyMapping("+ArenaLobby_PauseMenu_Xbox", "ArenaLobby PauseMenu Xbox", "PAD_ANALOGBUTTON", "START_INDEX")

RegisterNetEvent("ArenaAPI:sendStatus")
AddEventHandler("ArenaAPI:sendStatus", function(type, data)
	Wait(100)
	if ArenaAPI and ArenaAPI:IsPlayerInAnyArena() and ArenaAPI:GetPlayerArena() == data.ArenaIdentifier then
		-- UpdateInfos()
		UpdatePlayerList()
		while ArenaAPI:IsPlayerInAnyArena() do
			DisableControlAction(0, 200, true)
			DisableControlAction(0, 199, true)
			Wait(0)
		end
	end
end)