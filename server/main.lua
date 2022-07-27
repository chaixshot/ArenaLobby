RegisterServerEvent('ArenaLobby:CreateGame')
AddEventHandler('ArenaLobby:CreateGame', function(data)
	if data.gamename == "derby" then
		-- TriggerEvent("rcore_derby:CreateArena", source, data.password)
	-- elseif data.gamename == "paintball_flag" then
		-- TriggerEvent("paintball_flag:CreateArena", source, data.password, data.option1, data.option2)
	-- elseif data.gamename == "teamdeathmacth" then
		-- TriggerEvent("teamdeathmacth:CreateArena", source, data.password, data.option1, data.option2, data.option3, data.option4)
	-- elseif data.gamename == "bomb" then
		-- TriggerEvent("bomb:CreateArena", source, data.password, data.option1, data.option2)
	-- elseif data.gamename == "deathmacth" then
		-- TriggerEvent("deathmacth:CreateArena", source, data.password, data.option1, data.option2, data.option3)
	-- elseif data.gamename == "blood_bowl_original" then
		-- TriggerEvent("blood_bowl_original:CreateArena", source, data.password, data.option1, data.option2, data.option3, data.option4, data.option5, data.option6)
	-- elseif data.gamename == "zombie_infection" then
		-- TriggerEvent("zombie_infection:CreateArena", source, data.password, data.option1, data.option2)
	-- elseif data.gamename == "squidgame_light" then
		-- TriggerEvent("squidgame_light:CreateArena", source, data.password)
	-- elseif data.gamename == "squidgame_glass" then
		-- TriggerEvent("squidgame_glass:CreateArena", source, data.password)
	elseif data.gamename == "DarkRP_Racing" then
		TriggerEvent("DarkRP_Racing:CreateArena", source, data.password)
	-- elseif data.gamename == "boxing" then
		-- TriggerEvent("boxing:CreateArena", source, data.password, data.option1, data.option2)
	-- elseif data.gamename == "aimlab" then
		-- TriggerEvent("aimlab:CreateArena", source)
	end

	TriggerClientEvent("ArenaLobby:PlayerCreateGame", -1, GetPlayerName(source), data.gamename, data.gameLabel..(data.option1~=nil and " ("..data.option1..")" or ""))
end)