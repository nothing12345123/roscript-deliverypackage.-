local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('postal:server:givePackage', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.AddItem(Config.PackageItem, 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.PackageItem], "add")
    else
        TriggerClientEvent('QBCore:Notify', src, _U('no_inventory_space'), 'error')
    end
end)

RegisterNetEvent('postal:server:chargePlayer', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveMoney('cash', amount) then
        TriggerClientEvent('QBCore:Notify', src, _U('charged_amount', amount), 'success')
    else
        TriggerClientEvent('QBCore:Notify', src, _U('not_enough_cash'), 'error')
    end
end)

RegisterNetEvent('postal:server:receiveReward', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)


    local minReward = Config.MinReward
    local maxReward = Config.MaxReward
    local randomReward = math.random(minReward, maxReward)


    local specialItemChance = Config.SpecialItemChance
    local giveSpecialItem = math.random(100) <= specialItemChance

    if Player.Functions.RemoveItem(Config.PackageItem, 1) then
        Player.Functions.AddMoney('cash', randomReward)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.PackageItem], "remove")
        TriggerClientEvent('QBCore:Notify', src, _U('delivery_complete_reward', randomReward), 'success')

        
        if giveSpecialItem then
            Player.Functions.AddItem(Config.SpecialItem, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.SpecialItem], "add")
            TriggerClientEvent('QBCore:Notify', src, _U('special_item_received'), 'success')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, _U('no_package'), 'error')
    end
end)