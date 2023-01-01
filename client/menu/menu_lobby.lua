local pool = MenuPool.New()
lobbyMenu = nil

local currentColumnId = 1
local currentSelectId = 1

local ColumnCallbackFunction = {}
ColumnCallbackFunction[1] = {}
ColumnCallbackFunction[2] = {}

CreateThread(function()
	if not lobbyMenu then
		lobbyMenu = MainView.New("name", "dec", "", "", "")
		local columns = {
			SettingsListColumn.New("COLUMN SETTINGS", Colours.HUD_COLOUR_RED),
			PlayerListColumn.New("COLUMN PLAYERS", Colours.HUD_COLOUR_ORANGE),
			MissionDetailsPanel.New("COLUMN INFO PANEL", Colours.HUD_COLOUR_GREEN),
		}
		lobbyMenu:SetupColumns(columns)
		
		RequestStreamedTextureDictC("ArenaLobby")
		local mugshot = RegisterPedheadshot(PlayerPedId())
		local timer = GetGameTimer()
		while not IsPedheadshotReady(mugshot) and GetGameTimer() - timer < 1000 do
			Citizen.Wait(0)
		end
		local headshot = GetPedheadshotTxdString(mugshot)
		AddReplaceTexture("ArenaLobby", "LobbyHeadshot", headshot, headshot)
		lobbyMenu:HeaderPicture("ArenaLobby", "LobbyHeadshot") -- lobbyMenu:CrewPicture used to add a picture on the left of the HeaderPicture
		UnregisterPedheadshot(mugshot) -- call it right after adding the menu.. this way the txd will be loaded correctly by the scaleform.. 
		
		pool:AddPauseMenu(lobbyMenu)
		lobbyMenu:CanPlayerCloseMenu(true)
		
		local item = UIMenuItem.New("UIMenuItem", "UIMenuItem description")
		lobbyMenu.SettingsColumn:AddSettings(item)
		
		lobbyMenu.MissionPanel:UpdatePanelPicture("scaleformui", "lobby_panelbackground")
		lobbyMenu.MissionPanel:Title("ScaleformUI - Title")
		
		local detailItem = UIMenuFreemodeDetailsItem.New("Left Label", "Right Label", false, BadgeStyle.BRIEFCASE, Colours.HUD_COLOUR_FREEMODE)
		lobbyMenu.MissionPanel:AddItem(detailItem)
		
		local friend = FriendItem.New("", 0, 116, 0, 0, "")
		lobbyMenu.PlayersColumn:AddPlayer(friend)

		lobbyMenu.SettingsColumn.OnIndexChanged = function(idx)
			currentSelectId = idx
			currentColumnId = 1
		end

		lobbyMenu.PlayersColumn.OnIndexChanged = function(idx)
			currentSelectId = idx
			currentColumnId = 2
		end
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:SetHeaderMenu", function(data)
	if data.Title then
		lobbyMenu.Title = data.Title
	end
	
	if data.Subtitle then
		lobbyMenu.Subtitle = data.Subtitle
	end
	
	if data.SideTop then
		lobbyMenu.SideTop = data.SideTop
	end
	
	if data.SideMid then
		lobbyMenu.SideMid = data.SideMid
	end
	
	if data.SideBot then
		lobbyMenu.SideBot = data.SideBot
	end
	
	if data.Col1 then
		lobbyMenu._listCol[1]._label = data.Col1
	end
	
	if data.Col2 then
		lobbyMenu._listCol[2]._label = data.Col2
	end
	
	if data.Col3 then
		lobbyMenu._listCol[3]._label = data.Col3
	end
	
	if data.ColColor1 then
		lobbyMenu._listCol[1]._color = data.ColColor1
	end
	
	if data.ColColor2 then
		lobbyMenu._listCol[2]._color = data.ColColor2
	end
	
	if data.ColColor3 then
		lobbyMenu._listCol[3]._color = data.ColColor3
	end
end)

local ClonePedData = {}
local DataPlayerList = {}
AddEventHandler("ArenaLobby:lobbymenu:SetPlayerList", function(data)
	local HostSource = ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).ownersource
	ColumnCallbackFunction[2] = {}
	
	for i=1, #lobbyMenu.PlayersColumn.Items do
		lobbyMenu.PlayersColumn:RemovePlayer(#lobbyMenu.PlayersColumn.Items)
	end
	
	for k,v in pairs(data) do
		if HostSource == v.source then
			v.sortOrder = 1
		elseif v.ped then
			v.sortOrder = 2
		else
			v.sortOrder = 3
		end
	end
	table.sort(data, function(a,b)
		return a.sortOrder < b.sortOrder
	end)


	local playerPed = PlayerPedId()
	for k,v in pairs(data) do
		if HostSource == v.source then
			v.Status = "HOST"
			v.Colours = 116
		end
		
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
		v.HasVehicle = IsPedInAnyVehicle(v.ped)
			

		v.LobbyBadge = 120
		if v.LobbyBadgeIcon then
			v.LobbyBadge = v.LobbyBadgeIcon
		elseif GetPlayerFromServerId(v.source) ~= -1 then
			if not Player(v.source).state.ArenaLobby_IsUsingKeyboard then
				v.LobbyBadge = LobbyBadgeIcon.IS_CONSOLE_PLAYER
			end
		end
		
		local friend = FriendItem.New(v.name, v.Colours, v.rowColor, v.lev, v.Status, v.CrewTag)
		if v.ped then
			if v.ped ~= playerPed and (not ClonePedData[v.name] or not DoesEntityExist(ClonePedData[v.name])) then
				ClonePedData[v.name] = ClonePed(v.ped, false, true, false)
				SetEntityCoords(ClonePedData[v.name], 0.0, 0.0, 0.0)
				FreezeEntityPosition(ClonePedData[v.name], true)
			end
			friend:SetLeftIcon(v.LobbyBadge, false)
			friend:AddPedToPauseMenu((ClonePedData[v.name] or PlayerPedId())) -- defaulted to 0 if you set it to nil / 0 the ped will be removed from the pause menu
			local panel = PlayerStatsPanel.New(v.name, v.rowColor)
			panel:Description("My name is "..v.name)
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
			friend:Enabled(true)
		else
			friend._iconR = 0
			friend._itemColor = 158
			friend:Enabled(false)
		end
		lobbyMenu.PlayersColumn:AddPlayer(friend)

		if v.callbackFunction then
			ColumnCallbackFunction[2][#lobbyMenu.PlayersColumn.Items] = v.callbackFunction
		end
	end
	
	DataPlayerList = data
end)

local DataSetInfo = {}
AddEventHandler("ArenaLobby:lobbymenu:SetInfo", function(data)
	for i=1, #lobbyMenu.MissionPanel.Items do
		lobbyMenu.MissionPanel:RemoveItem(#lobbyMenu.MissionPanel.Items)
	end
	for k,v in pairs(data) do
		local detailItem = UIMenuFreemodeDetailsItem.New(v.LeftLabel, v.RightLabel, false, v.BadgeStyle, v.Colours)
		lobbyMenu.MissionPanel:AddItem(detailItem)
	end
	
	DataSetInfo = data
end)

AddEventHandler("ArenaLobby:lobbymenu:SetInfoTitle", function(data)
	if data.Title then
		lobbyMenu.MissionPanel:Title(data.Title)
	end
	
	if data.tex and data.txd then
		lobbyMenu.MissionPanel:UpdatePanelPicture(data.tex, data.txd)
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:SettingsColumn", function(data)
	ColumnCallbackFunction[1] = {}
	
	for i=1, #lobbyMenu.SettingsColumn.Items do
		lobbyMenu.SettingsColumn.Items[#lobbyMenu.SettingsColumn.Items] = nil
	end
	
	for k,v in pairs(data) do
		local item
		if v.type == "List" then
			item = UIMenuListItem.New(v.label, v.list, 0, v.dec, v.mainColor, v.highlightColor, v.textColor, v.highlightedTextColor)
		elseif v.type == "Checkbox" then
			item = UIMenuCheckboxItem.New(v.label, true, 1, v.dec)
		elseif v.type == "Slider" then
			item = UIMenuSliderItem.New(v.label, 100, 5, 50, false, v.dec)
		elseif v.type == "Progress" then
			item = UIMenuProgressItem.New(v.label, 10, 5, v.dec)
		else
			item = UIMenuItem.New(v.label, v.dec, v.mainColor, v.highlightColor, v.textColor, v.highlightedTextColor)
			if v.rightLabel then
				item:RightLabel(rightLabel)
			end
		end
		lobbyMenu.SettingsColumn.Items[k] = item
		item:BlinkDescription(v.Blink)
		
		if v.callbackFunction then
			ColumnCallbackFunction[1][k] = v.callbackFunction
		end
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:UpdateSettingsColumn", function(index, data)
	ColumnCallbackFunction[1][index] = nil
	
	local item
	if data.type == "List" then
		item = UIMenuListItem.New(data.label, data.list, 0, data.dec)
	elseif data.type == "Checkbox" then
		item = UIMenuCheckboxItem.New(data.label, true, 1, data.dec)
	elseif data.type == "Slider" then
		item = UIMenuSliderItem.New(data.label, 100, 5, 50, false, data.dec)
	elseif data.type == "Progress" then
		item = UIMenuProgressItem.New(data.label, 10, 5, data.dec)
	else
		item = UIMenuItem.New(data.label, data.dec, data.mainColor, data.highlightColor, data.textColor, data.highlightedTextColor)
	end
	lobbyMenu.SettingsColumn.Items[index] = item
	item:BlinkDescription(data.Blink)
	
	if data.callbackFunction then
		ColumnCallbackFunction[1][index] = data.callbackFunction
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:Show", function(FocusLevel, canclose, onClose)
	while IsDisabledControlPressed(0, 199) or IsDisabledControlPressed(0, 200) do
		Wait(0)
	end
	
	if lobbyMenu:Visible() then
		lobbyMenu:Visible(false)
		-- Wait(100)
		while IsPauseMenuRestarting() or IsFrontendFading() or IsPauseMenuActive() do
			Wait(0)
		end
	end
	
	currentSelectId = 1
	currentColumnId = 1
	lobbyMenu:CanPlayerCloseMenu(canclose)
	lobbyMenu:Visible(true)
	lobbyMenu:FocusLevel(FocusLevel)
	ScaleformUI.Scaleforms.InstructionalButtons:Enabled(false)
	
	local instructional_buttons = Scaleform.Request("instructional_buttons")
	instructional_buttons:CallFunction("CLEAR_ALL")
	local buttonsID = 0
	instructional_buttons:CallFunction("SET_DATA_SLOT", buttonsID, GetControlInstructionalButton(1, 191, true), GetLabelText("HUD_INPUT2"))
	buttonsID += 1
	if canclose then
		instructional_buttons:CallFunction("SET_DATA_SLOT", buttonsID, GetControlInstructionalButton(1, 194, true), GetLabelText("HUD_INPUT3"))
		buttonsID += 1
	end
	instructional_buttons:CallFunction("SET_DATA_SLOT", buttonsID, "~INPUTGROUP_FRONTEND_DPAD_ALL~", GetLabelText("HUD_INPUT8"))
	buttonsID += 1
	instructional_buttons:CallFunction("SET_BACKGROUND_COLOUR", 0, 0, 0, 80)
	instructional_buttons:CallFunction("DRAW_INSTRUCTIONAL_BUTTONS")
		
	while lobbyMenu:Visible() do
		SetScriptGfxDrawBehindPausemenu(true)
		instructional_buttons:Draw2D()
		
		if IsDisabledControlJustPressed(0, 201) then
			if ColumnCallbackFunction[currentColumnId][currentSelectId] then
				ColumnCallbackFunction[currentColumnId][currentSelectId]()
			end
			
			if ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).ownersource == GetPlayerServerId(PlayerId()) then
				if currentColumnId == 2 and DataPlayerList[currentSelectId] and DataPlayerList[currentSelectId].ped then
					lobbyMenu:Visible(false)
					-- Wait(100)
					while IsPauseMenuRestarting() or IsFrontendFading() or IsPauseMenuActive() do
						Wait(0)
					end
					
					local settingList = {}
					if ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).ownersource == DataPlayerList[currentSelectId].source then
						table.insert(settingList, {
							label = "Back",
							dec = "",
							callbackFunction = function()
								playerMenu:Visible(false)
							end,
						})
					else
						table.insert(settingList, {
							label = "Kick",
							dec = "Kick player from current lobby.",
							callbackFunction = function()
								PlaySoundFrontend(-1, "MP_IDLE_KICK", "HUD_FRONTEND_DEFAULT_SOUNDSET")
								TriggerServerEvent("ArenaLobby:lobbymenu:KickPlayer", DataPlayerList[currentSelectId].source)
							end,
							mainColor = 8,
							highlightColor = 6,
							textColor = 0,
							highlightedTextColor = 0,
							Blink = true,
						})
					end
					TriggerEvent("ArenaLobby:playermenu:SettingsColumn", settingList)
					TriggerEvent("ArenaLobby:playermenu:SetInfo", DataSetInfo)
					TriggerEvent("ArenaLobby:playermenu:SetInfoTitle", {
						Title = lobbyMenu.MissionPanel._title,
						tex = lobbyMenu.MissionPanel.TextureDict,
						txd = lobbyMenu.MissionPanel.TextureName,
					})
					TriggerEvent("ArenaLobby:playermenu:SetHeaderMenu", {
						SideTop = lobbyMenu.SideTop,
						SideMid = lobbyMenu.SideMid,
						SideBot = lobbyMenu.SideBot,
						ColColor1 = lobbyMenu._listCol[1]._color,
						ColColor2 = lobbyMenu._listCol[2]._color,
						ColColor3 = lobbyMenu._listCol[3]._color,
					})
					TriggerEvent("ArenaLobby:playermenu:SetPlayerList", DataPlayerList[currentSelectId], lobbyMenu.MissionPanel.TextureDict, lobbyMenu.MissionPanel.TextureName)
					
					TriggerEvent("ArenaLobby:playermenu:Show", 2, true, function()
						TriggerEvent("ArenaLobby:lobbymenu:Show", 1, true)
					end)
				end
			end
		end
		Wait(0)
	end
	instructional_buttons:Dispose()
	
	if onClose then
		-- Wait(100)
		while IsPauseMenuRestarting() or IsFrontendFading() or IsPauseMenuActive() do
			Wait(0)
		end
		onClose()
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:Hide", function()
	if lobbyMenu:Visible() then
		lobbyMenu:Visible(false)
	end
end)

RegisterNetEvent("ArenaLobby:lobbymenu:leaveLobby")
AddEventHandler("ArenaLobby:lobbymenu:leaveLobby", function()
	ExecuteCommand("minigame leave")
	if lobbyMenu:Visible() then
		lobbyMenu:Visible(false)
	end
end)