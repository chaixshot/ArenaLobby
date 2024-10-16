RegisterNetEvent('ArenaLobby:CreateGame')
AddEventHandler('ArenaLobby:CreateGame', function(data)
	data.password = tostring(data.password)

	if data.gameName == "DarkRP_Derby" then
		TriggerEvent("DarkRP_Derby:CreateArena", source, data.password)
	elseif data.gameName == "DarkRP_CaptureTheFlag" then
		TriggerEvent("DarkRP_CaptureTheFlag:CreateArena", source, data.password, data.option1, data.option2)
	elseif data.gameName == "DarkRP_Teamdeathmacth" then
		TriggerEvent("DarkRP_Teamdeathmacth:CreateArena", source, data.password, data.option1, data.option2, data.option3, data.option4)
	elseif data.gameName == "DarkRP_Bomb" then
		TriggerEvent("DarkRP_Bomb:CreateArena", source, data.password, data.option1, data.option2)
	elseif data.gameName == "DarkRP_Deathmacth" then
		TriggerEvent("DarkRP_Deathmacth:CreateArena", source, data.password, data.option1, data.option2, data.option3)
	elseif data.gameName == "DarkRP_Bloodbowl" then
		TriggerEvent("DarkRP_Bloodbowl:CreateArena", source, data.password, data.option1, data.option2, data.option3, data.option4, data.option5, data.option6)
	elseif data.gameName == "DarkRP_ZombieSurvival" then
		TriggerEvent("DarkRP_ZombieSurvival:CreateArena", source, data.password, data.option1, data.option2, data.option3)
	elseif data.gameName == "DarkRP_Squidlight" then
		TriggerEvent("DarkRP_Squidlight:CreateArena", source, data.password)
	elseif data.gameName == "DarkRP_Squidglass" then
		TriggerEvent("DarkRP_Squidglass:CreateArena", source, data.password)
	elseif data.gameName == "DarkRP_Racing" then
		TriggerEvent("DarkRP_Racing:CreateArena", source, data.password)
	elseif data.gameName == "DarkRP_CreateRacing" then
		TriggerEvent("DarkRP_Racing:CreateMap", source)
	elseif data.gameName == "DarkRP_Aimlab" then
		TriggerEvent("DarkRP_Aimlab:CreateArena", source)
	end
end)

Citizen.CreateThread(function()
	Citizen.Wait(2000)

	local resourceName = GetCurrentResourceName()
	local currentVersion = GetResourceMetadata(resourceName, "version", 0)
	PerformHttpRequest("https://api.github.com/repos/chaixshot/ArenaLobby/releases/latest", function(errorCode, resultData, resultHeaders)
		if errorCode == 200 then
			local data = json.decode(resultData)
			if currentVersion ~= data.name then
				print("------------------------------")
				print("Update available for ^1"..resourceName.." ^3(current version: "..currentVersion..")^0")
				print("Please update to the latest release ^2(version: "..data.name..")^0")
				print("Check in ^3"..data.html_url.."^0")
				print("------------------------------")
			end
		end
	end)
end)
