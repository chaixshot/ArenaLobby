local PlayerMenu
local settingsPanel = {}
local playersPanel = {}
local missionsPanel = {}
local defaultSubtitle = "Template by H@mer"

local firstLoad = true

local function CreatePlayerMenuMenu()
	if not PlayerMenu then
		settingsPanel = SettingsListColumn.New("COLUMN SETTINGS", 20)
		playersPanel = PlayerListColumn.New("COLUMN PLAYERS", 19)
		missionsPanel = MissionDetailsPanel.New("COLUMN INFO PANEL", 20)

		PlayerMenu = MainView.New("Lobby Menu", defaultSubtitle, "", "", "")
		PlayerMenu:SetupLeftColumn(settingsPanel)
		PlayerMenu:SetupCenterColumn(playersPanel)
		PlayerMenu:SetupRightColumn(missionsPanel)
		PlayerMenu:CanPlayerCloseMenu(true)

		local item = UIMenuItem.New("UIMenuItem", "UIMenuItem description")
		item:BlinkDescription(true)
		settingsPanel:AddSettings(item)

		missionsPanel:UpdatePanelPicture("scaleformui", "lobby_panelbackground")
		missionsPanel:Title("ScaleformUI - Title")

		local detailItem = UIMenuFreemodeDetailsItem.New("Left Label", "Right Label", false, BadgeStyle.BRIEFCASE, SColor.HUD_Freemode)
		missionsPanel:AddItem(detailItem)

		Citizen.Wait(100)
		firstLoad = false
	end
end

---Can't change while PlayerMenu already visible
AddEventHandler("ArenaLobby:playermenu:SetHeaderMenu", function(data)
	while firstLoad do
		Citizen.Wait(0)
	end

	if data.Title then
		PlayerMenu.Title = data.Title
	end

	if data.Subtitle then
		PlayerMenu.Subtitle = data.Subtitle
	end

	--[[
	if data.SideTop then
		playerMenu.SideTop = data.SideTop
	end
	
	if data.SideMid then
		playerMenu.SideMid = data.SideMid
	end
	
	if data.SideBot then
		playerMenu.SideBot = data.SideBot
	end
	]]

	if data.Col1 then
		PlayerMenu.listCol[1]._label = data.Col1
	end

	if data.Col2 then
		PlayerMenu.listCol[2]._label = data.Col2
	end

	if data.Col3 then
		PlayerMenu.listCol[3]._label = data.Col3
	end

	settingsPanel._color = SColor.FromHudColor(HudColours.HUD_COLOUR_FREEMODE)
	playersPanel._color = SColor.FromHudColor(HudColours.HUD_COLOUR_FREEMODE)
	missionsPanel._color = SColor.FromHudColor(HudColours.HUD_COLOUR_FREEMODE)
end)

local ClonePedData = {}
AddEventHandler("ArenaLobby:playermenu:SetPlayerList", function(data)
	while firstLoad do
		Citizen.Wait(0)
	end
	if PlayerMenu:Visible() then
		Citizen.Wait(300)
	end

	playersPanel:Clear()

	PlayerMenu.Subtitle = data.name

	local LobbyBadge = BadgeStyle.BRAND_BANSHEE
	if data.LobbyBadgeIcon then
		LobbyBadge = data.LobbyBadgeIcon
	elseif GetPlayerFromServerId(data.source) ~= -1 then
		if not DecorGetBool(data.ped, "IsUsingKeyboard") then
			LobbyBadge = LobbyBadgeIcon.IS_CONSOLE_PLAYER
		end
	end

	if ArenaAPI:IsPlayerInAnyArena() then
		if data.source == ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).ownerSource then
			data.Status = "HOST"
			data.Colours = HudColours.HUD_COLOUR_FREEMODE
		end
	end

	local crew = CrewTag.New(data.CrewTag, true, false, CrewHierarchy.Leader, SColor.HUD_Green)
	local friend = FriendItem.New(data.name, SColor.FromHudColor(data.Colours), true, data.level, data.Status, crew)

	friend.ClonePed = data.ped
	friend:SetLeftIcon(LobbyBadge, false)
	-- friend:AddPedToPauseMenu(friend.ClonePed) -- defaulted to 0 if you set it to nil / 0 the ped will be removed from the pause menu
	local panel = PlayerStatsPanel.New(data.name, SColor.FromHudColor(data.rowColor or HudColours.HUD_COLOUR_VIDEO_EDITOR_AMBIENT))
	panel:Description("My name is "..data.name)
	panel:HasPlane(data.HasPlane)
	panel:HasHeli(data.HasHeli)
	panel:HasBoat(data.HasBoat)
	panel:HasVehicle(data.HasVehicle)
	panel.RankInfo:RankLevel(data.level)
	-- panel.RankInfo:LowLabel("This is the low label")
	-- panel.RankInfo:MidLabel("This is the middle label")
	-- panel.RankInfo:UpLabel("This is the upper label")
	panel:AddStat(PlayerStatsPanelStatItem.New("Stamina", GetSkillStaminaDescription(data.MP0_STAMINA), data.MP0_STAMINA))
	panel:AddStat(PlayerStatsPanelStatItem.New("Shooting", GetSkillShootingDescription(data.MP0_SHOOTING_ABILITY), data.MP0_SHOOTING_ABILITY))
	panel:AddStat(PlayerStatsPanelStatItem.New("Strength", GetSkillStrengthDescription(data.MP0_STRENGTH), data.MP0_STRENGTH))
	panel:AddStat(PlayerStatsPanelStatItem.New("Stealth", GetSkillStealthDescription(data.MP0_STEALTH_ABILITY), data.MP0_STEALTH_ABILITY))
	panel:AddStat(PlayerStatsPanelStatItem.New("Driving", GetSkillDrivingDescription(data.MP0_DRIVING_ABILITY), data.MP0_DRIVING_ABILITY))
	panel:AddStat(PlayerStatsPanelStatItem.New("Flying", GetSkillFlyingDescription(data.MP0_FLYING_ABILITY), data.MP0_FLYING_ABILITY))
	panel:AddStat(PlayerStatsPanelStatItem.New("Mental State", GetSkillMentalStateDescription(data.MPPLY_KILLS_PLAYERS), data.MPPLY_KILLS_PLAYERS))
	friend:AddPanel(panel)

	playersPanel:AddPlayer(friend)

	-- if PlayerMenu:Visible() then
	-- 	playersPanel:refreshColumn()
	-- end
end)

AddEventHandler("ArenaLobby:playermenu:SetInfo", function(data)
	while firstLoad do
		Citizen.Wait(0)
	end
	if PlayerMenu:Visible() then
		Citizen.Wait(300)
	end

	for i = 1, #missionsPanel.Items do
		missionsPanel:RemoveItem(#missionsPanel.Items)
	end

	for k, v in pairs(data) do
		local detailItem = UIMenuFreemodeDetailsItem.New(v.LeftLabel, v.RightLabel, false, v.BadgeStyle, v.Colours)
		missionsPanel:AddItem(detailItem)
	end
end)

AddEventHandler("ArenaLobby:playermenu:SetInfoTitle", function(data)
	while firstLoad do
		Citizen.Wait(0)
	end
	if PlayerMenu:Visible() then
		Citizen.Wait(300)
	end

	if data.Title then
		missionsPanel:Title(data.Title)
	end

	if data.tex and data.txd then
		missionsPanel:UpdatePanelPicture(data.tex, data.txd)
	end
end)

AddEventHandler("ArenaLobby:playermenu:SettingsColumn", function(data)
	while firstLoad do
		Citizen.Wait(0)
	end
	if PlayerMenu:Visible() then
		Citizen.Wait(300)
	end

	settingsPanel:Clear()

	for k, v in pairs(data) do
		local item
		if v.type == "List" then
			item = UIMenuListItem.New(v.label, v.list, 0, v.dec, SColor.FromHudColor(v.mainColor or HudColours.HUD_COLOUR_PURE_WHITE), SColor.FromHudColor(v.highlightColor or HudColours.HUD_COLOUR_PURE_WHITE), SColor.FromHudColor(v.textColor or HudColours.HUD_COLOUR_PURE_WHITE), SColor.FromHudColor(v.highlightedTextColor or HudColours.HUD_COLOUR_PURE_WHITE))
		elseif v.type == "Checkbox" then
			item = UIMenuCheckboxItem.New(v.label, true, 1, v.dec)
		elseif v.type == "Slider" then
			item = UIMenuSliderItem.New(v.label, 100, 5, 50, false, v.dec)
		elseif v.type == "Progress" then
			item = UIMenuProgressItem.New(v.label, 10, 5, v.dec)
		else
			item = UIMenuItem.New(v.label, v.dec)
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

	if PlayerMenu:Visible() then
		settingsPanel:UpdateDescription()
	end
end)

AddEventHandler("ArenaLobby:playermenu:Show", function(onClose)
	CreatePlayerMenuMenu()

	if PlayerMenu:Visible() then
		PlayerMenu:Visible(false)
		Citizen.Wait(50)
	end
	while firstLoad or IsDisabledControlPressed(0, 199) or IsDisabledControlPressed(0, 200) or IsPauseMenuRestarting() or IsFrontendFading() or IsPauseMenuActive() do
		SetPauseMenuActive(false)
		SetFrontendActive(false)
		Citizen.Wait(0)
	end
	-- while PlayerMenu.Subtitle == defaultSubtitle do
	-- 	Citizen.Wait(0)
	-- end

	PlayerMenu.InstructionalButtons = {}
	table.insert(PlayerMenu.InstructionalButtons, InstructionalButton.New(GetLabelText("HUD_INPUT2"), -1, 191, 191, -1))
	table.insert(PlayerMenu.InstructionalButtons, InstructionalButton.New(GetLabelText("HUD_INPUT3"), -1, 194, 194, -1))
	table.insert(PlayerMenu.InstructionalButtons, InstructionalButton.New(GetLabelText("HUD_INPUT8"), -1, -1, -1, "INPUTGROUP_FRONTEND_DPAD_ALL"))

	PlayerMenu:Visible(true)
	-- Citizen.SetTimeout(50, function()
	-- 	PlayerMenu:SwitchColumn(1)
	-- end)

	while PlayerMenu:Visible() do
		Citizen.Wait(0)
	end

	if onClose then
		while IsPauseMenuRestarting() or IsFrontendFading() or IsPauseMenuActive() do
			Citizen.Wait(0)
		end
		onClose()
	end
end)

AddEventHandler("ArenaLobby:playermenu:Hide", function()
	if PlayerMenu then
		PlayerMenu:Visible(false)
	end
end)
