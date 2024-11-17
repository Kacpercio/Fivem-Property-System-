local haveBought;
local time2 
local todayTime2
local timejeden
local timedwa
local getInput
local inside = true

Citizen.CreateThread(function()
    for k, conf in pairs(Config.Targets) do
        exports['ox_target']:addBoxZone({
            coords = conf.coords,
            distance = conf.length,
            rotation = conf.rotation,
            debug = conf.debugPoly,
            size = conf.size,
            name = conf.name,
            options = conf.options
        })
    end
        exports['ox_target']:addBoxZone({
            coords = vec3(-934.82, -1522.86, 5.18),
            distance = 0.5,
            rotation = -70,
            debug = false,
            size = vec3(2.4, 2.0, 3),
            name = 'WEJDŹ APARTY',
            options = {
                {
                    event = "property:enter",
                    icon = "fas fa-sign-in-alt",
                    label = "Wejdź",
                    distance = 3,
                    canInteract = function()
                        if time2 >= todayTime2 - 86400 then
                            haveBought = true
                             inside = false
                            return true
                        else 
                            haveBought = false
                            return false
                        end
                    end
                },
                {
                    event = 'property:rentHome',
                    icon = 'fa-solid fa-cart-shopping',
                    label = 'Wynajmij Mieszkanie (cena wynajmu 1500$)',
                    distance = 3,
                    canInteract = function()
                        if not haveBought then 
                            return true
                        else 
                            return false
                        end
                    end
                },
                {
                    event = 'property:RErentHome',
                    icon = 'fa-solid fa-cart-shopping',
                    label = 'Przedłuż Wynajem Mieszkania',
                    canInteract = function()
                            --return haveBought
                            return false
                    end
                }
            }
        })
end)

Citizen.CreateThread(function()
    RegisterNetEvent('esx:playerLoaded')
    AddEventHandler('esx:playerLoaded',function()
        ESX.TriggerServerCallback('getData', function(time)
            time2 = time[1].time
        end)
        ESX.TriggerServerCallback('getTodayDate', function(todayTime)
            todayTime2 = todayTime
        end)

        local function insideZone()
            local playerPed = PlayerPedId()
            if inside then
                SetEntityCoords(playerPed, Config.Exit[1], Config.Exit[2], Config.Exit[3])
                SetEntityHeading(playerPed, Config.Exit[4])
                inside = false
            end
        end
        
        lib.zones.box {
            coords = vec3(260.97, -997.92, -99.01),
            size = vec3(20.2, 14.6, 80),
            rotation = 0,
            debug = false,
            inside = insideZone,
        }
    end)

    while true do
        ESX.TriggerServerCallback('getData', function(time)
            if time[1] ~= nil then
                time2 = time[1].time
            end
        end)
        ESX.TriggerServerCallback('getTodayDate', function(todayTime)
            todayTime2 = todayTime
        end)
        Citizen.Wait(300 * 1000)
    end
end)

Citizen.CreateThread(function()

    for _, info in pairs(Config.Blipy) do
      info.blip = AddBlipForCoord(info.x, info.y, info.z)
      SetBlipSprite(info.blip, info.id)
      SetBlipDisplay(info.blip, 4)
      SetBlipScale(info.blip, 0.7)
      SetBlipColour(info.blip, info.colour)
      SetBlipAsShortRange(info.blip, true)
	  BeginTextCommandSetBlipName("STRING")
      AddTextComponentString(info.title)
      EndTextCommandSetBlipName(info.blip)
    end
end)
Citizen.CreateThread(function()
    RegisterNetEvent('property:rentHome')
    AddEventHandler('property:rentHome', function()
        local input = lib.inputDialog('Menu Wynajmu', {
            {type = 'date-range', label = 'Data Wynajmu:', icon = {'far', 'calendar'}, deafult = true, required = true, format = "DD/MM/YYYY", clearable = true}
        })
        if not input[1] then
            return ESX.ShowNotification('Wybierz poprawną datę!')
        end
        getInput = input[1]
        ESX.TriggerServerCallback('property:checkDateCorrect', function(status)
            if status.getReturn then
                timejeden = status.getData1
                timedwa = status.getData2
                local h = timedwa - timejeden
                local nig = h / 3600
                local d = nig / 24
                local moneyPay = 1500 * d
                lib.registerContext({
                    id = 'pay_menu',
                    title = 'Menu zapłaty',
                    options = {
                      {
                        title = 'Zakup',
                        description = 'Cena jest wyświetlona po najechaniu na przycisk',
                        icon = 'shop',
                        onSelect = function()
                            local alertPay = lib.alertDialog({
                                header = 'Potwierdzenie',
                                content = 'Czy na pewno chce wynająć mieszkanie?',
                                centered = true,
                                cancel = true
                            })
                            if alertPay == 'confirm' then 
                                TriggerServerEvent('pay', moneyPay)
                            end
                        end,
                        metadata = {
                          {label = 'Cena', value = moneyPay.."$"},
                        },
                      },
                    }
                  })
                lib.showContext('pay_menu')
            end
        end, input[1])
    end)
end)
--[[
RegisterNetEvent('property:RErentHome')
AddEventHandler('property:RErentHome', function()
    local dataTake =  {}
    local input = lib.inputDialog('Menu Przedłużenia Wynajmu', {
        {type = 'date-range', label = 'Data Wynajmu:', icon = {'far', 'calendar'}, deafult = true, required = true, format = "DD/MM/YYYY", clearable = true}
    })
    if not input[1] then
        return ESX.ShowNotification('Wybierz poprawną datę!')
    end
    getInput = input[1]
    table.insert(dataTake, input[1])
    ESX.TriggerServerCallback('getReturn', function(cbThat)
        table.insert(dataTake, cbThat)
        ESX.TriggerServerCallback('property:checkDateCorrectReRent', function(status)

            if status.getReturn then
                timejeden = status.getData1
                timedwa = status.getData2
                local h = timedwa - timejeden
                local nig = h / 3600
                local d = nig / 24
                local moneyPay = 1500 * d
                lib.registerContext({
                    id = 'RePay_menu',
                    title = 'Menu zapłaty',
                    options = {
                    {
                        title = 'Zakup',
                        description = 'Cena jest wyświetlona po najechaniu na przycisk',
                        icon = 'shop',
                        onSelect = function()
                            local alertPay = lib.alertDialog({
                                header = 'Potwierdzenie',
                                content = 'Czy na pewno chce przedłużyć wynajem mieszkania?',
                                centered = true,
                                cancel = true
                            })
                            if alertPay == 'confirm' then 
                                TriggerServerEvent('pay', moneyPay)
                            end
                        end,
                        metadata = {
                        {label = 'Cena', value = moneyPay.."$"},
                        },
                    },
                    }
                })
                lib.showContext('RePay_menu')
            end
        end, dataTake)
    end)
end)
]]--
RegisterNetEvent('afterpay')
AddEventHandler('afterpay', function()
    ESX.TriggerServerCallback('getReturn', function(info)
        if next(info) == nil then
            ESX.TriggerServerCallback('insertData', function()             
            end, getInput)
        else
            ESX.TriggerServerCallback('updateData', function() 
            end, getInput)
        end
        haveBought = true
    end)
    Citizen.Wait(100)
    ESX.TriggerServerCallback('getData', function(time)
        time2 = time[1].time
    end)
    ESX.TriggerServerCallback('getTodayDate', function(todayTime)
        todayTime2 = todayTime
    end)
end)

RegisterNetEvent("property:enter", function()
    DoScreenFadeOut(50)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, Config.Enter[1], Config.Enter[2], Config.Enter[3])
    local interiorId = GetInteriorFromEntity(PlayerPedId())
    RequestCollisionAtCoord(interiorId)
    Wait(500)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, Config.Enter[1], Config.Enter[2], Config.Enter[3])
    SetEntityHeading(playerPed, Config.Enter[4])
    TriggerServerEvent("property:enter")
    Wait(500)
    DoScreenFadeIn(50)
end)

RegisterNetEvent("property:exit", function()
    DoScreenFadeOut(50)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, Config.Exit[1], Config.Exit[2], Config.Exit[3])
    SetEntityHeading(playerPed, Config.Exit[4])
    TriggerServerEvent("property:exit")
    Wait(500)
    DoScreenFadeIn(50)
end)

RegisterNetEvent("property:stash", function()
    local ox_inventory = exports.ox_inventory
    local identifier = ESX.GetPlayerData().identifier
    TriggerServerEvent('property:loadStash')
    TriggerServerEvent('property:forceOpen')
end)

RegisterNetEvent("property:getClothes", function()
	ESX.TriggerServerCallback('property:getPlayerDressing', function(dressing)
		local elements = {}
		for k,v in pairs(dressing) do
			elements[#elements + 1] =  {label = v.label, value = v.clothes, value2 = k}
		end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'dress_menu',{
			title    = 'Przebierz się',
			align    = 'center',
			elements = elements
		}, function(data, menu)
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerEvent('skinchanger:loadClothes', skin, data.current.value)
                TriggerEvent('esx_skin:setLastSkin', skin)
                --TriggerEvent('skinchanger:loadSkin', skin)

                TriggerEvent('skinchanger:getSkin', function(skin)
                    TriggerServerEvent('esx_skin:save', skin)
                end)
            end)
        end, function(data, menu)
            menu.close()
        end)
    end)
end)

RegisterNetEvent("property:removeClothes", function()
    ESX.TriggerServerCallback('property:getPlayerDressing', function(dressing)
		local elements = {}
		for k,v in pairs(dressing) do
			elements[#elements + 1] = {label = v.label, value = v.clothes, value2 = k}
		end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'dress_menu',{
			title    = 'Usuń ubranie',
			align    = 'center',
			elements = elements
		}, function(data, menu)
            menu.close()
            TriggerServerEvent('property:removeOutfit', data.current.value2)
            TriggerEvent("property:removeClothes")
            ESX.ShowNotification('~g~Ubranie pod nazwą: ~g~'..data.current.label..' zostało usunięte')
        end, function(data, menu)
            menu.close()
        end)
    end)
end)

RegisterNetEvent("property:addClothes", function()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'outfit_name', {
        title = "Podaj nazwę"
    }, function(data, menu)
        menu.close()
        if data.value then
            TriggerEvent('skinchanger:getSkin', function(skin)
                TriggerServerEvent('property:saveOutfit', data.value, skin)
                ESX.ShowNotification('~g~Ubranie zostalo zapisane pod nazwą: ~g~'..data.value)
            end)
        end
    end, function(data, menu)
        menu.close()
    end)
end)

--[[
RegisterNetEvent('MainCLMenu')
AddEventHandler('MainCLMenu', function(data)
    ESX.TriggerServerCallback('getData2', function (Database)

    lib.registerContext({

    })

    lib.registerContext({
        id = 'MenuMain',
        title = 'Menu Zarządzania',
        options = {
          {
            title = 'Ulepszenie szafki',
            description = 'Zwiększ wage oraz ilość slotów w szafce',
            icon = 'house',
            onSelect = function()
                local alertPay = lib.alertDialog({
                    header = 'Potwierdzenie',
                    content = 'Czy na pewno chcesz ulepszyć szafkę?',
                    centered = true,
                    cancel = true
                })
                if alertPay == 'confirm' then 
                    ESX.TriggerServerCallback('updateInventoryData', function() 
                    end, 1)
                end
            end,
            metadata = {
              {label = 'Aktualny lvl szafki ', value = Database[1].lvl_szafki},
            },
          },
          {
            title = 'Ceny Szafek',
            description = 'Sprawdź ceny poszczególnych lvl szafki',
            icon = 'cart',
            menu = ''
          }
        }
      })

    end)
    lib.showContext('MenuMain')
end)
]]--