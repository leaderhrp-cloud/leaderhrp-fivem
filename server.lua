local QBCore = exports['qb-core']:GetCoreObject()

-- دالة فحص وتحديث المخزون ومؤقت الـ 24 ساعة
local function checkAndResetStock(Player)
    local armoryData = Player.PlayerData.metadata["hrp_armory"] or {}
    local currentTime = os.time()

    if not armoryData.reset_time or currentTime >= armoryData.reset_time then
        armoryData = {
            reset_time = currentTime + 86400,
            stock = {}
        }
        for item, info in pairs(Config.Items) do
            armoryData.stock[item] = info.max
        end
        Player.Functions.SetMetaData("hrp_armory", armoryData)
    else
        local needsUpdate = false
        if not armoryData.stock then armoryData.stock = {} end
        
        for item, info in pairs(Config.Items) do
            if armoryData.stock[item] == nil then
                armoryData.stock[item] = info.max
                needsUpdate = true
            end
        end

        if needsUpdate then
            Player.Functions.SetMetaData("hrp_armory", armoryData)
        end
    end

    return armoryData
end

QBCore.Functions.CreateCallback('hrp-911-3hda:server:getArmoryData', function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or Player.PlayerData.job.name ~= Config.RequiredJob then return cb(nil) end

    local armoryData = checkAndResetStock(Player)
    local remainingTime = armoryData.reset_time - os.time()

    local clientItems = {}
    for item, info in pairs(Config.Items) do
        clientItems[item] = {
            label = info.label,
            max = info.max,
            current = armoryData.stock[item] or 0
        }
    end

    cb({ items = clientItems, cooldown = remainingTime })
end)

RegisterNetEvent('hrp-911-3hda:server:claimItem', function(item, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    
    -- حماية السيرفر الصارمة
    if not Player or Player.PlayerData.job.name ~= Config.RequiredJob then 
        DropPlayer(src, "محاولة استغلال ثغرة عهدة الشرطة!")
        return 
    end
    
    amount = tonumber(amount) or 1
    if not Config.Items[item] or amount <= 0 then return end

    local armoryData = checkAndResetStock(Player)
    local currentStock = armoryData.stock[item] or 0

    if amount > currentStock then
        TriggerClientEvent('QBCore:Notify', src, '❌ الكمية المطلوبة تتجاوز المسموح لك به حالياً في العهدة!', 'error', 4000)
        return
    end

    local totalPrice = amount * Config.PricePerItem
    local bankBalance = Player.Functions.GetMoney('bank')

    if bankBalance < totalPrice then
        TriggerClientEvent('QBCore:Notify', src, '❌ رصيدك البنكي لا يغطي رسوم تجهيز العهدة!', 'error', 4000)
        return
    end

    Player.Functions.RemoveMoney('bank', totalPrice, "armory-fee")
    Player.Functions.AddItem(item, amount)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add")

    armoryData.stock[item] = currentStock - amount
    Player.Functions.SetMetaData("hrp_armory", armoryData)

    TriggerClientEvent('QBCore:Notify', src, '👮‍♂️ تم صرف '..amount..'x من '..Config.Items[item].label..' بنجاح.', 'success', 4000)

    local remainingTime = armoryData.reset_time - os.time()
    local clientItems = {}
    for k, info in pairs(Config.Items) do
        clientItems[k] = {
            label = info.label,
            max = info.max,
            current = armoryData.stock[k] or 0
        }
    end

    TriggerClientEvent('hrp-911-3hda:client:updateStock', src, { items = clientItems, cooldown = remainingTime })
end)