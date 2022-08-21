--[[
TruckJob - Created by Lama	
For support - Lama#9612 on Discord	
Do not edit below if you don't know what you are doing
]]--

-- global variables, do not touch
isOnJob = false
hasCanceledJob = false

-- starting the job
Citizen.CreateThread(function()
    AddTextEntry("press_start_job", "Press ~INPUT_CONTEXT~ to start your shift")
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        
        -- uncomment this line below if you want a marker, I personally prefer without
        --DrawMarker(1, Config.BlipLocation.x, Config.BlipLocation.y, Config.BlipLocation.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.5, 0, 150, 255, 128, 0, 0, 0, 0)
        
        -- get distance between blip and player and check if player is near it
        if #(GetEntityCoords(player) - vector3(Config.BlipLocation.x, Config.BlipLocation.y, Config.BlipLocation.z)) <= 5 then
            DisplayHelpTextThisFrame("press_start_job")
            if IsControlPressed(1, 38) then
                if IsPedSittingInAnyVehicle(player) then
                    DisplayNotification("~r~You can't start the job while you're in a vehicle.")
                else
                    StartJob()
                end
            end
        end
    end
end)

-- draw blip on the map
Citizen.CreateThread(function()
    local blip = AddBlipForCoord(Config.BlipLocation.x, Config.BlipLocation.y, Config.BlipLocation.z)
    SetBlipSprite(blip, 457)
    SetBlipDisplay(blip, 4)
    SetBlipColour(blip, 21)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Truck Job")
    EndTextCommandSetBlipName(blip)
end)

function StartJob()
    local player = PlayerPedId()
    -- set model of the vehicle used for the job
    local vehicleName = Config.TruckModel
    RequestModel(vehicleName)
    while not HasModelLoaded(vehicleName) do
        Wait(500)
    end
    -- spawn truck at the depot
    vehicle = CreateVehicle(vehicleName, Config.DepotLocation.x, Config.DepotLocation.y, Config.DepotLocation.z, Config.DepotLocation.h, true, false)
    SetVehicleOnGroundProperly(vehicle)
    SetPedIntoVehicle(player, vehicle, -1)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetModelAsNoLongerNeeded(vehicleName)
    -- give player first task
    isOnJob = true
    FirstTask()
end

-- the first task consists of driving to the trailer and picking it up
function FirstTask()
    hasCanceledJob = false
    -- choose random location where the trailer is going to spawn
    local location = math.randomchoice(Config.TrailerLocations)
    -- choose random trailer model
    local model = math.randomchoice(Config.TrailerModels)
    -- add trailer blip to map
    local blip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(blip, 479)
    SetBlipColour(blip, 26)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 26)
    -- clear area first
    ClearArea(location.x, location.y, location.z, 50, false, false, false, false, false);
    -- spawn the chosen trailer at the chosen location
    SpawnTrailer(model, location)
    DisplayNotification("~b~Pick up the trailer~w~. Press ~r~DEL~w~ to cancel the job and pay a penalty.")
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        -- if player cancels the task
        if IsControlPressed(1, Config.CancelJobKey) then
            DeleteVehicle(trailer)
            RemoveBlip(blip)
            hasCanceledJob = true
            ThirdTask()
            break
        end
        -- gets distance between player and trailer location and check if player is in the vicinity of it
        if #(GetEntityCoords(player) - vector3(location.x, location.y, location.z)) <= 20 then
            -- and check if they have picked up the trailer 
            if IsVehicleAttachedToTrailer(vehicle) then
                RemoveBlip(blip)
                SecondTask()
            end
        end
    end
end

-- the second task consists of driving to the location and deliver the trailer
function SecondTask()
    AddTextEntry("press_detach_trailer", "Long press ~INPUT_VEH_HEADLIGHT~ to detach the trailer")
    local location = math.randomchoice(Config.Destinations)
    local blip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(blip, 478)
    SetBlipColour(blip, 26)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 26)
    DisplayNotification( "~b~Detach the trailer at the location.~w~ Press ~r~DEL~w~ to cancel the job and pay a penalty.")
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        -- if player cancels the task
        if IsControlPressed(1, Config.CancelJobKey) then
            DeleteVehicle(trailer)
            RemoveBlip(blip)
            hasCanceledJob = true
            ThirdTask()
            break
        end        
        -- gets distance between player and task location and check f player is in the vicinity of it
        if #(GetEntityCoords(player) - vector3(location.x, location.y, location.z)) <= 20 then
            DisplayHelpTextThisFrame("press_detach_trailer")
            -- and check if they don't have a trailer attached anymore
            if IsVehicleAttachedToTrailer(vehicle) == false then
                RemoveBlip(blip)
                ThirdTask()
            end
        end
    end
end

-- the third task consists of driving back to the truck depot and get paid
function ThirdTask()
    local blip = AddBlipForCoord(Config.DepotLocation.x, Config.DepotLocation.y, Config.DepotLocation.z)
    AddTextEntry("press_end_job", "Press ~INPUT_CONTEXT~ to end your shift")
    SetBlipSprite(blip, 477)
    SetBlipColour(blip, 26)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 26)
    if hasCanceledJob then
        DisplayNotification("~r~Job cancelled. ~w~Return the truck to the depot.")
    else
        DisplayNotification("~b~Return the truck to the depot to get paid.")
    end
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        -- gets distance between player and depot location and check if player is in the vicinity of it
        if #(GetEntityCoords(player) - vector3(Config.DepotLocation.x, Config.DepotLocation.y, Config.DepotLocation.z)) <= 10 then
            DisplayHelpTextThisFrame("press_end_job")
            if IsControlPressed(1, 38) then
                RemoveBlip(blip)
                -- deletes truck and trailer
                DeleteVehicle(GetVehiclePedIsIn(player, false))
                DeleteVehicle(trailer)
                isOnJob = false
                if Config.UseND then
                    if hasCanceledJob then
                        TriggerServerEvent("LamasJobs:GivePenalty", Config.PenaltyAmount)
                        DisplayNotification("You've been fined ~r~$" .. Config.PenaltyAmount .. " ~w~for cancelling the job.")
                        break
                    else 
                        local amount = math.random(Config.MinPayAmount, Config.MaxPayAmount)
                        TriggerServerEvent("LamasJobs:GivePay", amount)
                        DisplayNotification("You've received ~g~$" .. amount .. " ~w~for completing the job.")
                        break
                    end
                else
                    if hasCanceledJob then
                        DisplayNotification("~b~You've cancelled the job.")
                        break
                    else
                        DisplayNotification("~g~You've successfully completed the job.")
                        break
                    end
                end
            end
        end
    end
end

-- spawn random generated trailer at random generated location
function SpawnTrailer(model, location)
    local trailerName = model
    -- load model
    RequestModel(trailerName)
    while not HasModelLoaded(trailerName) do
        Wait(500)
    end
    -- spawn trailer
    trailer = CreateVehicle(trailerName, location.x, location.y, location.z, location.h, true, false)
    SetVehicleOnGroundProperly(trailer)
    SetPedIntoVehicle(player, trailer, -1)
    SetEntityAsMissionEntity(trailer, true, true)
    SetModelAsNoLongerNeeded(trailerName)
end

-- function to get random items from a table
function math.randomchoice(table)
    local keys = {}
    for key, value in pairs(table) do
        keys[#keys + 1] = key
    end
    index = keys[math.random(1, #keys)]
    return table[index]
end

-- function to display the notification above minimap
function DisplayNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end
