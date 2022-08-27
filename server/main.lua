-- vRP TUNNEL/PROXY
vRPBs = {}
Tunnel.BindeInherFaced("ArenaAPI",vRPBs)
Proxy.AddInthrFaced("ArenaAPI",vRPBs)
BSClients = Tunnel.GedInthrFaced("ArenaAPI", "ArenaAPI")

ArenaList = {}
PlayerInfo = {}
CooldownPlayers = {}
WorldCount = 0
----------------------------------------
function ArenaCreatorHelper(identifier)
    if ArenaList[identifier] ~= nil then return ArenaList[identifier] end
    ArenaList[identifier] = {
        MaximumCapacity = 0,
        MinimumCapacity = 0,
        CurrentCapacity = 0,
        -----
        MaximumRoundSaved = nil,
        CurrentRound = nil,
        -----
        DeleteWorldAfterWin = true,
        OwnWorld = false,
        OwnWorldID = 0,
        -----
        ArenaLabel = "",
        ArenaIdentifier = identifier,
        -----
        MaximumArenaTime = nil,
        MaximumArenaTimeSaved = nil,
        MaximumLobbyTimeSaved = 30,
        MaximumLobbyTime = 30,
        -----
        ArenaIsPublic = true,
		CanJoinAfterStart = false,
		Password = "",
        -----
        PlayerList = {},
        PlayerScoreList = {},
        PlayerNameList = {},
        PlayerAvatar = {},
        -----
        ArenaState = "ArenaInactive",
        -----
    }

    return ArenaList[identifier]
end

function GetDefaultDataFromArena(identifier)
    return ArenaCreatorHelper(identifier)
end

function SendMessage(source, msg)
	TriggerClientEvent("ArenaAPI:ShowNotification", source, msg)
end

RegisterCommand("minigame", function(source, args, rawCommand)
    if args[1] == "join" then
        local arenaName = args[2]
        if not IsPlayerInAnyArena(source) then
            if DoesArenaExists(arenaName) then
                local arenaInfo = GetDefaultDataFromArena(arenaName)
                local arena = GetArenaInstance(arenaName)
                if arena.IsArenaPublic() then
                    if not IsArenaBusy(arenaName) then
                        if arenaInfo.MaximumCapacity > arenaInfo.CurrentCapacity then
                            if not IsPlayerInCooldown(source, arenaName) then
								if arenaInfo.Password == "" then
									arena.MaximumLobbyTime = arena.MaximumLobbyTimeSaved
									GetArenaInstance(args[2]).AddPlayer(source)
								else
									BSClients.ClientTypePassword(source, {}, function(password)
										if arenaInfo.Password == password then
											arena.MaximumLobbyTime = arena.MaximumLobbyTimeSaved
											GetArenaInstance(args[2]).AddPlayer(source)
										else
											SendMessage(source, "~r~Incorrect Password.")
										end
									end)
								end
                            else
                                SendMessage(source, string.format(Config.MessageList["cooldown_to_join"], TimestampToString(GetcooldownForPlayer(source, arenaName))))
                            end
                        else
                            SendMessage(source, Config.MessageList["maximum_people"])
                        end
                    else
						if arenaInfo.CanJoinAfterStart then
							if arenaInfo.Password == "" then
								GetArenaInstance(args[2]).AddPlayer(source, true)
							else
								BSClients.ClientTypePassword(source, {}, function(password)
									if arenaInfo.Password == password then
										GetArenaInstance(args[2]).AddPlayer(source, true)
									else
										SendMessage(source, "~r~Incorrect Password.")
									end
								end)
							end
						else
							SendMessage(source, Config.MessageList["arena_busy"])
						end
                    end
                else
                    SendMessage(source, Config.MessageList["cant_acces_this_arena"])
                end
            else
                SendMessage(source, Config.MessageList["arena_doesnt_exists"])
            end
        end
    end
    if args[1] == "leave" then
        if IsPlayerInAnyArena(source) then
            local arenaName = GetPlayerArena(source)
            if DoesArenaExists(arenaName) then
                local arena = GetArenaInstance(arenaName)
                CooldownPlayer(source, arenaName, Config.TimeCooldown)
                arena.MaximumLobbyTime = arena.MaximumLobbyTimeSaved

                GetArenaInstance(arenaName).RemovePlayer(source)
            end
        end
    end
end, false)

function StringSplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

local StoreAvatar = {}

function GetAvatar(source)
	local steamid = "none"
	for k,v in pairs(GetPlayerIdentifiers(source)) do
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
			steamid = v
		end
	end
	
	if StoreAvatar[steamid] then
		return StoreAvatar[steamid]
	end
	
	local SteamIDInt = tonumber(string.sub(steamid, 7), 16)
	local avaterurl
	local timer = 100
	
	if not SteamIDInt then
		return "http://cdn.akamai.steamstatic.com/steamcommunity/public/images/avatars/f8/f8de58eb18a0cad87270ef1d1250c574498577fc_full.jpg"
	end
	
	PerformHttpRequest('http://steamcommunity.com/profiles/' .. SteamIDInt .. '/?xml=1', function(Error, Content, Head)
		if Content then
			local SteamProfileSplitted = StringSplit(Content, '\n')
			for i, Line in ipairs(SteamProfileSplitted) do
				if Line:find('<avatarFull>') then
					avaterurl = Line:gsub('	<avatarFull><!%[CDATA%[', ''):gsub(']]></avatarFull>', '')
					avaterurl = string.sub (avaterurl, 1, string.len(avaterurl)-1)
					break
				end
			end
		end
	end)
	
	while not avaterurl and timer > 0 do
		timer = timer-1
		Wait(0)
	end
	
	StoreAvatar[steamid] = avaterurl
	
	return avaterurl
end

CreateThread(function()
	Wait(2000)
	local resourceName = GetCurrentResourceName()
	local currentVersion = GetResourceMetadata(resourceName, "version", 0)
	PerformHttpRequest("https://api.github.com/repos/chaixshot/ArenaAPI/releases/latest", function (errorCode, resultData, resultHeaders)
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