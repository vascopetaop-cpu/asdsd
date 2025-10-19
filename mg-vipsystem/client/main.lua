local isMenuOpen = false
function _U(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    else
        return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
    end
end


Citizen.CreateThread(function()
    Framework = GetCore()
    if not Config.GiveItemsToPlayer then
        InteractionHandler()
    end
    RegisterCommand(Config.Commands.openMenu, function()
        if not isMenuOpen then
            OpenVIPMenu()
        else
            CloseVIPMenu()
        end
    end, false)

    if Config.UseKeyBind then
        RegisterKeyMapping(Config.Commands.openMenu, _U('command_vip_help'), 'keyboard', Config.KeyBind)
    end
    Debug("^5[mg-vipsystem] ^2 Client Side Successfully loaded^0")
end)
function OpenVIPMenu()
    if isMenuOpen then return end
    isMenuOpen = true
    SetNuiFocus(true, true)
    
    TriggerServerEvent('mg-vipsystem:getPlayerData')
    SendNUIMessage({
        action = 'openMenu',
        style = Config.UISettings.style or 'classic',
        locales = Locales[Config.Locale],
        config = {
            ServerLogo = Config.UISettings.ServerLogo,
            currency = Config.CurrencyName,
            locale = Locales[Config.Locale],
            vipTiers = Config.VIPTiers,
            featuredOffers = Config.FeaturedOffers,
            itemsFilters = Config.ItemsFilters,
            items = Config.VIPItems,
            vehiclesFilters = Config.VehiclesFilters,
            vehicles = Config.VIPVehicles,
            weaponsFilters = Config.WeaponsFilters,
            weapons = Config.VIPWeapons,
            moneyExchange = Config.MoneyExchange,
            uiSettings = Config.UISettings,
            testDriveEnabled = Config.TestDriveEnabled,
            tiersEnabled = Config.TiersEnabled,
            vipItemsEnabled = Config.VIPItemsEnabled,
            vipVehiclesEnabled = Config.VIPVehiclesEnabled,
            vipWeaponsEnabled = Config.VIPWeaponsEnabled,
            moneyExchangeEnabled = Config.MoneyExchangeEnabled,
            mlos = Config.MloList,
            mloEnabled = Config.MloEnabled,
            featuredOffersEnabled = Config.FeaturedOffersEnabled,
            tebexLink = Config.TebexLink,
            defaultImage = Config.DefaultImage
        }
    })
    
    if Config.UISettings.enableSounds then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
    end
end
RegisterNetEvent('mg-vipsystem:openVipStash', function(stashID)
    Debug('^5[mg-vipsystem] ^0Opening VIP Stash with ID:'.. stashID)
    OpenStash(stashID)
end)

local activeTestDriveVehicle = nil
local previousTestDriveCoords = nil

RegisterNetEvent('mg-vipsystem:testDrive', function(vehicleIndex)
    if not Config.TestDriveEnabled then
        Config.ClientNotification(_U('test_drive_disabled'), 'error')
        return
    end

    local vehicleData = Config.VIPVehicles[vehicleIndex]
    if not vehicleData then
        Config.ClientNotification(_U('invalid_vehicle'), 'error')
        return
    end

    if IsPedInAnyVehicle(PlayerPedId(), false) then
        Config.ClientNotification(_U('already_in_vehicle'), 'error')
        return
    end
    local playerId = GetPlayerServerId(PlayerId())
    local bucketId = 1000 + playerId
    TriggerServerEvent("mg-vipsystem:setBucket", bucketId)
    Wait(500)

    local ped = PlayerPedId()
    previousTestDriveCoords = GetEntityCoords(ped)

    local model = GetHashKey(vehicleData.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local veh = CreateVehicle(model, Config.TestDriveLocation.x, Config.TestDriveLocation.y, Config.TestDriveLocation.z, Config.TestDriveLocation.w, true, false)
    SetEntityAsMissionEntity(veh, true, true)
    TaskWarpPedIntoVehicle(ped, veh, -1)
    SetVehicleNumberPlateText(veh, Config.TestDriveVehiclePlate)

    activeTestDriveVehicle = veh

    local duration = Config.TestDriveDuration or 300
    local endTime = GetGameTimer() + (duration * 1000)
    CloseVIPMenu()
    SendNUIMessage({
        action = 'startTestDrive',
        duration = duration,
        finishKey = Config.TestDriveEndKey,
    })
    if Config.VehicleKeySystem then
        Config.GiveVehicleKey(veh, Config.TestDriveVehiclePlate)
    end
    CreateThread(function()
        while DoesEntityExist(veh) and GetGameTimer() < endTime do
            Wait(1000)
            if not IsPedInAnyVehicle(ped, false) and Config.CancelTestDriveOnExit then
                CancelTestDrive()
                break
            end
        end

        if DoesEntityExist(activeTestDriveVehicle) then
            CancelTestDrive()
        end
    end)
end)
function CancelTestDrive()
    local ped = PlayerPedId()

    if activeTestDriveVehicle and DoesEntityExist(activeTestDriveVehicle) then
        TaskLeaveVehicle(ped, activeTestDriveVehicle, 0)
        local timeout = GetGameTimer() + 5000
        while IsPedInVehicle(ped, activeTestDriveVehicle, false) and GetGameTimer() < timeout do
            Wait(100)
        end
        NetworkRequestControlOfEntity(activeTestDriveVehicle)
        local timeout = GetGameTimer() + 2000
        while not NetworkHasControlOfEntity(activeTestDriveVehicle) and GetGameTimer() < timeout do
            Wait(0)
        end

        SetEntityAsMissionEntity(activeTestDriveVehicle, true, true)
        DeleteVehicle(activeTestDriveVehicle)
    end
    if Config.VehicleKeySystem and Config.RemoveKey then
        Config.RemoveVehicleKey(activeTestDriveVehicle)
    end
    TriggerServerEvent("mg-vipsystem:resetBucket")

    if previousTestDriveCoords then
        SetEntityCoords(ped, previousTestDriveCoords.x, previousTestDriveCoords.y, previousTestDriveCoords.z)
    end
    SendNUIMessage({
        action = 'endTestDrive'
    })
    if activeTestDriveVehicle then
        Config.ClientNotification(_U('test_drive_ended'), 'info')
    end

    activeTestDriveVehicle = nil
    previousTestDriveCoords = nil
end
RegisterCommand(Config.Commands.finishTestDrive, function()
    if activeTestDriveVehicle then
        CancelTestDrive()
    end
end, false)

RegisterKeyMapping(Config.Commands.finishTestDrive, _U('finish_test_drive'), "keyboard", Config.TestDriveEndKey or "BACK")

function CloseVIPMenu()
    if not isMenuOpen then return end
    
    isMenuOpen = false
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        action = 'closeMenu'
    })
    
    if Config.UISettings.enableSounds then
        PlaySoundFrontend(-1, "CANCEL", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
    end
end

RegisterNUICallback('closeMenu', function(data, cb)
    CloseVIPMenu()
    cb('ok')
end)

RegisterNUICallback('redeemDiamonds', function(data, cb)
    local transactionId = data.transactionId
    if not transactionId or transactionId == '' then
        Config.ClientNotification(_U('invalid_transaction'), 'error')
        cb({success = false})
        return
    end
    
    TriggerServerEvent('mg-vipsystem:redeemTransaction', transactionId)
    cb({success = true})
end)

RegisterNUICallback('purchaseItem', function(data, cb)
    TriggerServerEvent('mg-vipsystem:purchaseItem', data.index+1, data.type)
    cb('ok')
end)

RegisterNUICallback('purchaseVehicle', function(data, cb)
    TriggerServerEvent('mg-vipsystem:purchaseVehicle', data.index+1)
    cb('ok')
end)

RegisterNUICallback('purchaseWeapon', function(data, cb)
    TriggerServerEvent('mg-vipsystem:purchaseWeapon', data.index+1)
    cb('ok')
end)

RegisterNUICallback('exchangeMoney', function(data, cb)
    TriggerServerEvent('mg-vipsystem:exchangeMoney', data.index+1)
    cb('ok')
end)

RegisterNUICallback('purchaseTier', function(data, cb)
    TriggerServerEvent('mg-vipsystem:purchaseTier', data.index+1)
    cb('ok')
end)

RegisterNUICallback('clearPurchaseHistory', function(data, cb)
    TriggerServerEvent('mg-vipsystem:clearPurchaseHistory')
    cb('ok')
end)
RegisterNUICallback('playSound', function(data, cb)
    if Config.UISettings.enableSounds then
        PlaySoundFrontend(-1, data.sound or "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
    end
    cb('ok')
end)
RegisterNUICallback('testDrive', function(data, cb)
    TriggerEvent('mg-vipsystem:testDrive', data.index+1)
    cb('ok')
end)
RegisterNUICallback('purchaseMlo', function(data, cb)
    TriggerServerEvent('mg-vipsystem:purchaseMlo', data.index+1)
    cb('ok')
end)


RegisterNetEvent('mg-vipsystem:updatePlayerData', function(data)
    SendNUIMessage({
        action = 'updatePlayerData',
        data = data
    })
end)

RegisterNetEvent('mg-vipsystem:transactionResult', function(success, message, diamonds)
    if success then
        Config.ClientNotification(message or _U('redeem_success'), 'success')
        SendNUIMessage({
            action = 'updateDiamonds',
            diamonds = diamonds
        })
    else
        Config.ClientNotification(message or _U('redeem_failed'), 'error')
    end
    
    SendNUIMessage({
        action = 'transactionResult',
        success = success,
        message = message
    })
end)

RegisterNetEvent('mg-vipsystem:purchaseResult', function(success, message, itemType, newBalance)
    if success then
        Config.ClientNotification(message or _U('purchase_successful'), 'success')
        SendNUIMessage({
            action = 'updateDiamonds',
            diamonds = newBalance
        })
    else
        Config.ClientNotification(message or _U('purchase_failed'), 'error')
    end
    
    SendNUIMessage({
        action = 'purchaseResult',
        success = success,
        message = message,
        itemType = itemType
    })
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        if isMenuOpen then
            CloseVIPMenu()
        end
    end
end)