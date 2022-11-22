RegisterServerEvent('ArenaLobby:CreateGame')
AddEventHandler('ArenaLobby:CreateGame', function(data)
	if data.gamename == "DarkRP_Derby" then
		TriggerEvent("DarkRP_Derby:CreateArena", source, data.password)
	elseif data.gamename == "DarkRP_CaptureTheFlag" then
		TriggerEvent("DarkRP_CaptureTheFlag:CreateArena", source, data.password, data.option1, data.option2)
	elseif data.gamename == "DarkRP_Teamdeathmacth" then
		TriggerEvent("DarkRP_Teamdeathmacth:CreateArena", source, data.password, data.option1, data.option2, data.option3, data.option4)
	elseif data.gamename == "DarkRP_Bomb" then
		TriggerEvent("DarkRP_Bomb:CreateArena", source, data.password, data.option1, data.option2)
	elseif data.gamename == "DarkRP_Deathmacth" then
		TriggerEvent("DarkRP_Deathmacth:CreateArena", source, data.password, data.option1, data.option2, data.option3)
	elseif data.gamename == "DarkRP_Bloodbowl" then
		TriggerEvent("DarkRP_Bloodbowl:CreateArena", source, data.password, data.option1, data.option2, data.option3, data.option4, data.option5, data.option6)
	elseif data.gamename == "DarkRP_ZombieInfection" then
		TriggerEvent("DarkRP_ZombieInfection:CreateArena", source, data.password, data.option1, data.option2)
	elseif data.gamename == "DarkRP_Squidlight" then
		TriggerEvent("DarkRP_Squidlight:CreateArena", source, data.password)
	elseif data.gamename == "DarkRP_Squidglass" then
		TriggerEvent("DarkRP_Squidglass:CreateArena", source, data.password)
	elseif data.gamename == "DarkRP_Racing" then
		local source=source
		local data=data
		TriggerEvent("DarkRP_Racing:CreateArena", source, data.password, function()
			TriggerClientEvent("ArenaLobby:PlayerCreateGame", -1, GetPlayerName(source), data.gamename, data.gameLabel..(data.option1~=nil and " ("..data.option1..")" or ""))
		end)
	elseif data.gamename == "DarkRP_CreateRacing" then
		TriggerEvent("DarkRP_Racing:CreateMap", source)
	elseif data.gamename == "DarkRP_Boxing" then
		TriggerEvent("DarkRP_Boxing:CreateArena", source, data.password, data.option1, data.option2)
	elseif data.gamename == "DarkRP_Aimlab" then
		TriggerEvent("DarkRP_Aimlab:CreateArena", source)
	end
	if not data.gamename == "DarkRP_Racing" then
		TriggerClientEvent("ArenaLobby:PlayerCreateGame", -1, GetPlayerName(source), data.gamename, data.gameLabel..(data.option1~=nil and " ("..data.option1..")" or ""))
	end
end)


CreateThread(function()
	Wait(2000)
	local resourceName = GetCurrentResourceName()
	local currentVersion = GetResourceMetadata(resourceName, "version", 0)
	PerformHttpRequest("https://api.github.com/repos/chaixshot/ArenaLobby/releases/latest", function (errorCode, resultData, resultHeaders)
		if errorCode == 200 then
			local data = json.decode(resultData)
			if currentVersion ~= data.name then
				print("------------------------------")
				print("Update available for ^1"..resourceName.."^0")
				print("Please update to the latest release ^2(version: "..data.name..")^0")
				print("Check in ^3"..data.html_url.."^0")
				print("------------------------------")
			end
		end
	end)
end)