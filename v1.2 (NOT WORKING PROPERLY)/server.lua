--[[
TruckJob - Created by Lama	
For support - Lama#9612 on Discord	
Do not edit below if you don't know what you are doing
]] --

RegisterServerEvent("lama_jobs:started")
RegisterServerEvent("lama_jobs:delivered")
RegisterServerEvent("lama_jobs:finished")

-- ND_Framework exports (edit with your framework's)
NDCore = exports["ND_Core"]:GetCoreObject()

-- variables, do not touch
local sessions = {}
local deliveries = 0
local isOnJob = false

function isClientTooFar(location)
	local distance = #(GetEntityCoords(GetPlayerPed(source)) - vector3(location.x, location.y, location.z))
	-- checking from a distance of 15 because it might not be 100% correct
	if distance > 15 then return true
	else return false
	end
end

AddEventHandler("lama_jobs:started", function()
    isOnJob = true
end)

AddEventHandler("lama_jobs:delivered", function(location)
	if isOnJob and not isClientTooFar(location) then
		-- keep track of amount of deliveries made
		deliveries = deliveries + 1
	else
		print(string.format("^1Possible exploiter detected\nName: ^0%s\n^1Identifier: ^0%s\n^1Reason: ^0has delivered from a too big distance", GetPlayerName(source), GetPlayerIdentifier(source, 0)))
	end
end)

AddEventHandler("lama_jobs:finished", function()
	if deliveries == 0 then
		print(string.format("^1Possible exploiter detected\nName: ^0%s\n^1Identifier: ^0%s\n^1Reason: ^0has somehow requested to be paid without delivering anything", GetPlayerName(source), GetPlayerIdentifier(source, 0)))
	else
		-- calculate amount of money to give to the player
		amount = Config.PayPerDelivery * deliveries
		if isOnJob and not isClientTooFar(Config.DepotLocation) then
			-- give the money to player
			-- if using another framework than ND, simply change the function below to your framework's
			NDCore.Functions.AddMoney(amount, source, "bank")
		else
			print(string.format("^1Possible exploiter detected\nName: ^0%s\n^1Identifier: ^0%s\n^1Reason: ^0has somehow requested to be paid without being near the job ending location", GetPlayerName(source), GetPlayerIdentifier(source, 0)))
		end	
	end
end)

-- version checker
Citizen.CreateThread(function()
    updatePath = "/ItzEndah/TruckJob"
    resourceName = "TruckJob by Lama"

    function checkVersion(err, responseText, headers)
        -- Returns the version set in the file
        curVersion = GetResourceMetadata(GetCurrentResourceName(), "version")

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
