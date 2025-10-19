-- CreateThread(function()
-- while true do
-- DisableControlAction(0, 200, true)
-- DisableControlAction(0, 199, true)
-- Citizen.Wait(0)
-- end
-- end)

local LobbyMenu
local settingsPanel = {}
local playersPanel = {}
local missionsPanel = {}
local defaultSubtitle = "Template by H@mer"

local minimapLobbyEnabled = false
local firstLoad = true
local DataSet = {
	HeaderMenu = {},
	PlayerList = {},
	SettingsColumn = {},
	InfoTitle = {},
	Info = {},
}

local function CreateLobbyMenu()
	if not LobbyMenu then
		LobbyMenu = MainView.New("Lobby Menu", defaultSubtitle, "", "", "")

		settingsPanel = SettingsListColumn.New("COLUMN SETTINGS", 16)
		playersPanel = PlayerListColumn.New("COLUMN PLAYERS", 16)
		missionsPanel = MissionDetailsPanel.New("COLUMN INFO PANEL", 10)

		LobbyMenu:SetupLeftColumn(settingsPanel)
		LobbyMenu:SetupCenterColumn(playersPanel)
		LobbyMenu:SetupRightColumn(missionsPanel)

		--[[
		RequestStreamedTextureDictC("ArenaLobby")
		local mugshot = RegisterPedheadshot(PlayerPedId())
		local timer = GetGameTimer()
		while not IsPedheadshotReady(mugshot) and GetGameTimer() - timer < 1000 do
			Citizen.Wait(0)
		end
		local headshot = GetPedheadshotTxdString(mugshot)
		AddReplaceTexture("ArenaLobby", "LobbyHeadshot", headshot, headshot)
		LobbyMenu:HeaderPicture("ArenaLobby", "LobbyHeadshot") -- LobbyMenu:CrewPicture used to add a picture on the left of the HeaderPicture
		UnregisterPedheadshot(mugshot) -- call it right after adding the menu.. this way the txd will be loaded correctly by the scaleform..
		]]

		LobbyMenu:CanPlayerCloseMenu(true) -- this is just an example..CanPlayerCloseMenu is always defaulted to true.. if you set this to false.. be sure to give the players a way out of your menu!!!

		local item = UIMenuItem.New("UIMenuItem", "UIMenuItem description")
		item:BlinkDescription(true)
		settingsPanel:AddSettings(item)

		local crew = CrewTag.New("", true, false, CrewHierarchy.Leader, SColor.HUD_Green)
		local friend = FriendItem.New("Name", SColor.FromHudColor(HudColours.HUD_COLOUR_FREEMODE), true, HudColours.HUD_COLOUR_FREEMODE, "BLANK", crew)
		playersPanel:AddPlayer(friend)

		missionsPanel:UpdatePanelPicture("scaleformui", "lobby_panelbackground")
		missionsPanel:Title("ScaleformUI - Title")

		local detailItem = UIMenuFreemodeDetailsItem.New("Left Label", "Right Label", false, BadgeStyle.BRIEFCASE, SColor.HUD_Freemode)
		missionsPanel:AddItem(detailItem)

		-- Player option menu
		playersPanel.OnPlayerItemActivated = function(index)
			-- Host select player row
			if ArenaAPI:IsPlayerInAnyArena() and ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).ownerSource == GetPlayerServerId(PlayerId()) then
				if DataSet.PlayerList[index] and DataSet.PlayerList[index].ped then
					local targetSource = DataSet.PlayerList[index].source
					local settingList = {
						{
							label = "Back",
							dec = "",
							callbackFunction = function()
								UpdateDetails()
								UpdatePlayerList()
							end,
						},
					}

					if ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).ownerSource ~= targetSource then
						table.insert(settingList, {
							label = "<font color='#c8423b'>Kick</font",
							dec = "Kick player from current lobby.",
							HudColours.HUD_COLOUR_RED,
							highlightColor = HudColours.HUD_COLOUR_REDDARK,
							textColor = HudColours.HUD_COLOUR_PURE_WHITE,
							highlightedTextColor = HudColours.HUD_COLOUR_PURE_WHITE,
							Blink = true,
							callbackFunction = function()
								PlaySoundFrontend(-1, "MP_IDLE_KICK", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
								TriggerServerEvent("ArenaLobby:lobbymenu:KickPlayer", targetSource)

								UpdateDetails()
								UpdatePlayerList()
							end,
						})
					end

					TriggerEvent("ArenaLobby:lobbymenu:SettingsColumn", settingList)
					TriggerEvent("ArenaLobby:lobbymenu:SetPlayerList", {DataSet.PlayerList[index]})

					LobbyMenu:SelectColumn(0)
				end
			end
		end

		--[[ -- EXAMPLE OF FILTERING, SORTING AND RESET TO ORIGINAL
		Citizen.Wait(3000)
		settings:SortSettings(function(a, b)
			return a:Label() < b:Label()
		end)
		Citizen.Wait(3000)
		settings:FilterSettings(function(x)
			return x:Label() == "UIMenuItem"
		end)
		Citizen.Wait(3000)
		settings:ResetFilter()
		]]
		-- Citizen.Wait(100)
		firstLoad = false
	end
end

---Can't change while LobbyMenu already visible
AddEventHandler("ArenaLobby:lobbymenu:SetHeaderMenu", function(data)
	while firstLoad do
		Citizen.Wait(0)
	end

	-- Check if some row has changed before apply: optimization
	local isChange = false
	if #data ~= #DataSet.HeaderMenu then
		isChange = true
	else
		for k, v in pairs(data) do
			if not DataSet.HeaderMenu[k] then
				isChange = true
				break
			else
				if DataSet.HeaderMenu[k] and DataSet.HeaderMenu[k] ~= v then
					isChange = true
					break
				end
			end
		end
	end

	if isChange then
		if data.Title then
			LobbyMenu.Title = data.Title
		end

		if data.Subtitle then
			LobbyMenu.Subtitle = data.Subtitle
		end

		if data.SideTop then
			LobbyMenu.SideTop = data.SideTop
		end

		if data.SideMid then
			LobbyMenu.SideMid = data.SideMid
		end

		if data.SideBot then
			LobbyMenu.SideBot = data.SideBot
		end

		if data.settingsPanel then
			settingsPanel.Label = data.settingsPanel
		end

		if data.playersPanel then
			playersPanel.Label = data.playersPanel
		end

		if data.missionsPanel then
			missionsPanel.Label = data.missionsPanel
		end

		if data.ColColor1 then
			settingsPanel.Color = SColor.FromHudColor(data.ColColor1)
		end

		if data.ColColor2 then
			playersPanel.Color = SColor.FromHudColor(data.ColColor2)
		end

		if data.ColColor3 then
			missionsPanel.Color = SColor.FromHudColor(data.ColColor3)
		end

		DataSet.HeaderMenu = data
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:SetPlayerList", function(data)
	while firstLoad do
		Citizen.Wait(0)
	end
	-- if LobbyMenu:Visible() then
	-- 	Citizen.Wait(300)
	-- end

	local isChange = false
	if #data ~= #DataSet.PlayerList then
		isChange = true
	else
		for k, v in pairs(data) do
			if not DataSet.PlayerList[k] then
				isChange = true
				break
			else
				for kk, vv in pairs(v) do
					if kk ~= "callbackFunction" and kk ~= "ped" and DataSet.PlayerList[k][kk] and DataSet.PlayerList[k][kk] ~= vv then
						isChange = true
						break
					end
				end
				if isChange then
					break
				end
			end
		end
	end

	if isChange then
		local currentRow = playersPanel:CurrentSelection()
		local hostSource = -1
		if ArenaAPI:IsPlayerInAnyArena() then
			hostSource = ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).ownerSource
		end

		playersPanel:Populate()
		playersPanel:Clear()

		-- Sort player row
		for k, v in pairs(data) do
			if not v.sortScore then
				if hostSource == v.source then
					v.sortScore = 1
				elseif v.LobbyBadgeIcon == ScoreRightIconType.SPECTATOR then -- JoinAsSpectatorMode
					v.sortScore = 3
				elseif v.ped then
					v.sortScore = 2
				else
					v.sortScore = 4
				end
			end
		end
		table.sort(data, function(a, b)
			return a.sortScore < b.sortScore
		end)

		-- Add player row
		for k, v in pairs(data) do
			if GetPlayerFromServerId(v.source) ~= -1 then
				v.MP0_STAMINA = DecorGetInt(v.ped, "AL_MP0_STAMINA")
				v.MP0_STRENGTH = DecorGetInt(v.ped, "AL_MP0_STRENGTH")
				v.MP0_LUNG_CAPACITY = DecorGetInt(v.ped, "AL_MP0_LUNG_CAPACITY")
				v.MP0_SHOOTING_ABILITY = DecorGetInt(v.ped, "AL_MP0_SHOOTING_ABILITY")
				v.MP0_DRIVING_ABILITY = DecorGetInt(v.ped, "AL_MP0_WHEELIE_ABILITY")
				v.MP0_WHEELIE_ABILITY = DecorGetInt(v.ped, "AL_MP0_WHEELIE_ABILITY")
				v.MP0_FLYING_ABILITY = DecorGetInt(v.ped, "AL_MP0_FLYING_ABILITY")
				v.MP0_STEALTH_ABILITY = DecorGetInt(v.ped, "AL_MP0_STEALTH_ABILITY")
				v.MPPLY_KILLS_PLAYERS = DecorGetInt(v.ped, "AL_MP0_HIGHEST_MENTAL_STATE")
			else
				v.MP0_STAMINA = 0
				v.MP0_STRENGTH = 0
				v.MP0_LUNG_CAPACITY = 0
				v.MP0_SHOOTING_ABILITY = 0
				v.MP0_DRIVING_ABILITY = 0
				v.MP0_WHEELIE_ABILITY = 0
				v.MP0_FLYING_ABILITY = 0
				v.MP0_STEALTH_ABILITY = 0
				v.MPPLY_KILLS_PLAYERS = 0
			end
			v.HasPlane = IsPedInAnyPlane(v.ped)
			v.HasHeli = IsPedInAnyHeli(v.ped)
			v.HasBoat = IsPedInAnyBoat(v.ped)
			v.HasVehicle = IsPedInAnyVehicle(v.ped, false)

			local lobbyBadge = LobbyBadgeIcon.IS_PC_PLAYER
			if v.LobbyBadgeIcon then
				lobbyBadge = v.LobbyBadgeIcon
			elseif GetPlayerFromServerId(v.source) ~= -1 then
				if not DecorGetBool(v.ped, "IsUsingKeyboard") then
					lobbyBadge = LobbyBadgeIcon.IS_CONSOLE_PLAYER
				end
			end

			local crew = CrewTag.New(v.CrewTag, true, false, CrewHierarchy.Leader, SColor.HUD_Green)
			local friend = FriendItem.New(v.name, SColor.FromHudColor(v.Colours), true, v.level, v.Status, crew)

			friend.ClonePed = v.ped
			local panel = PlayerStatsPanel.New(v.name, SColor.FromHudColor(v.rowColor or HudColours.HUD_COLOUR_PAUSE_DESELECT))
			panel:HasPlane(v.HasPlane)
			panel:HasHeli(v.HasHeli)
			panel:HasBoat(v.HasBoat)
			panel:HasVehicle(v.HasVehicle)
			panel.RankInfo:RankLevel(v.level)
			-- panel.RankInfo:LowLabel("This is the low label")
			-- panel.RankInfo:MidLabel("This is the middle label")
			-- panel.RankInfo:UpLabel("This is the upper label")
			panel:AddStat(PlayerStatsPanelStatItem.New("Stamina", GetSkillStaminaDescription(v.MP0_STAMINA), v.MP0_STAMINA))
			panel:AddStat(PlayerStatsPanelStatItem.New("Shooting", GetSkillShootingDescription(v.MP0_SHOOTING_ABILITY), v.MP0_SHOOTING_ABILITY))
			panel:AddStat(PlayerStatsPanelStatItem.New("Strength", GetSkillStrengthDescription(v.MP0_STRENGTH), v.MP0_STRENGTH))
			panel:AddStat(PlayerStatsPanelStatItem.New("Stealth", GetSkillStealthDescription(v.MP0_STEALTH_ABILITY), v.MP0_STEALTH_ABILITY))
			panel:AddStat(PlayerStatsPanelStatItem.New("Driving", GetSkillDrivingDescription(v.MP0_DRIVING_ABILITY), v.MP0_DRIVING_ABILITY))
			panel:AddStat(PlayerStatsPanelStatItem.New("Flying", GetSkillFlyingDescription(v.MP0_FLYING_ABILITY), v.MP0_FLYING_ABILITY))
			panel:AddStat(PlayerStatsPanelStatItem.New("Mental State", GetSkillMentalStateDescription(v.MPPLY_KILLS_PLAYERS), v.MPPLY_KILLS_PLAYERS))
			friend:AddPanel(panel)

			if v.ped then
				friend:Enabled(true)
				panel:Description("My name is "..tostring(v.name))
				friend:SetLeftIcon(lobbyBadge, false)
				friend:SetRightIcon(BadgeStyle.INV_MISSION, false)
			else
				friend:Enabled(false)
				panel:Description("Empty")
				friend:SetLeftIcon(BadgeStyle.NONE, false)
				friend:SetRightIcon(BadgeStyle.NONE, false)
			end

			playersPanel:AddPlayer(friend)
		end
		
		-- Fixed players column row changing to 1 from playersPanel:Clear()
		if playersPanel.Parent.CurrentColumnIndex == 1 then
			playersPanel:CurrentSelection(currentRow)
		end
		
		DataSet.PlayerList = table.clone(data)
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:SetInfo", function(data)
	while firstLoad do
		Citizen.Wait(0)
	end
	-- if LobbyMenu:Visible() then
	-- 	Citizen.Wait(300)
	-- end

	-- Check if some row has changed before apply: optimization
	local isChange = false
	if #data ~= #DataSet.Info then
		isChange = true
	else
		for k, v in pairs(data) do
			if not DataSet.Info[k] then
				isChange = true
				break
			else
				for kk, vv in pairs(v) do
					if DataSet.Info[k][kk] and DataSet.Info[k][kk] ~= vv then
						isChange = true
						break
					end
				end
				if isChange then
					break
				end
			end
		end
	end

	if isChange then
		for i = 1, #missionsPanel.Items do
			missionsPanel:RemoveItem(#missionsPanel.Items)
		end

		for k, v in pairs(data) do
			local detailItem = UIMenuFreemodeDetailsItem.New(v.LeftLabel, v.RightLabel, false, v.BadgeStyle, v.Colours)
			missionsPanel:AddItem(detailItem)
		end

		DataSet.Info = table.clone(data)
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:SetInfoTitle", function(data)
	while firstLoad do
		Citizen.Wait(0)
	end
	-- if LobbyMenu:Visible() then
	-- 	Citizen.Wait(300)
	-- end

	-- Check if some row has changed before apply: optimization
	local isChange = false
	if #data ~= #DataSet.InfoTitle then
		isChange = true
	else
		for k, v in pairs(data) do
			if not DataSet.InfoTitle[k] then
				isChange = true
				break
			else
				if DataSet.InfoTitle[k] and DataSet.InfoTitle[k] ~= v then
					isChange = true
					break
				end
			end
		end
	end

	if isChange then
		if data.Title then
			missionsPanel:Title(data.Title)
		end

		if data.tex and data.txd then
			missionsPanel:UpdatePanelPicture(data.tex, data.txd)
		end
		DataSet.InfoTitle = data
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:SettingsColumn", function(data)
	while firstLoad do
		Citizen.Wait(0)
	end
	-- if LobbyMenu:Visible() then
	-- 	Citizen.Wait(300)
	-- end

	-- Check if some row has changed before apply: optimization
	local isChange = false
	if #data ~= #DataSet.SettingsColumn then
		isChange = true
	else
		for k, v in pairs(data) do
			if not DataSet.SettingsColumn[k] then
				isChange = true
				break
			else
				for kk, vv in pairs(v) do
					if kk ~= "callbackFunction" and DataSet.SettingsColumn[k][kk] and DataSet.SettingsColumn[k][kk] ~= vv then
						isChange = true
						break
					end
				end
				if isChange then
					break
				end
			end
		end
	end

	if isChange then
		settingsPanel:Populate()
		settingsPanel:Clear()

		for k, v in pairs(data) do
			local item
			if v.type == "List" then
				item = UIMenuListItem.New(v.label, v.list, 0, v.dec, v.mainColor, v.highlightColor)
			elseif v.type == "Checkbox" then
				item = UIMenuCheckboxItem.New(v.label, true, 1, v.dec)
			elseif v.type == "Slider" then
				item = UIMenuSliderItem.New(v.label, 100, 5, 50, false, v.dec)
			elseif v.type == "Progress" then
				item = UIMenuProgressItem.New(v.label, 10, 5, v.dec)
			else
				item = UIMenuItem.New(v.label, v.dec, v.mainColor and SColor.FromHudColor(v.mainColor), v.highlightColor and SColor.FromHudColor(v.highlightColor))
				if v.rightLabel then
					item:RightLabel(v.rightLabel)
				end
			end
			item:BlinkDescription(v.Blink)
			item.Activated = function(menu, item)
				if v.callbackFunction then
					v.callbackFunction()
				end
			end
			settingsPanel:AddSettings(item)
		end

		if LobbyMenu:Visible() then
			settingsPanel:UpdateDescription()
			settingsPanel:CurrentSelection(1)
		end

		DataSet.SettingsColumn = table.clone(data)
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:MapPanel", function(data)
	while not LobbyMenu do
		Citizen.Wait(0)
	end

	LobbyMenu.MinimapButton = nil
	LobbyMenu.hasMapPanel = true

	minimapLobbyEnabled = false
	LobbyMenu.Minimap:Enabled(false) -- Force refresh map position
	LobbyMenu.MinimapButton = InstructionalButton.New("Toggle Map Panel", -1, 203, 203, -1)
	LobbyMenu.MinimapButton.OnControlSelected = function(control)
		minimapLobbyEnabled = not minimapLobbyEnabled
		if minimapLobbyEnabled then
			LobbyMenu.Minimap.MinimapRoute.RouteColor = HudColours.HUD_COLOUR_YELLOW
			LobbyMenu.Minimap.MinimapRoute.MapThickness = 17
			for k, v in pairs(data) do
				local blipColor = 5
				if v.path == 1 then
					blipColor = 83
				elseif v.path == 2 then
					blipColor = 3
				elseif v.path == 3 then
					blipColor = 29
				elseif v.path == 4 then
					blipColor = 17
				elseif v.path == 5 then
					blipColor = 8
				elseif v.path == 6 then
					blipColor = 23
				end
				if k == 1 then
					LobbyMenu.Minimap.MinimapRoute.StartPoint = MinimapRaceCheckpoint.New(309, vector3(v.x, v.y, v.z), 0, 0.6, false)
				elseif k == #data then
					LobbyMenu.Minimap.MinimapRoute.EndPoint = MinimapRaceCheckpoint.New(38, vector3(v.x, v.y, v.z), 0, 0.6, false)
				else
					table.insert(LobbyMenu.Minimap.MinimapRoute.CheckPoints, MinimapRaceCheckpoint.New(271, vector3(v.x, v.y, v.z), blipColor, 0.5, v.order))
				end
			end
		else
			LobbyMenu.Minimap:ClearMinimap()
		end
		LobbyMenu.Minimap:Enabled(minimapLobbyEnabled)
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:Show", function(focusColumn, canClose, onClose)
	CreateLobbyMenu()

	if LobbyMenu:Visible() then
		TriggerEvent("ArenaLobby:lobbymenu:Hide")
		-- Citizen.Wait(50)
	end
	while firstLoad or IsDisabledControlPressed(0, 199) or IsDisabledControlPressed(0, 200) or IsPauseMenuRestarting() or IsFrontendFading() or IsPauseMenuActive() do
		SetPauseMenuActive(false)
		SetFrontendActive(false)
		Citizen.Wait(0)
	end
	while LobbyMenu.Subtitle == defaultSubtitle do
		Citizen.Wait(0)
	end

	LobbyMenu.InstructionalButtons = {}
	table.insert(LobbyMenu.InstructionalButtons, InstructionalButton.New(GetLabelText("HUD_INPUT2"), -1, 191, 191, -1))
	if canClose then
		table.insert(LobbyMenu.InstructionalButtons, InstructionalButton.New(GetLabelText("HUD_INPUT3"), -1, 194, 194, -1))
	end
	table.insert(LobbyMenu.InstructionalButtons, InstructionalButton.New(GetLabelText("HUD_INPUT8"), -1, -1, -1, "INPUTGROUP_FRONTEND_BUMPERS"))
	table.insert(LobbyMenu.InstructionalButtons, InstructionalButton.New(GetLabelText("HUD_INPUT1C"), -1, -1, -1, "INPUTGROUP_FRONTEND_DPAD_ALL"))

	if LobbyMenu.hasMapPanel then
		while not LobbyMenu.MinimapButton do
			Citizen.Wait(0)
		end
		table.insert(LobbyMenu.InstructionalButtons, LobbyMenu.MinimapButton)
	end

	LobbyMenu:CanPlayerCloseMenu(canClose)
	LobbyMenu:Visible(true)
	TriggerEvent("ArenaLobby:lobbymenu:SetFocusColumn", focusColumn)

	while LobbyMenu:Visible() do
		Citizen.Wait(0)
	end

	-- onClose
	if onClose then
		while IsPauseMenuRestarting() or IsFrontendFading() or IsPauseMenuActive() do
			Citizen.Wait(0)
		end
		onClose()
	end

	LobbyMenu.hasMapPanel = false
end)

AddEventHandler("ArenaLobby:lobbymenu:SetFocusColumn", function(focusColumn)
	if LobbyMenu then
		if LobbyMenu:Visible() then
			LobbyMenu:SelectColumn(focusColumn)

			if focusColumn == 0 then
				settingsPanel:CurrentSelection(1)
			elseif focusColumn == 1 then
				Citizen.CreateThread(function()
					Citizen.Wait(1) -- Waiting for add ped to pause menu be done
					playersPanel:CurrentSelection(1)
				end)
			end
		end
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:Hide", function()
	if LobbyMenu then
		LobbyMenu:SelectColumn(0) -- Fix pause menu invisible after closed with focusColumn~=0
		LobbyMenu:Visible(false)
	end
end)

RegisterNetEvent("ArenaLobby:lobbymenu:leaveLobby")
AddEventHandler("ArenaLobby:lobbymenu:leaveLobby", function()
	ExecuteCommand("minigame leave")
	TriggerEvent("ArenaLobby:lobbymenu:Hide")
end)
