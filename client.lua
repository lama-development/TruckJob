--[[
TruckJob - Created by Lama	
For support - Lama#9612 on Discord	
Do not edit below if you don't know what you are doing
]] --

pay = 0

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

-- starting the job
Citizen.CreateThread(function()
    AddTextEntry("press_start_job", "Press ~INPUT_CONTEXT~ to start your shift")
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        -- get distance between blip and player and check if player is near it
        if #(GetEntityCoords(player) - vector3(Config.BlipLocation.x, Config.BlipLocation.y, Config.BlipLocation.z)) <= 5 then
            DisplayHelpTextThisFrame("press_start_job")
            if IsControlPressed(1, 38) then
                if IsPedSittingInAnyVehicle(player) then
                    DisplayNotification("~r~You can't start the job while you're in a vehicle.")
                else
                    SpawnVehicle(Config.TruckModel, Config.DepotLocation)
                    SetPedIntoVehicle(player, vehicle, -1)
                    StartJob()
                end
            end
        end
    end
end)

-- drive to the trailer and pick it up
function StartJob()
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
    -- delete previous trailer before spawning a new one
    if trailer ~= nil then 
        DeleteVehicle(trailer)
    end
    trailer = SpawnTrailer(model, location)
    DisplayNotification("~b~New task: ~w~pick up the trailer at the marked location.")
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        -- gets distance between player and trailer location and check if player is in the vicinity of it
        if #(GetEntityCoords(player) - vector3(location.x, location.y, location.z)) <= 20 then
            -- and check if they have picked up the trailer 
            if IsVehicleAttachedToTrailer(vehicle) then
                RemoveBlip(blip)
                DeliverTrailer()
                break
            end
        end
    end
end

-- drive to the location and deliver the trailer
function DeliverTrailer()
    AddTextEntry("press_detach_trailer", "Long press ~INPUT_VEH_HEADLIGHT~ to detach the trailer")
    local location = math.randomchoice(Config.Destinations)
    local blip = AddBlipForCoord(location.x, location.y, location.z)
    SetBlipSprite(blip, 478)
    SetBlipColour(blip, 26)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 26)
    DisplayNotification("~b~New task: ~w~deliver the trailer at the marked location.")
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        -- gets distance between player and task location and check f player is in the vicinity of it
        if #(GetEntityCoords(player) - vector3(location.x, location.y, location.z)) <= 20 then
            DisplayHelpTextThisFrame("press_detach_trailer")
            -- and check if they don't have a trailer attached anymore
            if not IsVehicleAttachedToTrailer(vehicle) then
                RemoveBlip(blip)
                pay = pay + Config.PayPerJob
                NewChoice()
                break
            end
        end
    end
end

-- choose to deliver another trailer or return do depot
function NewChoice()
    DisplayNotification("Press ~b~E~w~ to accept another job.\nPress ~r~X~w~ to end your shift.")
    while true do
        Citizen.Wait(0)
        if IsControlPressed(1, 38) then
            StartJob()
            break         
        elseif IsControlPressed(1, 73) then
            EndJob()
            break
        end
    end
end

-- drive back to the truck depot and get paid
function EndJob()
    local blip = AddBlipForCoord(Config.DepotLocation.x, Config.DepotLocation.y, Config.DepotLocation.z)
    AddTextEntry("press_end_job", "Press ~INPUT_CONTEXT~ to end your shift")
    SetBlipSprite(blip, 477)
    SetBlipColour(blip, 26)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 26)
    if Config.UseND then 
        DisplayNotification("~b~New task: ~w~return the truck to the depot to get paid.")
    else 
        DisplayNotification("~b~New task: ~w~return the truck to the depot.")
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
                local truck = GetVehiclePedIsIn(player, false)
                if GetEntityModel(truck) == GetHashKey(Config.TruckModel) then
                    DeleteVehicle(GetVehiclePedIsIn(player, false))
                end
                DeleteVehicle(trailer)
                if Config.UseND then
                    -- todo: validate pay amount on server side for security purposes
                    TriggerServerEvent("LamasJobs:GivePay", pay)
                    DisplayNotification("You've received ~g~$" .. pay .. " ~w~for completing the job.")
                    break
                else
                    DisplayNotification("~g~You've successfully completed the job.")
                    break
                end
            end
        end
    end
end

-- function to spawn vehicle at desired location
function SpawnVehicle(model, location)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end
    vehicle = CreateVehicle(model, location.x, location.y, location.z, location.h, true, false)
    SetVehicleOnGroundProperly(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetModelAsNoLongerNeeded(model)
end

-- function to trailer vehicle at desired location
function SpawnTrailer(model, location)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end
    trailer = CreateVehicle(model, location.x, location.y, location.z, location.h, true, false)
    SetVehicleOnGroundProperly(trailer)
    SetEntityAsMissionEntity(trailer, true, true)
    SetModelAsNoLongerNeeded(model)
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
