-- CreateThread(function()
-- while true do
-- DisableControlAction(0, 200, true)
-- DisableControlAction(0, 199, true)
-- Citizen.Wait(0)
-- end
-- end)

local LobbyMenu

local currentColumnId = 1
local currentSelectId = 1

local ColumnCallbackFunction = {}
ColumnCallbackFunction[1] = {}
ColumnCallbackFunction[2] = {}

local minimapLobbyEnabled = false
local menuLoaded = false
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
		local columns = {
			SettingsListColumn.New("COLUMN SETTINGS", SColor.HUD_Red),
			PlayerListColumn.New("COLUMN PLAYERS", SColor.HUD_Orange),
			MissionDetailsPanel.New("COLUMN INFO PANEL", SColor.HUD_Green),
		}
		LobbyMenu = MainView.New("Lobby Menu", "ScaleformUI for you by Manups4e!", "", "", "")
		-- LobbyMenu:ShowStoreBackground(true)
		-- LobbyMenu:StoreBackgroundAnimationSpeed(50)
		LobbyMenu:SetupColumns(columns)

		--[[
		RequestStreamedTextureDictC("ArenaLobby")
		local mugshot = RegisterPedheadshot(PlayerPedId())
		local timer = GetGameTimer()
		while not IsPedheadshotReady(mugshot) and GetGameTimer() - timer < 1000 do
			Citizen.Wait(0)
		end
		local headshot = GetPedheadshotTxdString(mugshot)
		AddReplaceTexture("ArenaLobby", "LobbyHeadshot", headshot, headshot)
		LobbyMenu:HeaderPicture("ArenaLobby", "LobbyHeadshot") -- lobbyMenu:CrewPicture used to add a picture on the left of the HeaderPicture
		UnregisterPedheadshot(mugshot) -- call it right after adding the menu.. this way the txd will be loaded correctly by the scaleform.. 
		]]

		LobbyMenu:CanPlayerCloseMenu(true)
		-- this is just an example..CanPlayerCloseMenu is always defaulted to true.. if you set this to false.. be sure to give the players a way out of your menu!!!

		local item = UIMenuItem.New("UIMenuItem", "UIMenuItem description")
		item:BlinkDescription(true)
		LobbyMenu.SettingsColumn:AddSettings(item)

		LobbyMenu.MissionPanel:UpdatePanelPicture("scaleformui", "lobby_panelbackground")
		LobbyMenu.MissionPanel:Title("ScaleformUI - Title")

		local detailItem = UIMenuFreemodeDetailsItem.New("Left Label", "Right Label", false, BadgeStyle.BRIEFCASE, SColor.HUD_Freemode)
		LobbyMenu.MissionPanel:AddItem(detailItem)

		LobbyMenu.SettingsColumn.OnIndexChanged = function(idx)
			currentSelectId = idx
			currentColumnId = 1
		end

		LobbyMenu.PlayersColumn.OnIndexChanged = function(idx)
			currentSelectId = idx
			currentColumnId = 2
		end

		--[[ -- EXAMPLE OF FILTERING, SORTING AND RESET TO ORIGINAL
		Citizen.Wait(3000)
		lobbyMenu.SettingsColumn:SortSettings(function(a, b)
			return a:Label() < b:Label()
		end)
		Citizen.Wait(3000)
		lobbyMenu.SettingsColumn:FilterSettings(function(x)
			return x:Label() == "UIMenuItem"
		end)
		Citizen.Wait(3000)
		lobbyMenu.SettingsColumn:ResetFilter()
		]]
		Citizen.Wait(50)
		menuLoaded = true
		Citizen.Wait(50)
		firstLoad = false
	end
end

AddEventHandler("ArenaLobby:lobbymenu:SetHeaderMenu", function(data)
	while not menuLoaded do
		Citizen.Wait(0)
	end

	local isChange = false
	if #data ~= #DataSet.HeaderMenu then
		isChange = true
	else
		for k,v in pairs(data) do
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

		--[[
		if data.SideTop then
			lobbyMenu.SideTop = data.SideTop
		end
		
		if data.SideMid then
			lobbyMenu.SideMid = data.SideMid
		end
		
		if data.SideBot then
			lobbyMenu.SideBot = data.SideBot
		end
		]]

		if data.Col1 then
			LobbyMenu.listCol[1]._label = data.Col1
		end

		if data.Col2 then
			LobbyMenu.listCol[2]._label = data.Col2
		end

		if data.Col3 then
			LobbyMenu.listCol[3]._label = data.Col3
		end

		if data.ColColor1 then
			LobbyMenu.listCol[1]._color = SColor.FromHudColor(data.ColColor1)
		end

		if data.ColColor2 then
			LobbyMenu.listCol[2]._color = SColor.FromHudColor(data.ColColor2)
		end

		if data.ColColor3 then
			LobbyMenu.listCol[3]._color = SColor.FromHudColor(data.ColColor3)
		end

		DataSet.HeaderMenu = data
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:SetPlayerList", function(data)
	while not menuLoaded do
		Citizen.Wait(0)
	end

	local isChange = false
	if #data ~= #DataSet.PlayerList then
		isChange = true
	else
		for k,v in pairs(data) do
			if not DataSet.PlayerList[k] then
				isChange = true
				break
			else
				for kk,vv in pairs(v) do
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
		ColumnCallbackFunction[2] = {}
		LobbyMenu.PlayersColumn:Clear()
		
		local HostSource = -1
		if ArenaAPI:IsPlayerInAnyArena() then
			HostSource = ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).ownersource
		end

		for k, v in pairs(data) do
			if HostSource == v.source then
				v.sortOrder = 1
			elseif v.LobbyBadgeIcon == 66 then -- JoinAsSpectatorMode
				v.sortOrder = 3
			elseif v.ped then
				v.sortOrder = 2
			else
				v.sortOrder = 4
			end
		end
		table.sort(data, function(a, b)
			return a.sortOrder < b.sortOrder
		end)

		for k, v in pairs(data) do
			local Status = v.Status
			local Colours = v.Colours

			if GetPlayerFromServerId(v.source) ~= -1 then
				v.MP0_STAMINA = Player(v.source).state.ArenaLobby_MP0_STAMINA or 0
				v.MP0_STRENGTH = Player(v.source).state.ArenaLobby_MP0_STRENGTH or 0
				v.MP0_LUNG_CAPACITY = Player(v.source).state.ArenaLobby_MP0_LUNG_CAPACITY or 0
				v.MP0_SHOOTING_ABILITY = Player(v.source).state.ArenaLobby_MP0_SHOOTING_ABILITY or 0
				v.MP0_DRIVING_ABILITY = Player(v.source).state.ArenaLobby_MP0_WHEELIE_ABILITY or 0
				v.MP0_WHEELIE_ABILITY = Player(v.source).state.ArenaLobby_MP0_WHEELIE_ABILITY or 0
				v.MP0_FLYING_ABILITY = Player(v.source).state.ArenaLobby_MP0_FLYING_ABILITY or 0
				v.MP0_STEALTH_ABILITY = Player(v.source).state.ArenaLobby_MP0_STEALTH_ABILITY or 0
				v.MPPLY_KILLS_PLAYERS = Player(v.source).state.ArenaLobby_MP0_HIGHEST_MENTAL_STATE or 0
			else
				v.MP0_STAMINA = GetRandomIntInRange(10, 100)
				v.MP0_STRENGTH = GetRandomIntInRange(10, 100)
				v.MP0_LUNG_CAPACITY = GetRandomIntInRange(10, 100)
				v.MP0_SHOOTING_ABILITY = GetRandomIntInRange(10, 100)
				v.MP0_DRIVING_ABILITY = GetRandomIntInRange(10, 100)
				v.MP0_WHEELIE_ABILITY = GetRandomIntInRange(10, 100)
				v.MP0_FLYING_ABILITY = GetRandomIntInRange(10, 100)
				v.MP0_STEALTH_ABILITY = GetRandomIntInRange(10, 100)
				v.MPPLY_KILLS_PLAYERS = GetRandomIntInRange(10, 100)
			end
			v.HasPlane = IsPedInAnyPlane(v.ped)
			v.HasHeli = IsPedInAnyHeli(v.ped)
			v.HasBoat = IsPedInAnyBoat(v.ped)
			v.HasVehicle = IsPedInAnyVehicle(v.ped, false)

			local LobbyBadge = 120
			if v.LobbyBadgeIcon then
				LobbyBadge = v.LobbyBadgeIcon
			elseif GetPlayerFromServerId(v.source) ~= -1 then
				if not Player(v.source).state.ArenaLobby_IsUsingKeyboard then
					LobbyBadge = LobbyBadgeIcon.IS_CONSOLE_PLAYER
				end
			end

			local crew = CrewTag.New(v.CrewTag, true, false, CrewHierarchy.Leader, SColor.HUD_Green)
			local friend = FriendItem.New(v.name, SColor.FromHudColor(Colours), true, v.rowColor, Status, crew)
			
			friend.ClonePed = v.ped
			local panel = PlayerStatsPanel.New(v.name, SColor.FromHudColor(v.rowColor or 158))
			panel:HasPlane(v.HasPlane)
			panel:HasHeli(v.HasHeli)
			panel:HasBoat(v.HasBoat)
			panel:HasVehicle(v.HasVehicle)
			panel.RankInfo:RankLevel(v.lev)
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
				panel:Description("My name is " .. v.name)
				friend:Enabled(true)
				friend:SetLeftIcon(LobbyBadge, false)
			else
				panel:Description("Empty")
				friend:SetLeftIcon(0, false)
				friend:SetRightIcon(0, false)
				friend:Enabled(false)
			end

			LobbyMenu.PlayersColumn:AddPlayer(friend)

			if v.callbackFunction then
				ColumnCallbackFunction[2][#LobbyMenu.PlayersColumn.Items] = v.callbackFunction
			end
		end

		LobbyMenu.PlayersColumn:refreshColumn()
		DataSet.PlayerList = table.deepcopy(data)
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:SetInfo", function(data)
	while not menuLoaded do
		Citizen.Wait(0)
	end

	local isChange = false
	if #data ~= #DataSet.Info then
		isChange = true
	else
		for k,v in pairs(data) do
			if not DataSet.Info[k] then
				isChange = true
				break
			else
				for kk,vv in pairs(v) do
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
		for i=1, #LobbyMenu.MissionPanel.Items do
			LobbyMenu.MissionPanel:RemoveItem(#LobbyMenu.MissionPanel.Items)
		end

		for k,v in pairs(data) do
			local detailItem = UIMenuFreemodeDetailsItem.New(v.LeftLabel, v.RightLabel, false, v.BadgeStyle, v.Colours)
			LobbyMenu.MissionPanel:AddItem(detailItem)
		end

		DataSet.Info = table.deepcopy(data)
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:SetInfoTitle", function(data)
	while not menuLoaded do
		Citizen.Wait(0)
	end

	local isChange = false
	if #data ~= #DataSet.InfoTitle then
		isChange = true
	else
		for k,v in pairs(data) do
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
			LobbyMenu.MissionPanel:Title(data.Title)
		end

		if data.tex and data.txd then
			LobbyMenu.MissionPanel:UpdatePanelPicture(data.tex, data.txd)
		end
		DataSet.InfoTitle = data
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:SettingsColumn", function(data)
	while not menuLoaded do
		Citizen.Wait(0)
	end
	
	local isChange = false
	if #data ~= #DataSet.SettingsColumn then
		isChange = true
	else
		for k,v in pairs(data) do
			if not DataSet.SettingsColumn[k] then
				isChange = true
				break
			else
				for kk,vv in pairs(v) do
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
		ColumnCallbackFunction[1] = {}
		LobbyMenu.SettingsColumn:Clear()
		
		for k,v in pairs(data) do
			local item
			if v.type == "List" then
				item = UIMenuListItem.New(v.label, v.list, 0, v.dec, SColor.FromHudColor(v.mainColor or 0), SColor.FromHudColor(v.highlightColor or 0), SColor.FromHudColor(v.textColor or 0), SColor.FromHudColor(v.highlightedTextColor or 0))
			elseif v.type == "Checkbox" then
				item = UIMenuCheckboxItem.New(v.label, true, 1, v.dec)
			elseif v.type == "Slider" then
				item = UIMenuSliderItem.New(v.label, 100, 5, 50, false, v.dec)
			elseif v.type == "Progress" then
				item = UIMenuProgressItem.New(v.label, 10, 5, v.dec)
			else
				item = UIMenuItem.New(v.label, v.dec, SColor.FromHudColor(v.mainColor or 0), SColor.FromHudColor(v.highlightColor or 0), SColor.FromHudColor(v.textColor or 0), SColor.FromHudColor(v.highlightedTextColor or 0))
				if v.rightLabel then
					item:RightLabel(v.rightLabel)
				end
			end
			item:BlinkDescription(v.Blink)
			LobbyMenu.SettingsColumn:AddSettings(item)

			if v.callbackFunction then
				ColumnCallbackFunction[1][k] = v.callbackFunction
			end
		end

		LobbyMenu.SettingsColumn:refreshColumn()
		DataSet.SettingsColumn = data
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:MapPanel", function(data)
	while not menuLoaded or not LobbyMenu:Visible() do
		Citizen.Wait(0)
	end

	minimapLobbyEnabled = false
	LobbyMenu.Minimap:Enabled(false) -- Force refresh map position
	local button = InstructionalButton.New("Open/Close Map Panel", -1, 203, 203, -1)
	button.OnControlSelected = function(control)
		minimapLobbyEnabled = not minimapLobbyEnabled
		if minimapLobbyEnabled then
			LobbyMenu.Minimap.MinimapRoute.RouteColor = HudColours.HUD_COLOUR_YELLOW
			LobbyMenu.Minimap.MinimapRoute.MapThickness = 17
			for k,v in pairs(data) do
				local blipColor = 5
				if v.path == 2 then
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
					LobbyMenu.Minimap.MinimapRoute.StartPoint = MinimapRaceCheckpoint.New(309, vector3(v.x, v.y, v.z), blipColor, 0.8)
				elseif k == #data then
					LobbyMenu.Minimap.MinimapRoute.EndPoint = MinimapRaceCheckpoint.New(38, vector3(v.x, v.y, v.z), blipColor, 0.8)
				else
					table.insert(LobbyMenu.Minimap.MinimapRoute.CheckPoints, MinimapRaceCheckpoint.New(271, vector3(v.x, v.y, v.z), 5, 0.8))
				end
			end
		else
			LobbyMenu.Minimap:ClearMinimap()
		end
		LobbyMenu.Minimap:Enabled(minimapLobbyEnabled)
	end
	
	table.insert(LobbyMenu.InstructionalButtons, button)
end)

AddEventHandler("ArenaLobby:lobbymenu:Show", function(focusColume, canClose, onClose)
	CreateLobbyMenu()

	if LobbyMenu:Visible() then
		LobbyMenu:Visible(false)
	end
	while firstLoad or IsDisabledControlPressed(0, 199) or IsDisabledControlPressed(0, 200) or IsPauseMenuRestarting() or IsFrontendFading() or IsPauseMenuActive() do
		SetPauseMenuActive(false)
		SetFrontendActive(false)
		Citizen.Wait(0)
	end

	LobbyMenu.InstructionalButtons = {}
	table.insert(LobbyMenu.InstructionalButtons, InstructionalButton.New(GetLabelText("HUD_INPUT2"), -1, 191, 191, -1))
	if canClose then
		table.insert(LobbyMenu.InstructionalButtons, InstructionalButton.New(GetLabelText("HUD_INPUT3"), -1, 194, 194, -1))
	end
	table.insert(LobbyMenu.InstructionalButtons, InstructionalButton.New(GetLabelText("HUD_INPUT8"), -1, -1, -1, "INPUTGROUP_FRONTEND_DPAD_ALL"))

	currentSelectId = 1
	currentColumnId = 1
	LobbyMenu:CanPlayerCloseMenu(canClose)
	LobbyMenu:Visible(true)
	Citizen.SetTimeout(50, function()
		LobbyMenu:updateFocus(focusColume, false)
	end)

	while LobbyMenu:Visible() do
		if IsDisabledControlJustPressed(2, 201) then
			if ColumnCallbackFunction[currentColumnId][currentSelectId] then
				ColumnCallbackFunction[currentColumnId][currentSelectId]()
			end

			if ArenaAPI:IsPlayerInAnyArena() and ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).ownersource == GetPlayerServerId(PlayerId()) then
				if currentColumnId == 2 and DataSet.PlayerList[currentSelectId] and DataSet.PlayerList[currentSelectId].ped then
					LobbyMenu:Visible(false)

					while IsPauseMenuRestarting() or IsFrontendFading() or IsPauseMenuActive() do
						Citizen.Wait(0)
					end

					local settingList = {}

					table.insert(settingList, {
						label = "Back",
						dec = "",
						callbackFunction = function()
							TriggerEvent("ArenaLobby:playermenu:Hide")
						end,
					})

					if ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).ownersource ~= DataSet.PlayerList[currentSelectId].source then
						table.insert(settingList, {
							label = "Kick",
							dec = "Kick player from current lobby.",
							mainColor = 8,
							highlightColor = 6,
							textColor = 0,
							highlightedTextColor = 0,
							Blink = true,
							callbackFunction = function()
								PlaySoundFrontend(-1, "MP_IDLE_KICK", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
								TriggerServerEvent("ArenaLobby:lobbymenu:KickPlayer", DataSet.PlayerList[currentSelectId].source)
							end,
						})
					end
					
					TriggerEvent("ArenaLobby:playermenu:SettingsColumn", settingList)
					TriggerEvent("ArenaLobby:playermenu:SetInfo", DataSet.Info)
					TriggerEvent("ArenaLobby:playermenu:SetInfoTitle", {
						Title = LobbyMenu.MissionPanel._title,
						tex = LobbyMenu.MissionPanel.TextureDict,
						txd = LobbyMenu.MissionPanel.TextureName,
					})

					TriggerEvent("ArenaLobby:playermenu:SetHeaderMenu", {
						SideTop = LobbyMenu.SideTop,
						SideMid = LobbyMenu.SideMid,
						SideBot = LobbyMenu.SideBot,
						ColColor1 = LobbyMenu.listCol[1]._color,
						ColColor2 = LobbyMenu.listCol[2]._color,
						ColColor3 = LobbyMenu.listCol[3]._color,
					})

					TriggerEvent("ArenaLobby:playermenu:SetPlayerList", DataSet.PlayerList[currentSelectId], LobbyMenu.MissionPanel.TextureDict, LobbyMenu.MissionPanel.TextureName)

					TriggerEvent("ArenaLobby:playermenu:Show", function()
						TriggerEvent("ArenaLobby:lobbymenu:Show", focusColume, true)
					end)
				end
			end
		end

		Citizen.Wait(0)
	end

	if onClose then
		while IsPauseMenuRestarting() or IsFrontendFading() or IsPauseMenuActive() do
			Citizen.Wait(0)
		end
		onClose()
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:Hide", function()
	if LobbyMenu then
		LobbyMenu:Visible(false)
	end
end)

RegisterNetEvent("ArenaLobby:lobbymenu:leaveLobby")
AddEventHandler("ArenaLobby:lobbymenu:leaveLobby", function()
	ExecuteCommand("minigame leave")
	if LobbyMenu then
		LobbyMenu:Visible(false)
	end
end)
