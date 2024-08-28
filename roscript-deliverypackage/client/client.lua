local QBCore = exports['qb-core']:GetCoreObject()
local deliveryBlip = nil
local npcModel = Config.NPCModel
local hasPackage = false
local recipientNPC = nil
local currentDeliveryLocation = nil
local faggioCost = 50
local boxProp = nil
local deliveryZone = nil

-- Delivery start location setup
local startLocation = Config.StartLocation  

Citizen.CreateThread(function()
    -- Spawn delivery NPC
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Wait(1)
    end

    local npc = CreatePed(4, npcModel, startLocation.x, startLocation.y, startLocation.z - 1, startLocation.w, false, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    TaskStartScenarioInPlace(npc, "WORLD_HUMAN_CLIPBOARD", 0, true)

    -- Setup qb-target for delivery NPC
    exports['qb-target']:AddTargetEntity(npc, {
        options = {
            {
                type = "client",
                event = "postal:client:openMenu",
                icon = "fas fa-box",
                label = _U('start_delivery'),
            },
        },
        distance = 2.0,
    })
end)

RegisterNetEvent('postal:client:openMenu', function()
    lib.registerContext({
        id = 'delivery_menu',
        title = 'Delivery Menu',
        options = {
            {
                title = _U('start_delivery'),
                description = 'Start Delivery',
                event = 'postal:client:startDelivery'
            },
            {
                title = _U('drive_faggio'),
                description = 'Rental Faggio ($' .. faggioCost .. ')',
                event = 'postal:client:driveFaggio'
            }
        }
    })

    lib.showContext('delivery_menu')
end)

RegisterNetEvent('postal:client:driveFaggio', function()
    local playerData = QBCore.Functions.GetPlayerData()

    if playerData.money.cash >= faggioCost then
        TriggerServerEvent('postal:server:chargePlayer', faggioCost)

        local playerPed = PlayerPedId()
        local vehicleModel = GetHashKey('faggio')

        RequestModel(vehicleModel)
        while not HasModelLoaded(vehicleModel) do
            Wait(1)
        end

        local vehicle = CreateVehicle(vehicleModel, startLocation.x + 2, startLocation.y, startLocation.z, startLocation.w, true, false)
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1)

        -- プレイヤーに車の鍵を渡す
        TriggerEvent('vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(vehicle))
        lib.notify({
            title = 'Faggio Rented',
            description = _U(''),
            type = 'success'
        })
    else
        lib.notify({
            title = 'Insufficient Funds',
            description = _U('not_enough_money', faggioCost),
            type = 'error'
        })
    end
end)

RegisterNetEvent('postal:client:startDelivery', function()
    if not hasPackage then
        hasPackage = true

        currentDeliveryLocation = Config.DeliveryLocations[math.random(#Config.DeliveryLocations)]

        if deliveryBlip then
            RemoveBlip(deliveryBlip)
        end

        deliveryBlip = AddBlipForCoord(currentDeliveryLocation.x, currentDeliveryLocation.y, currentDeliveryLocation.z)
        SetBlipSprite(deliveryBlip, 514)
        SetBlipColour(deliveryBlip, 3)
        SetBlipRoute(deliveryBlip, true)
        SetBlipRouteColour(deliveryBlip, 3)

        TriggerServerEvent('postal:server:givePackage')
        lib.notify({
            title = 'Package Received',
            description = _U('receive_package'),
            type = 'success'
        })

-- Add target zone at delivery location
deliveryZone = exports['qb-target']:AddBoxZone("delivery_zone", vector3(currentDeliveryLocation.x, currentDeliveryLocation.y, currentDeliveryLocation.z), 1.0, 1.0, {
    name = "delivery_zone",
    heading = currentDeliveryLocation.w,
    debugPoly = false,
    minZ = currentDeliveryLocation.z - 1.0,
    maxZ = currentDeliveryLocation.z + 1.0,
}, {
    options = {
        {
            type = "client",
            event = "postal:client:knockDoor",
            icon = "fas fa-hand-paper",
            label = "Knock on Door",
        },
    },
    distance = 2.0,
})

-- Spawn recipient NPC at delivery location
SpawnRecipientNPC()
else
    lib.notify({ title = 'Error', description = _U('already_have_package'), type = 'error' })
end
end)

function SpawnRecipientNPC()
    if recipientNPC then
        DeleteEntity(recipientNPC)
    end

    local randomModel = Config.RecipientModels[math.random(#Config.RecipientModels)]

    -- Spawn recipient NPC at delivery location
    RequestModel(randomModel)
    while not HasModelLoaded(randomModel) do
        Wait(1)
    end

    recipientNPC = CreatePed(4, randomModel, currentDeliveryLocation.x, currentDeliveryLocation.y, currentDeliveryLocation.z - 1, 0, false, true)
    SetEntityAsMissionEntity(recipientNPC, true, true)
    SetBlockingOfNonTemporaryEvents(recipientNPC, true)
    FreezeEntityPosition(recipientNPC, true) -- Prevent NPC from moving
    SetEntityInvincible(recipientNPC, true)
    SetEntityVisible(recipientNPC, false, false) -- Make NPC invisible initially
end

RegisterNetEvent('postal:client:knockDoor', function()
    if not hasPackage then
        lib.notify({ title = 'Error', description = "You have not accepted any delivery yet!", type = 'error' })
        return
    end

    local ped = PlayerPedId()
    
    -- Load and play animation
    LoadAnimDict('timetable@jimmy@doorknock@')
    TaskPlayAnim(ped, 'timetable@jimmy@doorknock@', 'knockdoor_idle', 8.0, -8.0, -1, 1, 0, false, false, false)
    
    lib.notify({ title = 'Notification', description = "Knocking on the door...", type = 'success' })

    QBCore.Functions.Progressbar("knock_door", "Knocking on the door...", 5000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- On completion
        -- Stop animation
        StopAnimTask(ped, 'timetable@jimmy@doorknock@', 'knockdoor_idle', 1.0)
        
        SetEntityVisible(recipientNPC, true, false) -- Make NPC visible
        lib.notify({ title = 'Notification', description = "The NPC has come outside.", type = 'success' })

        -- Remove target zone
        if deliveryZone then
            exports['qb-target']:RemoveZone("delivery_zone")
            deliveryZone = nil
        end

        -- Add target to recipient NPC
        exports['qb-target']:AddTargetEntity(recipientNPC, {
            options = {
                {
                    type = "client",
                    event = "postal:client:deliverPackage",
                    icon = "fas fa-hand-holding",
                    label = "Deliver Newspaper",
                },
            },
            distance = 2.0,
        })
    end)
end)

function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(1)
    end
end

RegisterNetEvent('postal:client:deliverPackage', function()
    if hasPackage then
        local ped = PlayerPedId()
        
        -- Player animation
        LoadAnimDict('pickup_object')
        TaskPlayAnim(ped, 'pickup_object', 'putdown_low', 5.0, 1.5, 1.0, 48, 0.0, 0, 0, 0)
        Wait(700)
        StopAnimTask(ped, 'pickup_object', 'putdown_low', 1.0)

        -- Player carries box
        LoadAnimDict("anim@heists@box_carry@")
        TaskPlayAnim(ped, "anim@heists@box_carry@", "idle", 8.0, -8.0, -1, 50, 0, false, false, false)

        -- Attach box prop to player
        local playerBox = CreateObject(GetHashKey("hei_prop_heist_box"), 0, 0, 0, true, true, true)
        AttachEntityToEntity(playerBox, ped, GetPedBoneIndex(ped, 60309), 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)

        QBCore.Functions.Progressbar("deliver_newspaper", "Delivering newspaper...", 12000, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {}, {}, {}, function() -- On completion
            -- Player drops box
            StopAnimTask(ped, "anim@heists@box_carry@", "idle", 1.0)
            DeleteObject(playerBox)

            -- NPC animation
            LoadAnimDict("anim@heists@box_carry@")
            TaskPlayAnim(recipientNPC, "anim@heists@box_carry@", "idle", 8.0, -8.0, -1, 1, 0, false, false, false)

            -- Attach box prop to NPC
            boxProp = CreateObject(GetHashKey("hei_prop_heist_box"), 0, 0, 0, true, true, true)
            AttachEntityToEntity(boxProp, recipientNPC, GetPedBoneIndex(recipientNPC, 60309), 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)

            TriggerServerEvent('postal:server:receiveReward')
            lib.notify({ title = 'Delivery Complete', description = _U('delivery_complete'), type = 'success' })

            if deliveryBlip then
                RemoveBlip(deliveryBlip)
            end

            -- Delete NPC after 3 seconds
            Citizen.SetTimeout(3000, function()
                if recipientNPC then
                    DeleteEntity(recipientNPC)
                end
            end)

            hasPackage = false

            -- Delete box prop after 10 seconds
            Citizen.SetTimeout(10000, function()
                if boxProp then
                    DeleteObject(boxProp)
                    boxProp = nil
                end
            end)
        end, function() -- On cancel
            DeleteObject(playerBox)
            if boxProp then
                DeleteObject(boxProp)
                boxProp = nil
            end
            lib.notify({ title = 'Delivery Cancelled', description = _U('delivery_cancelled'), type = 'error' })
        end)
    else
        lib.notify({ title = 'No Package', description = _U('no_package'), type = 'error' })
    end
end)

if Config.blipsShow then
    CreateThread(function()
        for _,v in pairs(Config.Locations) do
            local blip = AddBlipForCoord(v.vector)
            SetBlipSprite(blip, v.sprite)
            SetBlipScale(blip, v.scale)
            SetBlipColour(blip, v.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.text)
            EndTextCommandSetBlipName(blip)
        end
    end)
end
