--[[
TruckJob - Created by Lama	
For support - https://discord.gg/etkAKTw3M7
Do not edit below if you don't know what you are doing
]] --

-- ND_Framework exports (edit with your framework's)
-- Uncomment the next line to use NDFramework

-- NDCore = exports["ND_Core"]:GetCoreObject()

-- variables, do not touch
local deliveries = {}
local playersOnJob = {}

-- function to check if the client is actually at the job ending location before giving them the money
function isClientTooFar(location)
	local distance = #(GetEntityCoords(GetPlayerPed(source)) - vector3(location.x, location.y, location.z))
	-- checking from a distance of 15 because it might not be 100% correct
	if distance > 25 then return true
	else return false
	end
end

RegisterNetEvent("lama_jobs:started", function()
    local src = source
    playersOnJob[src] = true
end)

RegisterNetEvent("lama_jobs:delivered", function(location)
    local src = source
	if playersOnJob[src] and not isClientTooFar(location) then
		-- keep track of amount of deliveries made
        if not deliveries[src] then
            deliveries[src] = 0
        end
		deliveries[src] = deliveries[src] + 1
	else
		print(string.format("^1Possible exploiter detected\nName: ^0%s\n^1Identifier: ^0%s\n^1Reason: ^0has delivered from a too big distance", GetPlayerName(source), GetPlayerIdentifier(source, 0)))
	end
end)

RegisterNetEvent("lama_jobs:finished", function()
    local src = source
	if not deliveries[src] or deliveries[src] == 0 then
		print(string.format("^1Possible exploiter detected\nName: ^0%s\n^1Identifier: ^0%s\n^1Reason: ^0has somehow requested to be paid without delivering anything", GetPlayerName(source), GetPlayerIdentifier(source, 0)))
	else
		-- calculate amount of money to give to the player
		local amount = Config.PayPerDelivery * deliveries[src]
			-- only give the money to the client if it is on the job and near the ending location
		if playersOnJob[src] and not isClientTooFar(Config.DepotLocation) then
			-- give the money to player
			-- if using another framework than ND, simply change the function below to your framework's
            deliveries[src] = 0
            playersOnJob[src] = false
			NDCore.Functions.AddMoney(amount, src, "bank")
		else
			print(string.format("^1Possible exploiter detected\nName: ^0%s\n^1Identifier: ^0%s\n^1Reason: ^0has somehow requested to be paid without being near the job ending location", GetPlayerName(source), GetPlayerIdentifier(source, 0)))
		end	
	end
end)

RegisterNetEvent("lama_jobs:finishednat", function()
    local src = source
	if not deliveries[src] or deliveries[src] == 0 then
		print(string.format("^1Possible exploiter detected\nName: ^0%s\n^1Identifier: ^0%s\n^1Reason: ^0has somehow requested to be paid without delivering anything", GetPlayerName(source), GetPlayerIdentifier(source, 0)))
	else
		-- calculate amount of money to give to the player
		local amount = Config.PayPerDelivery * deliveries[src]
			-- only give the money to the client if it is on the job and near the ending location
		if playersOnJob[src] and not isClientTooFar(Config.DepotLocation) then
			-- give the money to player
            deliveries[src] = 0
            playersOnJob[src] = false
            local xPlayer = exports.money:getaccount(source)

            exports.money:updateaccount(source, {cash = xPlayer.amount + amount, bank = xPlayer.bank})
		else
			print(string.format("^1Possible exploiter detected\nName: ^0%s\n^1Identifier: ^0%s\n^1Reason: ^0has somehow requested to be paid without being near the job ending location", GetPlayerName(source), GetPlayerIdentifier(source, 0)))
		end	
	end
end)

-- version checker
Citizen.CreateThread(function()
    updatePath = "/lama-development/TruckJob"
    resourceName = "TruckJob by Lama"

    function checkVersion(err, responseText, headers)
        -- Returns the version set in the file
        local curVersion = GetResourceMetadata(GetCurrentResourceName(), "version")

        if responseText == nil or curVersion == nil then
            print("^1There was an error retrieving the version of " .. resourceName .. ": the version checker will be skipped.")
        else
            if tonumber(curVersion) == tonumber(responseText) then
                print("^2" .. resourceName .. " is up to date. Enjoy.")
            else
                print("^1" .. resourceName .. " is outdated.\nLatest version: " .. responseText .. "Current version: " .. curVersion .. "\nPlease update it from: https://github.com" .. updatePath)
            end
        end
    end

    PerformHttpRequest("https://raw.githubusercontent.com" .. updatePath .. "/main/version", checkVersion, "GET")
end)
