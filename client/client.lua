--[[Proxy/Tunnel]]--
vRPBs = {}
Tunnel.BindeInherFaced("ArenaAPI",vRPBs)
BSServers = Tunnel.GedInthrFaced("ArenaAPI", "ArenaAPI")

IsArenaBusy = false

ArenaData = {}
PlayerList = {}
PlayerData = {
    CurrentArena = "none",
}

-- stolen from https://scriptinghelpers.org/questions/43622/how-do-i-turn-seconds-to-minutes-and-seconds
function DecimalsToMinutes(dec)
	if dec then
		local ms = tonumber(dec)
		return math.floor(ms / 60) .. ":" .. (ms % 60)
	else
		return 0
	end
end

function UpdatePlayerNameList()
    if IsPlayerInAnyArena() then
        local data = GetArena(GetPlayerArena())
        local names = {}
        for source, name in pairs(data.PlayerNameList) do
            table.insert(names, {name=name, avatar=data.PlayerAvatar[source]})
        end
        SendNUIMessage({ type = "playerNameList", Names = names, })
    end
end

CreateThread(function()
    TriggerServerEvent("ArenaAPI:PlayerJoinedFivem")
end)

CreateThread(function()
    while true do
        Wait(1000)
        if IsArenaBusy then
            local data = GetArena(GetPlayerArena())
            if data and data.MaximumArenaTime ~= nil and data.MaximumArenaTime > 1 then
                data.MaximumArenaTime = data.MaximumArenaTime - 1
				if data.ShowArenaTime then
					BeginTextCommandPrint('STRING')
					AddTextComponentSubstringPlayerName("Time Left "..DecimalsToMinutes(data.MaximumArenaTime))
					EndTextCommandPrint(1000, 1)
				end
				TriggerEvent("ArenaAPI:UpdateArenaTime", DecimalsToMinutes(data.MaximumArenaTime))
            end
        end

        if IsPlayerInAnyArena() then
            local data = GetArena(GetPlayerArena())
            if data and data.MinimumCapacity - 1 < data.CurrentCapacity then
                if data.MaximumLobbyTime == 1 then
                    SendNUIMessage({ type = "ui", status = false})
                else
                    data.MaximumLobbyTime = data.MaximumLobbyTime - 1
                    SendNUIMessage({
                        type = "updateTime",
                        time = data.MaximumLobbyTime,
                    })
                end
            end
        end
    end
end)

AddEventHandler('IsPauseMenuActive', function(toggle)
	if IsPlayerInAnyArena() and not IsArenaBusy then
		SendNUIMessage({ type = "ui", status = not toggle})
	end
end)


function vRPBs.ClientTypePassword()
	local password = KeyboardInput("Password:", "", 100)
	return tostring(password)
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)

	-- TextEntry		-->	The Text above the typing field in the black square
	-- ExampleText		-->	An Example Text, what it should say in the typing field
	-- MaxStringLenght	-->	Maximum String Lenght

	AddTextEntry('FMMC_KEY_TIP1', TextEntry) --Sets the Text above the typing field in the black square
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) --Actually calls the Keyboard Input
	blockinput = true --Blocks new input while typing if **blockinput** is used

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do --While typing is not aborted and not finished, this loop waits
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult() --Gets the result of the typing
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return result --Returns the result
	else
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return nil --Returns nil if the typing got aborted
	end
end

RegisterNetEvent("ArenaAPI:ShowNotification")
AddEventHandler("ArenaAPI:ShowNotification", function(msg)
	BeginTextCommandThefeedPost('STRING')
	AddTextComponentSubstringPlayerName(msg)
	local id = EndTextCommandThefeedPostTicker(false, true)
	ThefeedRemoveItem(id-5)
end)