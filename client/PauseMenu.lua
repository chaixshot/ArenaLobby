function DecimalsToMinutes(dec)
	if dec then
		local ms = tonumber(dec)
		return math.floor(ms / 60) .. ":" .. (ms % 60)
	else
		return 0
	end
end

function UpdateDetails()
	RequestStreamedTextureDictC("ArenaLobby")
	local CurrentSize = ArenaAPI:GetArenaCurrentSize(ArenaAPI:GetPlayerArena())
	local MinimumSize = ArenaAPI:GetArenaMinimumSize(ArenaAPI:GetPlayerArena())
	local MaximumSize = ArenaAPI:GetArenaMaximumSize(ArenaAPI:GetPlayerArena())
	local ArenaLabel = ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena())
	local MaximumArenaTime = ArenaAPI:GetArena(ArenaAPI:GetPlayerArena()).MaximumArenaTime
	local map = ArenaAPI:GetArenaLabel(ArenaAPI:GetPlayerArena()):match("%((.*)%)")
	local txd = string.gsub(ArenaAPI:GetPlayerArena(), '%d+', '')
	
	TriggerEvent('lobbymenu:CreateMenu', 'ArenaLobby:PauseMenu', "DarkRP - GameRoom", ArenaLabel, "🕹️  Game", "Players "..CurrentSize.." of "..MaximumSize, "Info")
	TriggerEvent('lobbymenu:SetHeaderDetails', 'ArenaLobby:PauseMenu', false, false, 123, 0, 0)
	if string.find(string.lower(ArenaLabel), "racing") and exports["DarkRP_Racing"]:IsInGame() then
		exports["DarkRP_Racing"]:UpdateSettings(true)
		exports["DarkRP_Racing"]:UpdateDetails(true)
	else
		TriggerEvent('lobbymenu:SetDetailsTitle', 'ArenaLobby:PauseMenu', string.gsub(ArenaLabel, "%((.*)%)", ''), 'ArenaLobby', txd)
		if map then
			TriggerEvent('lobbymenu:AddDetailsRow', 'ArenaLobby:PauseMenu', "Map", map)
		end
		TriggerEvent('lobbymenu:AddDetailsRow', 'ArenaLobby:PauseMenu', "Min Player", MinimumSize)
		TriggerEvent('lobbymenu:AddDetailsRow', 'ArenaLobby:PauseMenu', "Time Left", DecimalsToMinutes(MaximumArenaTime).." Minute")
	end

	TriggerEvent('lobbymenu:AddButton', 'ArenaLobby:PauseMenu', {text = "Setting"}, "⚙️ ~p~Setting", "", false, 0, "ArenaLobby:PauseMenu.Setting")
	TriggerEvent('lobbymenu:AddButton', 'ArenaLobby:PauseMenu', {text = "Map"}, "🗺️  ~b~Map", "", false, 0, "ArenaLobby:PauseMenu.Map")
	TriggerEvent('lobbymenu:AddButton', 'ArenaLobby:PauseMenu', {id = 0, text = "Exit"}, " ~r~Leave Game", "", false, 0, "ArenaLobby:PauseMenu.leave")
	TriggerEvent('lobbymenu:SetDetailsCashRPandAP', "ArenaLobby:PauseMenu", 0, 0, 0)
end

function UpdatePlayerList()
	TriggerEvent('lobbymenu:ResetPlayerList', 'ArenaLobby:PauseMenu')
	local CurrentSize = ArenaAPI:GetArenaCurrentSize(ArenaAPI:GetPlayerArena())
	local MinimumSize = ArenaAPI:GetArenaMinimumSize(ArenaAPI:GetPlayerArena())
	local MaximumSize = ArenaAPI:GetArenaMaximumSize(ArenaAPI:GetPlayerArena())
	local ArenaBusy = ArenaAPI:IsCurrentArenaBusy()
	local emptyslot = MaximumSize-CurrentSize
	for source,v in pairs(ArenaAPI:GetPlayerListArena(ArenaAPI:GetPlayerArena())) do
		TriggerEvent('lobbymenu:AddPlayer', 'ArenaLobby:PauseMenu', v.name, "", (ArenaBusy and "PLAYING" or "WAITING"), 65, (Player(source).state.PlayerXP or 1), true, 116, (ArenaBusy and 18 or 12), 'ArenaLobby:PauseMenu.UsePlayerEvent', {source = source}, true)
	end
	for i=1,MaximumSize-CurrentSize do
		TriggerEvent('lobbymenu:AddPlayer', 'ArenaLobby:PauseMenu', "empty", "", "", 0, "", false, 9, 18)
	end
end

AddEventHandler("ArenaLobby:PauseMenu.UsePlayerEvent", function(_buttonParams)
	TriggerEvent('lobbymenu:SetTooltipMessage', 'ArenaLobby:PauseMenu', "Player: "..GetPlayerName(GetPlayerFromServerId(_buttonParams.source)))
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
	Wait(100)
	if ArenaAPI and ArenaAPI:IsPlayerInAnyArena() and ArenaAPI:GetPlayerArena() == data.ArenaIdentifier then
		UpdateDetails()
		UpdatePlayerList()
		TriggerEvent('lobbymenu:UpdateMenu', 'ArenaLobby:PauseMenu')
		TriggerEvent('lobbymenu:ReloadMenu', 'ArenaLobby:PauseMenu')
	end
end)