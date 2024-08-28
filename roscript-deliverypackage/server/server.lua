local QBCore = exports['qb-core']:GetCoreObject()
  
RegisterNetEvent('postal:server:givePackage', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.AddItem(Config.PackageItem, 1) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.PackageItem], "add")
        lib.notify({ title = 'Item received', description = 'You received a package!', type = 'success' })
    else
        lib.notify({ title = 'Error', description = 'No inventory space available', type = 'error' })
    end
end)

RegisterNetEvent('postal:server:chargePlayer', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveMoney('cash', amount) then
        lib.notify({ title = 'Charged', description = 'You were charged $'..amount, type = 'success' })
    else
        lib.notify({ title = 'Error', description = 'Not enough cash available', type = 'error' })
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
        lib.notify({ title = 'Delivery complete', description = 'You received $'..randomReward..' as a reward!', type = 'success' })

        
        if giveSpecialItem then
            Player.Functions.AddItem(Config.SpecialItem, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.SpecialItem], "add")
            lib.notify({ title = 'Special item received', description = 'You received a special item!', type = 'success' })
        end
    else
        lib.notify({ title = 'Error', description = 'No package available', type = 'error' })
    end
end)
