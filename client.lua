local QBCore = exports['qb-core']:GetCoreObject()
local ArmoryPed = nil

CreateThread(function()
    RequestModel(GetHashKey(Config.PedModel))
    while not HasModelLoaded(GetHashKey(Config.PedModel)) do Wait(10) end

    ArmoryPed = CreatePed(4, GetHashKey(Config.PedModel), Config.PedCoords.x, Config.PedCoords.y, Config.PedCoords.z - 1.0, Config.PedCoords.w, false, true)
    FreezeEntityPosition(ArmoryPed, true)
    SetEntityInvincible(ArmoryPed, true)
    SetBlockingOfNonTemporaryEvents(ArmoryPed, true)
    
    TaskStartScenarioInPlace(ArmoryPed, Config.PedScenario, 0, true)

    exports['qb-target']:AddTargetEntity(ArmoryPed, {
        options = {
            {
                type = "client",
                action = function()
                    OpenArmoryMenu()
                end,
                icon = "fas fa-shield-alt",
                label = "عهدة وزارة الداخلية",
                job = Config.RequiredJob
            }
        },
        distance = 2.0
    })
end)

function OpenArmoryMenu()
    QBCore.Functions.TriggerCallback('hrp-911-3hda:server:getArmoryData', function(data)
        if data then
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "open",
                items = data.items,
                cooldown = data.cooldown,
                price = Config.PricePerItem
            })
        else
            QBCore.Functions.Notify('❌ مخصص لمنتسبي وزارة الداخلية فقط', 'error', 5000)
        end
    end)
end

RegisterNUICallback('closeUI', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('claimItem', function(data, cb)
    TriggerServerEvent('hrp-911-3hda:server:claimItem', data.item, tonumber(data.amount))
    cb('ok')
end)

RegisterNetEvent('hrp-911-3hda:client:updateStock', function(data)
    SendNUIMessage({
        action = "update",
        items = data.items,
        cooldown = data.cooldown
    })
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if DoesEntityExist(ArmoryPed) then DeleteEntity(ArmoryPed) end
end)