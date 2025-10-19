Citizen.CreateThread(function()
    Framework = GetCore()
end)

function ExecuteSql(query, parameters)
    local IsBusy = true
    local result = nil
    if Config.SQL == "autodetect" then
        if GetResourceState("oxmysql") == "started" then
            Config.SQL = "oxmysql"
        elseif GetResourceState("ghmattimysql") == "started" then
            Config.SQL = "ghmattimysql"
        elseif GetResourceState("mysql-async") == "started" then
            Config.SQL = "mysql-async"
        else
            print("^5[mg-vipsystem] ^1ERROR: No SQL System found!^0")
            return nil
        end
    end

    if Config.SQL == "oxmysql" then
        if parameters then
            exports.oxmysql:execute(query, parameters, function(data)
                result = data
                IsBusy = false
            end)
        else
            exports.oxmysql:execute(query, function(data)
                result = data
                IsBusy = false
            end)
        end
    elseif Config.SQL == "ghmattimysql" then
        if parameters then
            exports.ghmattimysql:execute(query, parameters, function(data)
                result = data
                IsBusy = false
            end)
        else
            exports.ghmattimysql:execute(query, {}, function(data)
                result = data
                IsBusy = false
            end)
        end
    elseif Config.SQL == "mysql-async" then
        if parameters then
            MySQL.Async.fetchAll(query, parameters, function(data)
                result = data
                IsBusy = false
            end)
        else
            MySQL.Async.fetchAll(query, {}, function(data)
                result = data
                IsBusy = false
            end)
        end
    end
    while IsBusy do
        Citizen.Wait(0)
    end
    return result
end

function Debug(text)
    if Config.DebugPrint then
        print(text)
    end
end
function GetName(source)
    if Config.Framework == "oldesx" or Config.Framework == "newesx" then
        local xPlayer = Framework.GetPlayerFromId(source)
        if xPlayer then
            local playerName = xPlayer.getName()
            return playerName
        end
    elseif Config.Framework == "oldqb" or Config.Framework == "newqb" then
        local Player = Framework.Functions.GetPlayer(source)
        if Player then
            local playerName = GetPlayerName(source)
            return playerName
        end
    end
    return nil
end

function GetPlayer(source)
    if Config.Framework == 'newqb' or Config.Framework == 'oldqb' then
        return Framework.Functions.GetPlayer(source)
    elseif Config.Framework == 'newesx' or Config.Framework == 'oldesx' then
        return Framework.GetPlayerFromId(source)
    end
    return nil
end

function GetPlayerIdentifier(source)
    local player = GetPlayer(source)
    if player then
        if Config.Framework == 'newqb' or Config.Framework == 'oldqb' then
            return player.PlayerData.citizenid
        elseif Config.Framework == 'newesx' or Config.Framework == 'oldesx' then
            return player.identifier
        end
    end
    return nil
end

function AddMoney(source, amount)
    local player = GetPlayer(source)
    if player then
        if Config.Framework == 'newqb' or Config.Framework == 'oldqb' then
            if Config.MoneyType == 'bank' then
                player.Functions.AddMoney('bank', amount)
            elseif Config.MoneyType == 'cash' then
                player.Functions.AddMoney('cash', amount)
            end
        elseif Config.Framework == 'newesx' or Config.Framework == 'oldesx' then
            if Config.MoneyType == 'bank' then
                player.addAccountMoney('bank', amount)
            elseif Config.MoneyType == 'cash' then
                player.addMoney(amount)
            end
        end
        return true
    end
    return false
end

function AddItem(source, item, amount)
    local player = GetPlayer(source)
    if player then
        if Config.Inventory == 'codem-inventory' then
            return exports['codem-inventory']:AddItem(source, item, amount)
        elseif Config.Inventory == 'ox_inventory' then
            return exports.ox_inventory:AddItem(source, item, amount)
        elseif Config.Inventory == 'qb-inventory' then
            return player.Functions.AddItem(item, amount or 1)
        elseif Config.Inventory == 'esx_inventory' then
            player.addInventoryItem(item, amount or 1)
            return true
        elseif Config.Inventory == 'qs-inventory' then
            return exports['qs-inventory']:AddItem(source, item, amount)
        end
    end
    return false
end

function GiveWeapon(source, weapon, ammo)
    local player = GetPlayer(source)
    if player then
        if Config.Framework == 'newqb' or Config.Framework == 'oldqb' then
            player.Functions.AddItem(weapon, 1)
            if Config.GiveAmmo and ammo and ammo > 0 then
                player.Functions.AddItem('pistol_ammo', ammo) -- Adjust based on your ammo system
            end
        elseif Config.Framework == 'newesx' or Config.Framework == 'oldesx' then
            player.addWeapon(weapon, ammo or 0)
        end
        return true
    end
    return false
end

-- Since CodeM Inventory does not have an export to add Items directly to a stash,
-- I had to use their GetStashItems and UpdateStash functions to add items.

-- This info part is directly taken from codem-inventory addItem function, 
-- if you have other items that have info besides weapon you can edit it here
function AddItemToCodemStash(stashID, item)
    local StashItems = exports['codem-inventory']:GetStashItems(stashID)
    local itemInfo = {}
    for k,v in pairs(CodeMItemList) do
        if v.name == item then
            itemInfo = v
            break
        end
    end
    local info = {}

    if itemInfo.type == 'weapon' then
        info.ammo = 0
        info.series = RandomStr(11) 
        info.attachments = {}
        info.tint = 0
        info.maxrepair = 1
        info.repair = 0
        info.durability = 0.3
        info.decay = 'time'
        info.quality = 100
    
    end
    local nextSlot = 1
    while StashItems[tostring(nextSlot)] ~= nil do
        nextSlot = nextSlot + 1
    end

    local itemToAdd = {
        name = itemInfo.name,
        label = itemInfo.label,
        description = itemInfo.description,
        image = itemInfo.image,
        weight = itemInfo.weight,
        amount = 1,
        count = 1,
        unique = itemInfo.unique,
        usable = itemInfo.usable,
        type = itemInfo.type,
        slot = tostring(nextSlot),
        info = info
    }

    StashItems[itemToAdd.slot] = itemToAdd
    exports['codem-inventory']:UpdateStash(stashID, StashItems)
end
function AddItemToStash(source, stashID, item, amount)
    local player = GetPlayer(source)
    if player then
        if Config.Inventory == 'qs-inventory' then
            exports['qs-inventory']:AddItemIntoStash(stashID, item, amount, nil, nil, 50, 1000000)
        elseif Config.Inventory == 'ox_inventory' then
            exports.ox_inventory:AddItem(stashID, item, amount)
        elseif Config.Inventory == 'qb-inventory' then
            exports['qb-inventory']:AddItemIntoStash(stashID, item, amount, nil, nil, 50, 1000000)
        end
    end
    return false
end
function CreateStash(source)
    local player = GetPlayer(source)
    local stashID = 'vip_stash_' .. GetPlayerIdentifier(source)
    local label = 'Vip Stash'
    if player then
        if Config.Inventory == 'ox_inventory' then
            exports.ox_inventory:RegisterStash(stashID, label, 50, 1000000, GetPlayerIdentifier(source), nil, vector3(0, 0, 0))
        end
    end
    return false
end

function GeneratePlate()
    local tableName = 'player_vehicles'
    local plate = RandomInt(1) .. RandomStr(2) .. RandomInt(3) .. RandomStr(2)

    if Config.Framework == 'esx' or Config.Framework == 'newesx' then
        tableName = 'owned_vehicles'
		plate = RandomStr(3) .. ' ' .. RandomInt(3)
    end
    plate = plate:upper()
    local result =  ExecuteSql(string.format("SELECT plate FROM %s WHERE plate = '%s'", tableName, plate))
    if result[1] then
        return GeneratePlate()
    else
        return plate:upper()
    end
end
local StringCharset = {}
local NumberCharset = {}

for i = 48,  57 do NumberCharset[#NumberCharset+1] = string.char(i) end
for i = 65,  90 do StringCharset[#StringCharset+1] = string.char(i) end
for i = 97, 122 do StringCharset[#StringCharset+1] = string.char(i) end

function RandomStr(length)
    if length <= 0 then return '' end
    return RandomStr(length - 1) .. StringCharset[math.random(1, #StringCharset)]
end

function RandomInt(length)
    if length <= 0 then return '' end
    return RandomInt(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
end

function Round(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10^numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end
function GetVehicleProperties(name, plate, helicopter)
    local vehicleType = "car"
    if helicopter then
        vehicleType = "helicopter"
    end
    local extras = {}
    for i = 1, 12 do
        extras[i] = false
    end

    local defaultProps = {
        model = GetHashKey(name),
        plate = plate,
        plateIndex        = 0,
        bodyHealth        = Round(1000,  0.1),
        engineHealth      = Round(1000,  0.1),
        tankHealth        = Round(1000,  0.1),
        fuelLevel         = Round(100, 0.1),
        dirtLevel         = Round(0, 0.1),

        color1            = 0,
        color2            = 0,

        pearlescentColor  = 111,
        wheelColor        = 156,
        dashboardColor    = 0,
        interiorColor     = 0,
        wheels            = 0,
        windowTint        = -1,
        xenonColor        = 255,
        neonEnabled = {
            false,
            false,
            false,
            false
        },
        neonColor         = {255,0,255},
        extras            = extras,
        tyreSmokeColor    = {255,255,255},
        modSpoilers = -1,
        modFrontBumper = -1,
        modRearBumper = -1,
        modSideSkirt = -1,
        modExhaust = -1,
        modFrame = -1,
        modGrille =-1,
        modHood = -1,
        modFender = -1,
        modRightFender = -1,
        modRoof =-1,
        modEngine = -1,
        modBrakes = -1,
        modTransmission = -1,
        modHorns = -1,
        modSuspension = -1,
        modArmor = -1,
        modTurbo = false,
        modSmokeEnabled = false,
        modXenon = false,
        modFrontWheels = -1,
        modBackWheels =-1,
        modCustomTiresF = false,
        modCustomTiresR = false,
        modPlateHolder = -1,
        modVanityPlate = -1,
        modTrimA = -1,
        modOrnaments = -1,
        modDashboard = -1,
        modDial = -1,
        modDoorSpeaker = -1,
        modSeats = -1,
        modSteeringWheel = -1,
        modShifterLeavers = -1,
        modAPlate = -1,
        modSpeakers = -1,
        modTrunk = -1,
        modHydrolic = -1,
        modEngineBlock = -1,
        modAirFilter = -1,
        modStruts = -1,
        modArchCover = -1,
        modAerials = -1,
        modTrimB = -1,
        modTank = -1,
        modWindows = -1,
        modLivery = 0,
    }

    if vehicleType == 'helicopter' then
        defaultProps.liveryRoof = -1
        defaultProps.extras = {
            ["1"] = true,
            ["2"] = true,
            ["7"] = true,
        }
        defaultProps.windowStatus = {
            ["1"] = true,
            ["2"] = true,
            ["3"] = true,
            ["4"] = true,
            ["5"] = true,
            ["6"] = true,
            ["7"] = false,
            ["0"] = true,
        }
    end

    return defaultProps
end
function GiveVehicle(source, vehicleName, type)
    local player = GetPlayer(source)
    local plate = GeneratePlate()
    local isHelicopter = false
    local garage = nil
    if type == 'air' then
        isHelicopter = true
        garage = Config.AirGarage
    elseif type == 'boat' then
        garage = Config.BoatGarage
    else
        garage = Config.Garage
    end
    local vehicleProps = GetVehicleProperties(vehicleName, plate, isHelicopter)
    if player then
        if Config.Framework == 'newqb' or Config.Framework == 'oldqb' then
            local identifier = player.PlayerData.citizenid
            ExecuteSql(string.format("INSERT INTO `player_vehicles` (license, citizenid, vehicle, hash, mods, plate, garage) VALUES ('%s', '%s', '%s', '%s', %q, '%s', '%s')",
            player.PlayerData.license, identifier, vehicleName, GetHashKey(vehicleName), json.encode(vehicleProps),  plate, garage))
        elseif Config.Framework == 'newesx' then
            local identifier = player.identifier
            if identifier then
                if identifier and plate and vehicleProps then
                    ExecuteSql(string.format("INSERT INTO owned_vehicles (owner, plate, vehicle, stored, parking) VALUES ('%s', '%s', %q, '%s', '%s')", identifier, plate, json.encode(vehicleProps), "1", garage))
                end
            end
        elseif Config.Framework == 'oldesx' then
            local identifier = player.identifier
            if identifier then
                if identifier and plate and vehicleProps then
                    ExecuteSql(string.format("INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES ('%s', '%s', %q)", identifier, plate, json.encode(vehicleProps)))
                end
            end 
        end
        return true
    end
    return false
end

function IsPlayerStaff(source)
    if Config.Framework == "oldesx" or Config.Framework == "newesx" then
        local xPlayer = Framework.GetPlayerFromId(source)
        if xPlayer then
            local playerGroup = xPlayer.getGroup()
            return Config.AdminGroups[playerGroup] or false
        end
    elseif Config.Framework == "oldqb" or Config.Framework == "newqb" then
        for group, _ in pairs(Config.AdminGroups) do
            if Framework.Functions.HasPermission(source, group) then
                return true
            end
        end
        return false
    end
    return false
end

CreateThread(function()
    if Config.VersionChecker then
        local resource_name = 'mg-vipsystem'
        local current_version = GetResourceMetadata(resource_name, 'version', 0)
        PerformHttpRequest('https://raw.githubusercontent.com/MiguexMG/MG-VersionChecker/main/version.json',
            function(error, result, headers)
                if not result then
                    print('^1[mg-vipsystem] Version check disabled - GitHub API unavailable^0')
                    return
                end
                local data = json.decode(result)
                if not data then
                    print('^1[mg-vipsystem] Failed to decode version data^0')
                    return
                end
                local latest_version = data[resource_name]
                if not latest_version then
                    print(('^3[mg-vipsystem] Resource not found in version database: %s^0'):format(resource_name))
                    return
                end

                print(('^5[mg-vipsystem] Current version: %s^0'):format(current_version))
                print(('^5[mg-vipsystem] Latest version: %s^0'):format(latest_version))
                if tonumber(current_version) < tonumber(latest_version) then
                    print('\n^1======================================================================^0')
                    print(('^1[mg-vipsystem] UPDATE AVAILABLE! New version: %s ^0'):format(latest_version))
                    print('^1======================================================================^0\n')
                elseif tonumber(current_version) > tonumber(latest_version) then
                    print('^3[mg-vipsystem] You are running a development version^0')
                else
                    print('^2[mg-vipsystem] Resource is up to date!^0')
                end
            end, 'GET') 
    end
end)