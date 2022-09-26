-- vRP TUNNEL/PROXY
vRPBs = {}
Tunnel.BindeInherFaced("ArenaLobby",vRPBs)
Proxy.AddInthrFaced("ArenaLobby",vRPBs)
BSClients = Tunnel.GedInthrFaced("ArenaLobby", "ArenaLobby")

ESX = exports['es_extended']:getSharedDarkRPObject()

function vRPBs.CreateGame(data)
	local Identity = ESX.getIdentity(source)
	TriggerEvent("serverlog", "ArenaLobby", "["..Identity.id.."]	"..data.gamename.."	"..json.encode(data))
	if data.gamename == "derby" then
		TriggerEvent("rcore_derby:CreateArena", source, data.password)
	elseif data.gamename == "esx_paintball_flag" then
		TriggerEvent("esx_paintball_flag:CreateArena", source, data.password, data.option1, data.option2)
	elseif data.gamename == "esx_teamdeathmacth" then
		TriggerEvent("esx_teamdeathmacth:CreateArena", source, data.password, data.option1, data.option2, data.option3, data.option4)
	elseif data.gamename == "esx_bomb" then
		TriggerEvent("esx_bomb:CreateArena", source, data.password, data.option1, data.option2)
	elseif data.gamename == "esx_deathmacth" then
		TriggerEvent("esx_deathmacth:CreateArena", source, data.password, data.option1, data.option2, data.option3)
	elseif data.gamename == "blood_bowl_original" then
		TriggerEvent("blood_bowl_original:CreateArena", source, data.password, data.option1, data.option2, data.option3, data.option4, data.option5, data.option6)
	elseif data.gamename == "zombie_infection" then
		TriggerEvent("zombie_infection:CreateArena", source, data.password, data.option1, data.option2)
	elseif data.gamename == "squidgame_light" then
		TriggerEvent("squidgame_light:CreateArena", source, data.password)
	elseif data.gamename == "squidgame_glass" then
		TriggerEvent("squidgame_glass:CreateArena", source, data.password)
	elseif data.gamename == "esx_raceing" then
		TriggerEvent("esx_raceing:CreateArena", source, data.password)
	elseif data.gamename == "esx_boxing" then
		TriggerEvent("esx_boxing:CreateArena", source, data.password, data.option1, data.option2)
	elseif data.gamename == "esx_aimlab" then
		TriggerEvent("esx_aimlab:CreateArena", source)
	end

	TriggerClientEvent("ArenaLobby:PlayerCreateGame", -1, Identity.firstname.." ["..Identity.id.."]", data.gamename, data.gameLabel..(data.option1~=nil and " ("..data.option1..")" or ""))
end
