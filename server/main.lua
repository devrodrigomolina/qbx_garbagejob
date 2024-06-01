local config = require 'config.server'
local sharedConfig = require 'config.shared'
local routes = {}

local function canPay(player)
    return player.PlayerData.money.bank >= sharedConfig.truckPrice
end

lib.callback.register("garbagejob:server:NewShift", function(source, continue)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local citizenId = player.PlayerData.citizenid
    local shouldContinue = false
    local nextStop = 0
    local totalNumberOfStops = 0
    local bagNum = 0

    if canPay(player) or continue then
        local maxStops = math.random(config.minStops, #sharedConfig.locations.trashcan)
        local allStops = {}

        for _ = 1, maxStops do
            local stop = math.random(#sharedConfig.locations.trashcan)
            local newBagAmount = math.random(config.minBagsPerStop, config.maxBagsPerStop)
            allStops[#allStops + 1] = {stop = stop, bags = newBagAmount}
        end

        routes[citizenId] = {
            stops = allStops,
            currentStop = 1,
            started = true,
            currentDistance = 0,
            depositPay = sharedConfig.truckPrice,
            actualPay = 0,
            stopsCompleted = 0,
            totalNumberOfStops = #allStops
        }

        nextStop = allStops[1].stop
        shouldContinue = true
        totalNumberOfStops = #allStops
        bagNum = allStops[1].bags
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.not_enough", {value = sharedConfig.truckPrice}), "error")
    end

    return shouldContinue, nextStop, bagNum, totalNumberOfStops
end)

lib.callback.register("garbagejob:server:NextStop", function(source, currentStop, currentStopNum, currLocation)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local citizenId = player.PlayerData.citizenid
    local currStopCoords = sharedConfig.locations.trashcan[currentStop].coords
    local distance = #(currLocation - currStopCoords.xyz)
    local newStop = 0
    local shouldContinue = false
    local newBagAmount = 0
    exports["cw-rep"]:updateSkill(source, "garbage", 5)

    if math.random(100) >= config.cryptoStickChance and config.giveCryptoStick then
        player.Functions.AddItem("cryptostick", 1, false)
        TriggerClientEvent('QBCore:Notify', source, Lang:t("info.found_crypto"))
    end

    if distance <= 20 then
        if currentStopNum >= #routes[citizenId].stops then
            routes[citizenId].stopsCompleted = tonumber(routes[citizenId].stopsCompleted) + 1
            newStop = currentStop
        else
            newStop = routes[citizenId].stops[currentStopNum+1].stop
            newBagAmount = routes[citizenId].stops[currentStopNum+1].bags
            shouldContinue = true
            local bagAmount = routes[citizenId].stops[currentStopNum].bags
            local totalNewPay = 0

            for _ = 1, bagAmount do
                totalNewPay += math.random(config.bagLowerWorth, config.bagUpperWorth)
            end

            routes[citizenId].actualPay = math.ceil(routes[citizenId].actualPay + totalNewPay)
            routes[citizenId].stopsCompleted = tonumber(routes[citizenId].stopsCompleted) + 1
        end
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.too_far"), "error")
    end

    return shouldContinue, newStop, newBagAmount
end)

lib.callback.register('garbagejob:server:EndShift', function(source)
    local player = exports.qbx_core:GetPlayer(source)
    if not player then return end

    local citizenId = player.PlayerData.citizenid
    return routes[citizenId]
end)

lib.callback.register('garbagejob:server:spawnVehicle', function(source, coords)
    local netId = SpawnVehicle(source, joaat(config.vehicle), coords, true)
    if not netId or netId == 0 then return end
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or veh == 0 then return end

    local plate = "GBGE" .. tostring(math.random(1000, 9999))
    SetVehicleNumberPlateText(veh, plate)
    TriggerClientEvent('vehiclekeys:client:SetOwner', source, plate)
    SetVehicleDoorsLocked(veh, 2)
    local player = exports.qbx_core:GetPlayer(source)
    TriggerClientEvent('QBCore:Notify', source, Lang:t(player and not player.Functions.RemoveMoney("bank", sharedConfig.truckPrice, "garbage-deposit") and "error.not_enough" or "info.deposit_paid", {value = sharedConfig.truckPrice}), "error")

    return netId
end)

RegisterNetEvent('garbagejob:server:PayShift', function(continue)
    local src = source
    local player = exports.qbx_core:GetPlayer(src)
    local citizenId = player.PlayerData.citizenid
    if routes[citizenId] then
        local depositPay = routes[citizenId].depositPay
        if tonumber(routes[citizenId].stopsCompleted) < tonumber(routes[citizenId].totalNumberOfStops) then
            depositPay = 0
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.early_finish", {completed = routes[citizenId].stopsCompleted, total = routes[citizenId].totalNumberOfStops}), "error")
        end
        if continue then
            depositPay = 0
        end
        local totalToPay = depositPay + routes[citizenId].actualPay
        local payoutDeposit = Lang:t("info.payout_deposit", {value = depositPay})
        if depositPay == 0 then
            payoutDeposit = ""
        end
        player.Functions.AddMoney("bank", totalToPay , 'garbage-payslip')
        exports["cw-rep"]:updateSkill(src, "garbage", 5)
        TriggerClientEvent('QBCore:Notify', src, Lang:t("success.pay_slip", {total = totalToPay, deposit = payoutDeposit}), "success")
        routes[citizenId] = nil
    else
        TriggerClientEvent('QBCore:Notify', source, Lang:t("error.never_clocked_on"), "error")
    end
end)

lib.addCommand('cleargarbroutes', {
    help = 'Removes garbo routes for user (admin only)', -- luacheck: ignore
    params = {
        { name = 'id', help = 'Player ID (may be empty)' }
    },
    restricted = 'group.admin'
},  function(source, args)
    local player = exports.qbx_core:GetPlayer(tonumber(args[1]))
    if not player then return end
    local citizenId = player.PlayerData.citizenid
    local count = 0
    for k in pairs(routes) do
        if k == citizenId then
            count += 1
        end
    end
    TriggerClientEvent('QBCore:Notify', source, Lang:t("success.clear_routes", {value = count}), "success")
    routes[citizenId] = nil
end)
