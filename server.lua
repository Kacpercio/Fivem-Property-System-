RegisterNetEvent("property:enter", function()
    local _source = source
    SetPlayerRoutingBucket(_source, (1000 + _source))
end)

RegisterNetEvent("property:exit", function()
    local _source = source
    SetPlayerRoutingBucket(_source, 0)
end)

RegisterNetEvent("property:loadStash", function()
    local _source = source
    local ox_inventory = exports.ox_inventory
    local identifier = ESX.GetPlayerFromId(_source).identifier
    ox_inventory:RegisterStash("playerFreeProperty-" .. identifier, "Mieszkanie", 50, 100000, true, false, false)
end)

RegisterNetEvent('property:forceOpen', function()
    local _source = source
    local identifier = ESX.GetPlayerFromId(_source).identifier
    exports.ox_inventory:forceOpenInventory(_source, 'stash', { id = "playerFreeProperty-" .. identifier, owner = identifier })
end)

RegisterNetEvent("property:saveOutfit", function(label, skin)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local identifier = ESX.GetPlayerFromId(_source).identifier
    TriggerEvent('esx_datastore:getDataStore', 'property', identifier, function(store) 
        local dressing = store.get('dressing')
        if dressing == nil then
            dressing = {}
        end
        local count  = store.count('dressing')
        for i=1, count, 1 do
            local entry = store.get('dressing', i)
            if entry.label == label then
                xPlayer.showNotification('~r~W szafce znajduje się już strój pod taką nazwą!')
                return
            end
        end
        if #dressing < 20 then
            dressing[#dressing + 1] = {
                label = label,
                skin  = skin
            }
            store.set('dressing', dressing)
        else
            xPlayer.showNotification('~r~W szafie nie ma miejsc na więcej ubrań!')		
        end
    end)
end)

RegisterNetEvent("property:removeOutfit", function(label)
    local _source = source
    local identifier = ESX.GetPlayerFromId(_source).identifier
    TriggerEvent('esx_datastore:getDataStore', 'property', identifier, function(store)
        local dressing = store.get('dressing') or {}
        table.remove(dressing, label)
        store.set('dressing', dressing)
    end)
end)

ESX.RegisterServerCallback("property:getPlayerDressing", function(source, cb)
    local _source = source
    local identifier = ESX.GetPlayerFromId(_source).identifier
    TriggerEvent('esx_datastore:getDataStore', 'property', identifier, function(store)
        local labels = {}
        local count  = store.count('dressing')
        for i=1, count, 1 do
            local entry = store.get('dressing', i)
            labels[#labels + 1] = {label = entry.label, clothes = entry.skin}
        end
        cb(labels)
    end)
end)

ESX.RegisterServerCallback("property:checkDateCorrect", function(source, cb, data)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer ~= nil then
        local currentTime = os.time()
        local timestamp = math.floor(data[1] / 1000)
        local maxDays = 30

        if timestamp > currentTime + 700 then 
            xPlayer.showNotification('Wybierz poprawną początkową datę wynajmu!')  
            cb(false)
        elseif timestamp + 86400 < currentTime then
            xPlayer.showNotification('Wybierz poprawną datę!')  
            cb(false)
        elseif timestamp > currentTime - 86400 then
            cb({
                getReturn = true,
                getData1 = data[1] / 1000,
                getData2 = data[2] / 1000
            })
        elseif timestamp > math.floor(currentTime * (maxDays * 86400)) then
            xPlayer.showNotification('Możesz makysmalnie na 30 dni do przodu!')
            cb(false)
        end
    else
        cb(false)
    end
end)
--[[
ESX.RegisterServerCallback("property:checkDateCorrectReRent", function(source, cb, data)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    print(ESX.DumpTable(data))
    if xPlayer ~= nil then
        local currentTime = os.time()
        for k, v in ipairs(data) do
            local timestamp = math.floor(v[1] / 1000)
            local maxDays = 30
            print(ESX.DumpTable(timestamp))
            if timestamp > v[2] + 700 then 
                xPlayer.showNotification('Wybierz poprawną początkową datę wynajmu!')  
                cb(false)
            elseif timestamp + 86400 < v[2] then
                xPlayer.showNotification('Wybierz poprawną datę!')  
                cb(false)
            elseif timestamp > v[2] - 86400 then
                cb({
                    getReturn = true,
                    getData1 = data[1] / 1000,
                    getData2 = data[2] / 1000
                })
            elseif timestamp > math.floor(v[2] * (maxDays * 86400)) then
                xPlayer.showNotification('Możesz makysmalnie na 30 dni do przodu!')
                cb(false)
            end
        end
    else
        cb(false)
    end
end)
]]--
RegisterServerEvent('pay')
AddEventHandler('pay', function(days)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	local itemcheck = xPlayer.getInventoryItem('money')

    if itemcheck.count >= days then 
        xPlayer.removeInventoryItem('money', days)
        TriggerClientEvent('afterpay', _source)
    else 
        xPlayer.showNotification('Nie masz wystarczająco pieniędzy przy sobie!')  
    end
end)

RegisterServerEvent('invSV')
AddEventHandler('invSV', function(source)
    local playerName = GetPlayerName(source)

    TriggerClientEvent('invCLMenu', source, playerName)
end)

RegisterServerEvent('SetPlayerRoutingBucketForInv')
AddEventHandler('SetPlayerRoutingBucketForInv', function(source2)
    local sourcve = source
    SetPlayerRoutingBucket(source2, (1000 + sourcve))
end)

ESX.RegisterServerCallback('getTodayDate', function(source, cb)
    cb(os.time())
end)

ESX.RegisterServerCallback('insertData', function(source, cb, date)
    local xPlayer = ESX.GetPlayerFromId(source)
    local timestamp = math.floor(date[2] / 1000)
    
    MySQL.insert('INSERT INTO `SinisterSocjalne` (owner, time, lvl_szafki) VALUES (@owner,@time,@lvl_szafki)', {
        ['@owner'] = xPlayer.identifier,
        ['@time'] = timestamp,
        ['@lvl_szafki'] = 0, 
    })
end)

ESX.RegisterServerCallback('updateData', function(source, cb, date)
    local xPlayer = ESX.GetPlayerFromId(source)
    local timestamp = math.floor(date[2] / 1000)

    MySQL.update('UPDATE SinisterSocjalne SET time = @time WHERE owner = @owner', {
        ['@owner'] = xPlayer.identifier,
        ['@time'] = timestamp
    })
end)

ESX.RegisterServerCallback('getReturn', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer ~= nil then 
        MySQL.query('SELECT time FROM SinisterSocjalne WHERE owner = @owner', {
            ['@owner'] = xPlayer.identifier
        }, function(result)
            cb(result)
        end)
    end
end)

ESX.RegisterServerCallback('getData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer ~= nil then 
        MySQL.query('SELECT time FROM SinisterSocjalne WHERE owner = @owner', {
            ['@owner'] = xPlayer.identifier
        }, function(result)
            cb(result)
        end)
    end
end)

ESX.RegisterServerCallback('getData2', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer ~= nil then 
        MySQL.query('SELECT lvl_szafki FROM SinisterSocjalne WHERE owner = @owner', {
            ['@owner'] = xPlayer.identifier
        }, function(result)
            cb(result)
        end)
    end
end)

ESX.RegisterServerCallback('updateInventoryData', function(source, cb, data)
    local xPlayer = ESX.GetPlayerFromId(source)

    MySQL.update('UPDATE SinisterSocjalne SET lvl_szafki = @lvl_szafki WHERE owner = @owner', {
        ['@owner'] = xPlayer.identifier,
        ['@lvl_szafki'] = data
    })
end)