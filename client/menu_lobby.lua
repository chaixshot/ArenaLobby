local pool = MenuPool.New()
local lobbyMenu
local currentSelectId = 1

CreateThread(function()
	if not lobbyMenu then
		lobbyMenu = MainView.New("name", "dec", "", "", "")
		local columns = {
			SettingsListColumn.New("COLUMN SETTINGS", Colours.HUD_COLOUR_RED),
			PlayerListColumn.New("COLUMN PLAYERS", Colours.HUD_COLOUR_ORANGE),
			MissionDetailsPanel.New("COLUMN INFO PANEL", Colours.HUD_COLOUR_GREEN),
		}
		lobbyMenu:SetupColumns(columns)
		
		local mugshot = RegisterPedheadshot(PlayerPedId())
		local timer = GetGameTimer()
		while not IsPedheadshotReady(mugshot) and GetGameTimer() - timer < 1000 do
			Citizen.Wait(0)
		end
		local headshot = GetPedheadshotTxdString(mugshot)
		lobbyMenu:HeaderPicture(headshot, headshot) 	-- lobbyMenu:CrewPicture used to add a picture on the left of the HeaderPicture
		UnregisterPedheadshot(mugshot) -- call it right after adding the menu.. this way the txd will be loaded correctly by the scaleform.. 
		
		pool:AddPauseMenu(lobbyMenu)
		lobbyMenu:CanPlayerCloseMenu(true)
		
		for i=1, 10 do
			local item = UIMenuItem.New("UIMenuItem", "UIMenuItem description")
			lobbyMenu.SettingsColumn:AddSettings(item)
		end
		
		lobbyMenu.MissionPanel:UpdatePanelPicture("scaleformui", "lobby_panelbackground")
		lobbyMenu.MissionPanel:Title("ScaleformUI - Title")
		
		local detailItem = UIMenuFreemodeDetailsItem.New("Left Label", "Right Label", false, BadgeStyle.BRIEFCASE, Colours.HUD_COLOUR_FREEMODE)
		lobbyMenu.MissionPanel:AddItem(detailItem)
		
		local friend = FriendItem.New("", 0, 116, 0, 0, "")
		lobbyMenu.PlayersColumn:AddPlayer(friend)

		lobbyMenu.SettingsColumn.OnIndexChanged = function(idx)
			currentSelectId = idx
		end

		lobbyMenu.PlayersColumn.OnIndexChanged = function(idx)
			currentSelectId = 0
		end
		
		local buttons = {
		InstructionalButton.New(GetLabelText("HUD_INPUT3"), -1, 177, 177, -1),
		InstructionalButton.New("Scroll text", 0, 2, -1, -1),
		InstructionalButton.New("Scroll text", 1, -1, -1, "INPUTGROUP_CURSOR_SCROLL")
		-- cannot make difference between controller / keyboard here in 1 line because we are using the InputGroup for keyboard
	}
	ScaleformUI.Scaleforms.InstructionalButtons:SetInstructionalButtons(buttons)
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
AddEventHandler("ArenaLobby:lobbymenu:SetPlayerList", function(data)
	for i=1, #lobbyMenu.PlayersColumn.Items do
		lobbyMenu.PlayersColumn:RemovePlayer(#lobbyMenu.PlayersColumn.Items)
	end
	
	local playerPed = PlayerPedId()
	for k,v in pairs(data) do
		local friend = FriendItem.New(v.name, v.Colours, 116, v.lev, v.Status, v.CrewTag)
		friend:SetLeftIcon(v.LobbyBadgeIcon, false)
		if v.ped then
			if v.ped ~= playerPed and (not ClonePedData[v.name] or not DoesEntityExist(ClonePedData[v.name])) then
				ClonePedData[v.name] = ClonePed(v.ped, false, true, false)
				SetEntityCoords(ClonePedData[v.name], 0.0, 0.0, 0.0)
				FreezeEntityPosition(ClonePedData[v.name], true)
			end
			friend:AddPedToPauseMenu((ClonePedData[v.name] or PlayerPedId())) -- defaulted to 0 if you set it to nil / 0 the ped will be removed from the pause menu
			local panel = PlayerStatsPanel.New(v.name, 116)
			panel:Description("My name is "..v.name)
			panel:HasPlane(v.HasPlane)
			panel:HasHeli(v.HasHeli)
			panel:HasBoat(v.HasBoat)
			panel:HasVehicle(v.HasVehicle)
			panel.RankInfo:RankLevel(v.lev)
			panel.RankInfo:LowLabel("This is the low label")
			-- panel.RankInfo:MidLabel("This is the middle label")
			-- panel.RankInfo:UpLabel("This is the upper label")
			-- panel:AddStat(PlayerStatsPanelStatItem.New("Statistic 1", "Description 1", GetRandomIntInRange(30, 150)))
			-- panel:AddStat(PlayerStatsPanelStatItem.New("Statistic 2", "Description 2", GetRandomIntInRange(30, 150)))
			-- panel:AddStat(PlayerStatsPanelStatItem.New("Statistic 3", "Description 3", GetRandomIntInRange(30, 150)))
			-- panel:AddStat(PlayerStatsPanelStatItem.New("Statistic 4", "Description 4", GetRandomIntInRange(30, 150)))
			-- panel:AddStat(PlayerStatsPanelStatItem.New("Statistic 5", "Description 5", GetRandomIntInRange(30, 150)))
			friend:AddPanel(panel)
		else
			friend._iconR = 0
			friend._itemColor = 70
			friend:Enabled(false)
		end
		lobbyMenu.PlayersColumn:AddPlayer(friend)
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:SetInfo", function(data)
	-- print(#lobbyMenu.MissionPanel.Items)
	for i=1, #lobbyMenu.MissionPanel.Items do
		lobbyMenu.MissionPanel:RemoveItem(#lobbyMenu.MissionPanel.Items)
	end
	for k,v in pairs(data) do
		local detailItem = UIMenuFreemodeDetailsItem.New(v.LeftLabel, v.RightLabel, false, v.BadgeStyle, v.Colours)
		lobbyMenu.MissionPanel:AddItem(detailItem)
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:SetInfoTitle", function(data)
	if data.Title then
		lobbyMenu.MissionPanel:Title(data.Title)
	end
	
	if data.tex and data.txd then
		lobbyMenu.MissionPanel:UpdatePanelPicture(data.tex, data.txd)
	end
end)

local ColumnCallbackEvent = {}
AddEventHandler("ArenaLobby:lobbymenu:SettingsColumn", function(data)
	for k,v in pairs(data) do
		local item
		if v.type == "List" then
			item = UIMenuListItem.New(v.label, v.list, 0, v.dec)
		elseif v.type == "Checkbox" then
			item = UIMenuCheckboxItem.New(v.label, true, 1, v.dec)
		elseif v.type == "Slider" then
			item = UIMenuSliderItem.New(v.label, 100, 5, 50, false, v.dec)
		elseif v.type == "Progress" then
			item = UIMenuProgressItem.New(v.label, 10, 5, v.dec)
		else
			item = UIMenuItem.New(v.label, v.dec)
		end
		item:TextColor(v.color or 0)
		lobbyMenu.SettingsColumn.Items[k] = item
		item:BlinkDescription(v.Blink)
		
		if v.callbackEvent then
			ColumnCallbackEvent[k] = v.callbackEvent
		end
	end
	
	for i=#data+1, 10 do
		local item = UIMenuItem.New("", "")
		item:Enabled(false)
		lobbyMenu.SettingsColumn.Items[i] = item
		
		ColumnCallbackEvent[i] = nil
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:Show", function(canclose)
	while IsDisabledControlPressed(0, 199) or IsDisabledControlPressed(0, 200) do
		Wait(0)
	end
	currentSelectId = 1
	lobbyMenu:CanPlayerCloseMenu(canclose == nil and true or false)
	lobbyMenu:Visible(true)
	
	while pool:IsAnyMenuOpen() do
		if IsDisabledControlJustPressed(0, 201) then
			if ColumnCallbackEvent[currentSelectId] then
				TriggerEvent(ColumnCallbackEvent[currentSelectId])
			end
		end
		Wait(0)
	end
end)

AddEventHandler("ArenaLobby:lobbymenu:Hide", function()
	lobbyMenu:Visible(false)
end)