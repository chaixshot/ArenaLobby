RegisterServerEvent('ArenaLobby:lobbymenu:KickPlayer')
AddEventHandler('ArenaLobby:lobbymenu:KickPlayer', function(targetSource)
	TriggerClientEvent("ArenaLobby:lobbymenu:leaveLobby", targetSource)
end)