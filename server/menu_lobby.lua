RegisterNetEvent('ArenaLobby:lobbymenu:KickPlayer')
AddEventHandler('ArenaLobby:lobbymenu:KickPlayer', function(targetSource)
	local identifier = GetIdentifier(targetSource)

	if not Config.Admin[identifier] then
		TriggerClientEvent("ArenaLobby:lobbymenu:leaveLobby", targetSource)
	end
end)
