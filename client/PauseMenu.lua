function DecimalsToMinutes(dec)
	if dec then
		local ms = tonumber(dec)
		return math.floor(ms / 60) .. ":" .. (ms % 60)
	else
		return 0
	end
end

function UpdateDetails()
	ESX.Streaming.RequestStreamedTextureDict("ArenaLobby")
	local CurrentSize = ArenaAPI:GetArenaCurrentSize(ArenaAPI:GetPlayerArena())
	local MinimumSize = ArenaAPI:GetArenaMinimumSize(ArenaAPI:GetPlayerArena())
	local MaximumSize = ArenaAPI:GetArenaMaximumSize(ArenaAPI:GetPlayerArena())
	local ArenaLabel = ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena())
	local MaximumArenaTime = ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).MaximumArenaTime
	local map = ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena()):match("%((.*)%)")
	local txd = string.gsub(ArenaAPI:GetPlayerArena(), '%d+', '')
	
	TriggerEvent('lobbymenu:CreateMenu', 'ArenaLobby:PauseMenu', "DarkRP - GameRoom", ArenaLabel, "<font face='DarkRP'>🕹️  เกม</font>", "<font face='DarkRP'>ผู้เล่น "..CurrentSize.." จาก "..MaximumSize.."</font>", "<font face='DarkRP'>ข้อมูล</font>")
	TriggerEvent('lobbymenu:SetHeaderDetails', 'ArenaLobby:PauseMenu', false, true, 2, 18, 0)
	TriggerEvent('lobbymenu:SetDetailsTitle', 'ArenaLobby:PauseMenu', string.gsub(ArenaLabel, "%((.*)%)", ''), 'ArenaLobby', txd)
	
	if map then
		TriggerEvent('lobbymenu:AddDetailsRow', 'ArenaLobby:PauseMenu', "<font face='DarkRP'>แผนที่</font>", map)
	end
	TriggerEvent('lobbymenu:AddDetailsRow', 'ArenaLobby:PauseMenu', "<font face='DarkRP'>ผู้เล่นขั้นต่ำ</font>", MinimumSize.." <font face='DarkRP'>คน</font>")
	TriggerEvent('lobbymenu:AddDetailsRow', 'ArenaLobby:PauseMenu', "<font face='DarkRP'>เหลือเวลา</font>", DecimalsToMinutes(MaximumArenaTime).." <font face='DarkRP'>นาที</font>")
	
	TriggerEvent('lobbymenu:AddButton', 'ArenaLobby:PauseMenu', {text = "Setting"}, "<font face='DarkRP'>⚙️ ~p~ตั้งค่า</font>", "", false, 0, "ArenaLobby:PauseMenu.Setting")
	TriggerEvent('lobbymenu:AddButton', 'ArenaLobby:PauseMenu', {text = "Map"}, "<font face='DarkRP'>🗺️  ~b~แผนที่</font>", "", false, 0, "ArenaLobby:PauseMenu.Map")
	TriggerEvent('lobbymenu:AddButton', 'ArenaLobby:PauseMenu', {id = 0, text = "Exit"}, "<font face='DarkRP'>🚪 ~r~ออกจากเกม</font>", "", false, 0, "ArenaLobby:PauseMenu.leave")
	TriggerEvent('lobbymenu:SetDetailsCashRPandAP', "ArenaLobby:PauseMenu", 0, 0, 0)
end

function UpdatePlayerList()
	TriggerEvent('lobbymenu:ResetPlayerList', 'ArenaLobby:PauseMenu')
	local playerData = ESX.Game.GetDataPlayers()
	local CurrentSize = ArenaAPI:GetArenaCurrentSize(ArenaAPI:GetPlayerArena())
	local MinimumSize = ArenaAPI:GetArenaMinimumSize(ArenaAPI:GetPlayerArena())
	local MaximumSize = ArenaAPI:GetArenaMaximumSize(ArenaAPI:GetPlayerArena())
	local ArenaBusy = ArenaAPI:IsCurrentArenaBusy()
	local emptyslot = MaximumSize-CurrentSize
	for source,v in pairs(ArenaAPI:GetPlayerListArena(ArenaAPI:GetPlayerArena())) do
		TriggerEvent('lobbymenu:AddPlayer', 'ArenaLobby:PauseMenu', "<font face='DarkRP'>"..playerData[source].firstname.." ["..playerData[source].user_id.."]</font>", playerData[source].gangname, (ArenaBusy and "PLAYING" or "WAITING"), 65, (Player(source).state.PlayerXP or 1), true, 9, (ArenaBusy and 18 or 12), 'ArenaLobby:PauseMenu.UsePlayerEvent', {source = source}, false)
	end
	for i=1,MaximumSize-CurrentSize do
		TriggerEvent('lobbymenu:AddPlayer', 'ArenaLobby:PauseMenu', "<font face='DarkRP'>ว่าง</font>", "", "", 0, "", false, 9, 18)
	end
end

AddEventHandler("ArenaLobby:PauseMenu.UsePlayerEvent", function(_buttonParams)
	local playerData = ESX.Game.GetDataPlayers()[_buttonParams.source]
	TriggerEvent('lobbymenu:SetTooltipMessage', 'ArenaLobby:PauseMenu', "<font face='DarkRP'>ผู้เล่น</font>: "..playerData.firstname.." ["..playerData.user_id.."] ("..playerData.name..")")
	TriggerEvent('lobbymenu:UpdateMenu', 'ArenaLobby:PauseMenu')
	TriggerEvent('lobbymenu:ReloadMenu', 'ArenaLobby:PauseMenu')
end)

AddEventHandler("ArenaLobby:PauseMenu.Map", function(_buttonParams)
	TriggerEvent('lobbymenu:CloseMenu')
	Wait(100)
	ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_MP_PAUSE"), false, 0)
end)

AddEventHandler("ArenaLobby:PauseMenu.Setting", function(_buttonParams)
	TriggerEvent('lobbymenu:CloseMenu')
	Wait(100)
	ActivateFrontendMenu(GetHashKey("FE_MENU_VERSION_MP_PAUSE"), false, 6)
end)

AddEventHandler("ArenaLobby:PauseMenu.leave", function(_buttonParams)
	TriggerEvent('lobbymenu:CloseMenu')
	ExecuteCommand("minigame leave")
end)

RegisterCommand('+ArenaLobby_PauseMenu', function()
	if ArenaAPI and ArenaAPI:IsPlayerInAnyArena() then
		if not IsPauseMenuActive() then
			UpdateDetails()
			UpdatePlayerList()
			TriggerEvent('lobbymenu:OpenMenu', 'ArenaLobby:PauseMenu', true)
		end
	end
end, false)
RegisterCommand('-ArenaLobby_PauseMenu', function()
end, false)
RegisterKeyMapping('+ArenaLobby_PauseMenu', 'ArenaLobby_PauseMenu', 'keyboard', "ESCAPE")

RegisterCommand('+ArenaLobby_PauseMenu1', function()
	if ArenaAPI and ArenaAPI:IsPlayerInAnyArena() then
		if not IsPauseMenuActive() then
			UpdateDetails()
			UpdatePlayerList()
			TriggerEvent('lobbymenu:OpenMenu', 'ArenaLobby:PauseMenu', true)
		end
	end
end, false)
RegisterCommand('-ArenaLobby_PauseMenu1', function()
end, false)
RegisterKeyMapping('+ArenaLobby_PauseMenu1', 'ArenaLobby_PauseMenu1', 'keyboard', "P")

RegisterNetEvent("ArenaAPI:sendStatus")
AddEventHandler("ArenaAPI:sendStatus", function(type, data)
	if ArenaAPI and ArenaAPI:IsPlayerInAnyArena() and ArenaAPI:GetPlayerArena() == data.ArenaIdentifier then
		UpdateDetails()
		UpdatePlayerList()
		TriggerEvent('lobbymenu:UpdateMenu', 'ArenaLobby:PauseMenu')
		TriggerEvent('lobbymenu:ReloadMenu', 'ArenaLobby:PauseMenu')
	end
end) 