AddEventHandler('onResourceStop', function(resourceName)
    RemoveEventsWithNameResource(resourceName)
end)

RegisterNetEvent("ArenaAPI:sendStatus")
AddEventHandler("ArenaAPI:sendStatus", function(type, data)
    local arena = data.ArenaIdentifier
    if type == "updateData" then
        ArenaData = data
        UpdatePlayerNameList()
    end
	
    if type == "updatePlayerList" then
		if data.PlayerList and PlayerData.CurrentArena == arena then
			PlayerList = data.PlayerList
		end
    end

    if type == "roundEnd" then
        if ArenaData[arena].MaximumArenaTime then
            ArenaData[arena].MaximumArenaTime = data.MaximumLobbyTime + 1
        end
        CallOn(arena, "roundend", data)
    end

    if type == "start" then
		if ArenaData[arena] then
			ArenaData[arena].ArenaState = "ArenaBusy"
		end
        CallOn(arena, "start", data)
        if PlayerData.CurrentArena == arena then
			NetworkSetTalkerProximity(10000.0) -- ความใกล้ชิด
			MumbleSetAudioInputDistance(10000.0) -- ระยะเสียงที่ส่ง
			MumbleSetAudioOutputDistance(10000.0) -- ระยะเสียงที่รับ
            IsArenaBusy = true
			Wait(1000)
        end
    end

    if type == "end" then
		if ArenaData[arena] then
			ArenaData[arena].ArenaState = "ArenaInactive"
		end
        CallOn(arena, "end", data)
        if ArenaData[arena] and ArenaData[arena].MaximumArenaTime then
            ArenaData[arena].MaximumArenaTime = data.MaximumLobbyTime + 1
        end
        if PlayerData.CurrentArena == arena then
			TriggerEvent("mumble:ResetVoiceTarget")
            IsArenaBusy = false
			PlayerData.CurrentArena = "none"
			PlayerList = {}
        end
    end

    if type == "join" then
        PlayerData.CurrentArena = data.ArenaIdentifier
        CallOn(arena, "join", data)
		
		if data.JoinAfterArenaStart then
			TriggerEvent("ArenaAPI:sendStatus", "start", data)
		else
			SendNUIMessage({ type = "ui", status = true, })
			SendNUIMessage({ type = "arenaName", arenaName = data.ArenaLabel })
			SendNUIMessage({ type = "arenaImage", arenaImage = string.gsub(data.ArenaIdentifier, "%d+", "") })
		end
        UpdatePlayerNameList()
    end

    if type == "leave" then
        CallOn(arena, "leave", data)

        if PlayerData.CurrentArena == arena then
			TriggerEvent("mumble:ResetVoiceTarget")
            IsArenaBusy = false
			PlayerList = {}
        end

        PlayerData.CurrentArena = "none"
        SendNUIMessage({ type = "ui", status = false, })
    end
end)