function UpdateDetails()
	if string.find(string.lower(ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena())), "racing") and exports["DarkRP_Racing"]:IsPlayerInGame() then -- Racing call
		exports["DarkRP_Racing"]:UpdateDetails()
	else
		RequestStreamedTextureDictC("ArenaLobby")

		local CurrentSize = ArenaAPI:GetArenaCurrentSize(ArenaAPI:GetPlayerArena())
		local MaximumSize = ArenaAPI:GetArenaMaximumSize(ArenaAPI:GetPlayerArena())
		local ArenaLabel = string.split(ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena()):gsub("<br>", "|"), "|")

		TriggerEvent("ArenaLobby:lobbymenu:SetHeaderMenu", {
			Title = "DarkRP - GameRoom",
			Subtitle = (ArenaLabel[1] and ArenaLabel[1]:gsub("<b", "<p"):gsub("</b>", "</p>") or ""),
			SideTop = (ArenaLabel[2] and ArenaLabel[2]:gsub("<b", "<p"):gsub("</b>", "</p>") or ""),
			SideMid = (ArenaLabel[4] and ArenaLabel[4]:gsub("<b", "<p"):gsub("</b>", "</p>") or ""),
			SideBot = (ArenaLabel[3] and ArenaLabel[3]:gsub("<b", "<p"):gsub("</b>", "</p>"):gsub("%]", ""):gsub("%[", "") or ""),
			Col1 = "🕹️  GAME",
			Col2 = "PLAYERS " .. CurrentSize .. " OF " .. MaximumSize,
			Col3 = "INFO",
			ColColor1 = HudColours.HUD_COLOUR_FREEMODE,
			ColColor2 = HudColours.HUD_COLOUR_FREEMODE,
			ColColor3 = HudColours.HUD_COLOUR_FREEMODE,
		})

		local txd = string.gsub(ArenaAPI:GetPlayerArena(), "%d+", "")
		TriggerEvent("ArenaLobby:lobbymenu:SetInfoTitle", {
			Title = ArenaLabel[1],
			tex = "ArenaLobby",
			txd = txd
		})

		local settingList = {
			{
				label = "Setting",
				dec = "Open game setting menu.",
				callbackFunction = function()
					TriggerEvent("ArenaLobby:lobbymenu:Hide")
					Citizen.Wait(100)
					ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_MP_PAUSE"), false, 6)
				end,
			},
			{
				label = "Map",
				dec = "Open map menu.",
				callbackFunction = function()
					TriggerEvent("ArenaLobby:lobbymenu:Hide")
					Citizen.Wait(100)
					ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_MP_PAUSE"), false, 0)
				end,
			},
			{
				label = "<font color='#c8423b'>Leave Game</font>",
				dec = "Leave current lobby.",
				callbackFunction = function()
					TriggerEvent("ArenaLobby:lobbymenu:Hide")
					ExecuteCommand("minigame leave")
				end,
				mainColor = HudColours.HUD_COLOUR_RED,
				highlightColor = HudColours.HUD_COLOUR_REDDARK,
				textColor = HudColours.HUD_COLOUR_PURE_WHITE,
				highlightedTextColor = HudColours.HUD_COLOUR_PURE_WHITE,
				Blink = true,
			},
		}

		TriggerEvent("ArenaLobby:lobbymenu:SettingsColumn", settingList)
	end
end

local function UpdateInfos()
	if string.find(string.lower(ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena())), "racing") and exports["DarkRP_Racing"]:IsPlayerInGame() then
		exports["DarkRP_Racing"]:UpdateInfos()
	else
		local MinimumSize = ArenaAPI:GetArenaMinimumSize(ArenaAPI:GetPlayerArena())
		local MaximumArenaTime = ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).MaximumArenaTime
		local map = ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena()):match("%((.*)%)")
		local infoList = {
			{
				LeftLabel = "Map",
				RightLabel = map,
				BadgeStyle = BadgeStyle.INFO,
				Colours = false,
			},
			{
				LeftLabel = "Min Player",
				RightLabel = MinimumSize,
				BadgeStyle = BadgeStyle.INFO,
				Colours = false,
			},
			{
				LeftLabel = "Time Left",
				RightLabel = DecimalsToMinutes(MaximumArenaTime) .. " Minute",
				BadgeStyle = BadgeStyle.INFO,
				Colours = false,
			},
		}
		TriggerEvent("ArenaLobby:lobbymenu:SetInfo", infoList)
	end
end

function UpdatePlayerList()
	if ArenaAPI:IsPlayerInAnyArena() then
		if string.find(string.lower(ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena())), "racing") and exports["DarkRP_Racing"]:IsPlayerInGame() then
			exports["DarkRP_Racing"]:UpdatePlayerList()
		else
			local HostSource = ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).ownersource
			local CurrentSize = ArenaAPI:GetArenaCurrentSize(ArenaAPI:GetPlayerArena())
			local MaximumSize = ArenaAPI:GetArenaMaximumSize(ArenaAPI:GetPlayerArena())
			local ArenaBusy = ArenaAPI:IsArenaBusy(ArenaAPI:GetPlayerArena())

			local playerList = {}
			for source, v in pairs(ArenaAPI:GetPlayerListArena(ArenaAPI:GetPlayerArena())) do
				local isHost = HostSource == source
				local player = GetPlayerFromServerId(source)
				local ped = PlayerPedId()
				if player ~= -1 then
					ped = GetPlayerPed(player)
				end

				table.insert(playerList, {
					source = source,
					name = v.name,
					rowColor = HudColours.HUD_COLOUR_FREEMODE,
					Colours = (isHost and HudColours.HUD_COLOUR_FREEMODE or ArenaBusy and HudColours.HUD_COLOUR_GREEN or HudColours.HUD_COLOUR_ORANGE),
					Status = (isHost and "HOST" or ArenaBusy and "PLAYING" or "WAITING"),
					CrewTag = "",
					lev = (Player(source).state.PlayerXP or 1),
					ped = ped,
				})
			end
			for i=1, MaximumSize-CurrentSize do
				-- for i=1, 16-CurrentSize do
				table.insert(playerList, {
					name = "empty",
					rowColor = HudColours.HUD_COLOUR_PAUSE_DESELECT,
					Colours = HudColours.HUD_COLOUR_PAUSE_DESELECT,
					LobbyBadgeIcon = 0,
					Status = false,
					CrewTag = "",
					lev = "",
					ped = false,
				})
			end

			TriggerEvent("ArenaLobby:lobbymenu:SetPlayerList", playerList)
		end
	end
end

local function OpenPauseMenu()
	UpdatePlayerState()
	UpdateInfos()
	UpdateDetails()
	UpdatePlayerList()

	TriggerEvent("ArenaLobby:lobbymenu:Show", 1, true)
end

AddEventHandler("ArenaLobby:OpenPauseMenu", function()
	OpenPauseMenu()
end)

RegisterCommand("+ArenaLobby_PauseMenu_ESC", function()
	if ArenaAPI and ArenaAPI:IsPlayerInAnyArena() then
		if string.find(string.lower(ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena())), "racing") then
			if exports["DarkRP_Racing"]:IsPlayerOnSpectate() then
				return
			end
		end
		if not IsPauseMenuActive() and not IsPlayerSwitchInProgress() then
			OpenPauseMenu()
		end
	end
end, false)
RegisterCommand("-ArenaLobby_PauseMenu_ESC", function()
end, false)
RegisterKeyMapping("+ArenaLobby_PauseMenu_ESC", "ArenaLobby PauseMenu ESC", "keyboard", "ESCAPE")

RegisterCommand("+ArenaLobby_PauseMenu_P", function()
	if ArenaAPI and ArenaAPI:IsPlayerInAnyArena() then
		if not IsPauseMenuActive() and not IsPlayerSwitchInProgress() then
			OpenPauseMenu()
		end
	end
end, false)
RegisterCommand("-ArenaLobby_PauseMenu_P", function()
end, false)
RegisterKeyMapping("+ArenaLobby_PauseMenu_P", "ArenaLobby PauseMenu P", "keyboard", "P")

RegisterCommand("+ArenaLobby_PauseMenu_Xbox", function()
	if ArenaAPI and ArenaAPI:IsPlayerInAnyArena() then
		if not IsPauseMenuActive() and not IsPlayerSwitchInProgress() then
			OpenPauseMenu()
		end
	end
end, false)
RegisterCommand("-ArenaLobby_PauseMenu_Xbox", function()
end, false)
RegisterKeyMapping("+ArenaLobby_PauseMenu_Xbox", "ArenaLobby PauseMenu Xbox", "PAD_ANALOGBUTTON", "START_INDEX")

local DisablePauseMenu = false
RegisterNetEvent("ArenaAPI:sendStatus")
AddEventHandler("ArenaAPI:sendStatus", function(type, data)
	Citizen.Wait(100)
	if ArenaAPI and ArenaAPI:IsPlayerInAnyArena() then
		if ArenaAPI:GetPlayerArena() == data.ArenaIdentifier then
			UpdatePlayerState()
			if IsPauseMenuActive() then
				UpdatePlayerList()
			end
		end
		DisablePauseMenu = false
		Citizen.Wait(1)
		DisablePauseMenu = true
		while DisablePauseMenu do
			DisableControlAction(0, 200, true)
			DisableControlAction(0, 199, true)
			Citizen.Wait(0)
		end
	else
		DisablePauseMenu = false
	end
end)

function UpdatePlayerState()
	StatSetBool(GetHashKey("MP0_DEFAULT_STATS_SET"), true, true)
	StatSetBool(GetHashKey("MP1_DEFAULT_STATS_SET"), true, true)

	LocalPlayer.state:set("ArenaLobby_IsUsingKeyboard", IsUsingKeyboard(0), true)
	LocalPlayer.state:set("ArenaLobby_MP0_STAMINA", table.pack(StatGetInt(`MP0_STAMINA`))[2], true)
	LocalPlayer.state:set("ArenaLobby_MP0_STRENGTH", table.pack(StatGetInt(`MP0_STRENGTH`))[2], true)
	LocalPlayer.state:set("ArenaLobby_MP0_LUNG_CAPACITY", table.pack(StatGetInt(`MP0_LUNG_CAPACITY`))[2], true)
	LocalPlayer.state:set("ArenaLobby_MP0_SHOOTING_ABILITY", table.pack(StatGetInt(`MP0_SHOOTING_ABILITY`))[2], true)
	LocalPlayer.state:set("ArenaLobby_MP0_WHEELIE_ABILITY", table.pack(StatGetInt(`MP0_WHEELIE_ABILITY`))[2], true)
	LocalPlayer.state:set("ArenaLobby_MP0_FLYING_ABILITY", table.pack(StatGetInt(`MP0_FLYING_ABILITY`))[2], true)
	LocalPlayer.state:set("ArenaLobby_MP0_STEALTH_ABILITY", table.pack(StatGetInt(`MP0_STEALTH_ABILITY`))[2], true)
	LocalPlayer.state:set("ArenaLobby_MP0_HIGHEST_MENTAL_STATE", table.pack(StatGetInt(`MP0_HIGHEST_MENTAL_STATE`))[2], true)
end
