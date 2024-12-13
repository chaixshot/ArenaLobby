local function GetCurrentRank()
	if GetResourceState("DarkRP_XP") == "started" then -- DarkRP_XP request.
		return exports.DarkRP_XP:GetCurrentPlayerLevel()
	else
		return 1
	end
end

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
			Col2 = "PLAYERS "..CurrentSize.." OF "..MaximumSize,
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
				RightLabel = DecimalsToMinutes(MaximumArenaTime).." Minute",
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
			local HostSource = ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).ownerSource
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
					level = DecorGetInt(ped, "AL_Rank"),
					ped = ped,
				})
			end
			for i = 1, MaximumSize - CurrentSize do
				-- for i=1, 16-CurrentSize do
				table.insert(playerList, {
					name = "empty",
					rowColor = HudColours.HUD_COLOUR_MENU_GREY_DARK,
					Colours = HudColours.HUD_COLOUR_MENU_GREY_DARK,
					LobbyBadgeIcon = 0,
					Status = false,
					CrewTag = "",
					level = "",
					ped = false,
				})
			end

			TriggerEvent("ArenaLobby:lobbymenu:SetPlayerList", playerList)
		end
	end
end

local function OpenPauseMenu()
	local allow = true

	if GetResourceState("DarkRP_Racing") == "started" then
		if exports["DarkRP_Racing"]:IsPlayerOnSpectate() then
			allow = false
		elseif exports["DarkRP_Racing"]:GetEndScreen().IsOnEndScreen then
			allow = false
		end
	end
	if GetResourceState("DarkRP_Bomb") == "started" then
		if exports["DarkRP_Bomb"]:IsPlayerOnSpectate() then
			allow = false
		end
	end
	if GetResourceState("DarkRDarkRP_TeamdeathmacthP_Racing") == "started" then
		if exports["DarkRP_Teamdeathmacth"]:IsPlayerOnSpectate() then
			allow = false
		end
	end
	if GetResourceState("DarkRP_CaptureTheFlag") == "started" then
		if exports["DarkRP_CaptureTheFlag"]:IsPlayerOnSpectate() then
			allow = false
		end
	end
	if GetResourceState("DarkRP_ZombieSurvival") == "started" then
		if exports["DarkRP_ZombieSurvival"]:IsPlayerOnSpectate() then
			allow = false
		end
	end

	if ArenaAPI and ArenaAPI:IsPlayerInAnyArena() and allow then
		if not IsPauseMenuActive() and (IsGameplayCamRendering() or IsPlayerSwitchInProgress() or NetworkIsInSpectatorMode()) then
			UpdatePlayerState()
			UpdateInfos()
			UpdateDetails()
			UpdatePlayerList()

			TriggerEvent("ArenaLobby:lobbymenu:Show", 1, true)
		end
	end
end

AddEventHandler("ArenaLobby:OpenPauseMenu", OpenPauseMenu)

RegisterCommand("+ArenaLobby_PauseMenu", OpenPauseMenu, false)
RegisterCommand("-ArenaLobby_PauseMenu", function() end, false)
RegisterKeyMapping("+ArenaLobby_PauseMenu", "ArenaLobby PauseMenu", "keyboard", "ESCAPE")

RegisterCommand("+ArenaLobby_PauseMenu_P", OpenPauseMenu, false)
RegisterCommand("-ArenaLobby_PauseMenu_P", function() end, false)
RegisterKeyMapping("+ArenaLobby_PauseMenu_P", "ArenaLobby PauseMenu P", "keyboard", "P")

RegisterCommand("+ArenaLobby_PauseMenu_Xbox", OpenPauseMenu, false)
RegisterCommand("-ArenaLobby_PauseMenu_Xbox", function() end, false)
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

DecorRegister("IsUsingKeyboard", 3)
DecorRegister("AL_Rank", 2)
DecorRegister("AL_MP0_STAMINA", 2)
DecorRegister("AL_MP0_STRENGTH", 2)
DecorRegister("AL_MP0_LUNG_CAPACITY", 2)
DecorRegister("AL_MP0_SHOOTING_ABILITY", 2)
DecorRegister("AL_MP0_WHEELIE_ABILITY", 2)
DecorRegister("AL_MP0_FLYING_ABILITY", 2)
DecorRegister("AL_MP0_STEALTH_ABILITY", 2)
DecorRegister("AL_MP0_HIGHEST_MENTAL_STATE", 2)
function UpdatePlayerState()
	local playerPed = PlayerPedId()

	StatSetBool(GetHashKey("MP0_DEFAULT_STATS_SET"), true, true)
	StatSetBool(GetHashKey("MP1_DEFAULT_STATS_SET"), true, true)

	DecorSetBool(playerPed, "IsUsingKeyboard", IsUsingKeyboard(0))
	DecorSetInt(playerPed, "AL_Rank", GetCurrentRank())
	DecorSetInt(playerPed, "AL_MP0_STAMINA", select(2, StatGetInt(`MP0_STAMINA`, -1)))
	DecorSetInt(playerPed, "AL_MP0_STRENGTH", select(2, StatGetInt(`MP0_STRENGTH`, -1)))
	DecorSetInt(playerPed, "AL_MP0_LUNG_CAPACITY", select(2, StatGetInt(`MP0_LUNG_CAPACITY`, -1)))
	DecorSetInt(playerPed, "AL_MP0_SHOOTING_ABILITY", select(2, StatGetInt(`MP0_SHOOTING_ABILITY`, -1)))
	DecorSetInt(playerPed, "AL_MP0_WHEELIE_ABILITY", select(2, StatGetInt(`MP0_WHEELIE_ABILITY`, -1)))
	DecorSetInt(playerPed, "AL_MP0_FLYING_ABILITY", select(2, StatGetInt(`MP0_FLYING_ABILITY`, -1)))
	DecorSetInt(playerPed, "AL_MP0_STEALTH_ABILITY", select(2, StatGetInt(`MP0_STEALTH_ABILITY`, -1)))
	DecorSetInt(playerPed, "AL_MP0_HIGHEST_MENTAL_STATE", select(2, StatGetInt(`MP0_HIGHEST_MENTAL_STATE`, -1)))
end

exports("IsAnyMenuOpen", function()
	return MenuHandler:IsAnyMenuOpen()
end)

exports("IsAnyPauseMenuOpen", function()
	return MenuHandler:IsAnyPauseMenuOpen()
end)
