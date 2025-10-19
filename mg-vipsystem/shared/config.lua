Config = {}

-- Framework Settings
Config.Debug = true
Config.VersionChecker = true -- Enable version checker
Config.Framework = 'autodetect' -- 'autodetect', 'newqb', 'oldqb', 'newesx', 'oldesx'
Config.SQL = 'autodetect' -- 'autodetect', 'oxmysql', 'ghmattimysql', 'mysql-async'
Config.Locale = 'es' -- 'en', 'pt', 'fr', 'es' | You can add your own locale by creating a new file in the locales folder and adding it to the Config.Locale list
Config.Inventory = 'qs-inventory' -- 'codem-inventory', 'ox_inventory', 'qb-inventory', 'esx_inventory', 'qs-inventory'
Config.MoneyType = 'bank' -- 'bank', 'cash' | What type of money can be purchased with diamonds

-- Currency Settings
Config.CurrencyName = 'ZCoins' -- Name of VIP currency
Config.StartingDiamonds = 0 -- Starting diamonds for new players

-- Tebex Settings
Config.TebexLink = 'https://mg-studios.tebex.io' -- Link to your Tebex store

-- UI Settings
Config.UISettings = {
    ServerLogo = 'https://horizons-cdn.hostinger.com/37ec45a0-04a9-4ffe-91d9-070ef945504c/de9b7f928d492a0e0bb99cb5e649bec9.png', -- URL to server logo
    enableSounds = true,
    enableAnimations = true,
    style = 'modern', -- 'classic' or 'modern' (modern = sidebar style)
    testDriveInfoPosition = 'center-left', -- top-left, top-right, bottom-left, bottom-right, center-left, center-right, center-top, center-bottom
}
-- Test drive
Config.TestDriveEnabled = true -- Enable test drive feature
Config.TestDriveDuration = 30 -- Duration in seconds for test drive
Config.TestDriveEndKey = 'BACK' -- Key to end test drive
Config.TestDriveLocation = vector4(-1740.2286, -2916.1018, 13.9443, 337.0327) -- Coordinates for test drive start location
Config.CancelTestDriveOnExit = true -- Cancel test drive if player exits the vehicle
Config.TestDriveVehiclePlate = 'VIP TEST' -- Plate for test drive vehicles
Config.UseRoutingBucket = true -- Use routing bucket for test drive vehicles so that they don't interfere with other players | Extremely recommended to keep this true

-- Commands 
Config.Commands = {
    openMenu = 'tienda', -- Command to open VIP menu
    giveDiamonds = 'darzcoins', -- Command to give diamonds (admin only)
    removeDiamonds = 'quitarzcoins', -- Command to remove diamonds (admin only)
    setDiamonds = 'ajustarzcoins', -- Command to set diamonds (admin only)
    setVIP = 'darvip', -- Command to set VIP tier (admin only)
    removeVIP = 'quitarvip', -- Command to remove VIP tier (admin only)
    finishTestDrive = 'quitartestcochevip' -- Command to finish test drive
}
Config.UseKeyBind = false -- Enable keybind to open menu
Config.KeyBind = 'F6' -- Key to open VIP menu

Config.AdminGroups = { -- Admin groups that will have access to use the commands
    moderador = true,
    administrador = true,
    superadmin = true,
    dueno = true
}

Config.DefaultImage = 'https://r2.fivemanage.com/RxnHchmV04WVJzlhi9v4T/default.png' -- Default image to use as a fallback when an item/vehicle/weapon/mlo does not have an image 
-- VIP Tiers
Config.TiersEnabled = true -- Enable VIP tiers page

Config.VIPTiers = {
    {
        id = 'dios',
        label = 'Dios',
        duration = 0, -- 0 = permanente
        benefits = {
            'Rol exclusivo: Caminante dios',
            'Rango VIP en servidor para siempre',
            '3 meses de refugio de facción',
            'Plano VIP para 4x4',
            'Plano VIP para volador',
            'Ballesta VIP',
            'Caballo',
            'Habitación privada en refugio',
            'Opción de 2º personaje zombi',
            '100 ZCoins'
        },
        price = 500, -- € 
        color = '#FFD700'
    },
    {
        id = 'premium',
        label = 'Premium',
        duration = 0, -- 0 = permanente
        benefits = {
            'Rol exclusivo: Caminante premium',
            'Rango VIP en servidor para siempre',
            '1 mes de refugio de facción',
            'Plano VIP para 4x4',
            'Plano VIP para motocicletas',
            'Caballo',
            'Arma VIP',
            'Materiales para base 8x8',
            '50 ZCoins'
        },
        price = 250, -- €
        color = '#6A0DAD'
    },
    {
        id = 'pro',
        label = 'Pro',
        duration = 180, -- días (6 meses)
        benefits = {
            'Rol exclusivo: Caminante pro',
            'Rango VIP por 6 meses',
            'Plano VIP para 4x4',
            'Caballo',
            'Materiales para base 4x4',
            'Arma VIP',
            '30 ZCoins'
        },
        price = 100, -- €
        color = '#00C8D7'
    },
    {
        id = 'vip_plus',
        label = 'VIP+',
        duration = 90, -- días (3 meses)
        benefits = {
            'Rol exclusivo: Caminante VIP+',
            'Rango VIP por 3 meses',
            'Plano VIP para moto',
            'Arma VIP',
            '15 ZCoins'
        },
        price = 50, -- €
        color = '#00D084'
    },
    {
        id = 'vip',
        label = 'VIP',
        duration = 60, -- días (2 meses)
        benefits = {
            'Rol exclusivo: Caminante VIP',
            'Rango VIP por 2 meses',
            '10 ZCoins'
        },
        price = 10, -- €
        color = '#9AA0A6'
    }
}



-- Featured Offers (shown on main page)
Config.FeaturedOffersEnabled = true -- Enable featured offers
Config.FeaturedOffers = {
    {
        name = 'Weekend Special',
        description = 'Get 25% bonus Diamonds!',
        active = true
    },
    {
        name = 'VIP Starter Pack',
        description = 'Perfect for new VIPs',
        active = true
    }
}

-- VIP Items
Config.VIPItemsEnabled = true -- Enable VIP items page
Config.GiveItemsToPlayer = true -- True - Give items directly to player inventory | False - Sends the inventory to a private stash | This also applies for weapons | When false this is not Available for default esx_inventory
Config.VipStashCoords = vector3(259.6896, -783.0989, 30.5092) -- Coordinates for VIP stash (Only used if GiveItemsToPlayer is false)
Config.VipStashInteraction = 'drawtext' -- qb-target, ox-target, codem-textui, drawtext
Config.ItemsFilters = { -- This is for filtering items in the menu
    ['utility'] = 'Utility Items',
    ['food'] = 'Food Items',
    ['drink'] = 'Drink Items',
    ['clothing'] = 'Clothing Items',
    ['misc'] = 'Miscellaneous'

}
Config.VIPItems = {
    {
        name = 'Kevlar Armor',
        description = 'High-quality armor',
        price = 50,
        item = 'armor',
        image = 'armor.png', -- You can use a URL or a file in the html/images/items folder
        amount = 1,
        filter = 'utility' -- This is according to Config.ItemsFilters
    },
    {
        name = 'Phone',
        description = 'Exclusive smartphone with premium features',
        price = 100,
        item = 'phone',
        image = 'phone.png', -- You can use a URL or a file in the html/images/items folder
        amount = 1,
        filter = 'utility'
    },
    {
        name = 'Diamond Ring',
        description = 'Sparkling diamond ring',
        price = 200,
        item = 'diamond_ring',
        image = 'diamond_ring.png', -- You can use a URL or a file in the html/images/items folder
        amount = 1,
        filter = 'misc'
    }
}

-- VIP Vehicles
Config.VIPVehiclesEnabled = true -- Enable VIP vehicles page
Config.Garage = 'pillboxgarage' -- Default garage for VIP vehicles | Only for QBCore
Config.BoatGarage = 'lsymc' -- Default garage for VIP boats | Only for QBCore
Config.AirGarage = 'intairport' -- Default garage for VIP aircraft | Only for QBCore
Config.VehiclesFilters = { -- This is for filtering vehicles in the menu
    ['car'] = 'Cars',
    ['bike'] = 'Motorcycles',
    ['plane'] = 'Airplanes',
    ['heli'] = 'Helicopters',
    ['boat'] = 'Boats'
}
Config.VIPVehicles = {
    {
        name = 'Truffade Adder',
        model = 'adder',
        price = 500,
        image = 'adder.png', -- You can use a URL or a file in the html/images/vehicles folder
        filter = 'car', -- This is according to Config.VehiclesFilters
        category = 'car' -- car, air, boat
    },
    {
        name = 'Pegassi Zentorno',
        model = 'zentorno',
        price = 600,
        image = 'zentorno.png', -- You can use a URL or a file in the html/images/vehicles folder
        filter = 'car',
        category = 'car' -- car, air, boat
    },
    {
        name = 'Progen Itali GTB',
        model = 'italigtb',
        price = 1000,
        image = 'italigtb.png', -- You can use a URL or a file in the html/images/vehicles folder
        filter = 'car',
        category = 'car' -- car, air, boat
    }
}

-- VIP Weapons
Config.VIPWeaponsEnabled = true -- Enable VIP weapons page
Config.GiveAmmo = true -- Give ammo with weapons
Config.WeaponAsItem = true -- Give weapons as items instead of directly | If Config.GiveItemsToPlayer is false this will not work
Config.WeaponsFilters = { -- This is for filtering weapons in the menu
    ['pistol'] = 'Pistols',
    ['smg'] = 'SMGs',
    ['rifle'] = 'Rifles',
    ['shotgun'] = 'Shotguns',
    ['sniper'] = 'Sniper Rifles',
    ['heavy'] = 'Heavy Weapons'
}
Config.VIPWeapons = {
    {
        name = 'Pistol MK2',
        weapon = 'weapon_pistol_mk2',
        price = 150,
        image = 'weapon_pistol_mk2.png', -- You can use a URL or a file in the html/images/weapons folder
        ammo = 10,
        filter = 'pistol', -- This is according to Config.WeaponsFilters
        ammoItem = 'pistol_ammo' -- Adjust based on your ammo system
    },
    {
        name = 'AK-47',
        weapon = 'weapon_assaultrifle',
        price = 300,
        image = 'weapon_assaultrifle.png', -- You can use a URL or a file in the html/images/weapons folder
        ammo = 10,
        filter = 'rifle', -- This is according to Config.WeaponsFilters
        ammoItem = 'rifle_ammo' -- Adjust based on your ammo system
    },
    {
        name = 'Sniper Rifle',
        weapon = 'weapon_sniperrifle',
        price = 400,
        image = 'weapon_sniperrifle.png', -- You can use a URL or a file in the html/images/weapons folder
        ammo = 10,
        filter = 'sniper', -- This is according to Config.WeaponsFilters
        ammoItem = 'snp_ammo' -- Adjust based on your ammo system
    }
}

-- Money Exchange 
Config.MoneyExchangeEnabled = true -- Enable money exchange feature
Config.MoneyExchange = {
    {
        amount = 10000, -- In-game money amount
        price = 10, -- Diamond cost
        label = '$10,000'
    },
    {
        amount = 50000,
        price = 45,
        label = '$50,000'
    },
    {
        amount = 100000,
        price = 85,
        label = '$100,000'
    },
    {
        amount = 500000,
        price = 400,
        label = '$500,000'
    }
}
-- MLO Access
-- MLO Purchases do not give the players the MLO, it will send a webhook to the admin to notify them of the purchase so they can give it to the player
Config.MloEnabled = true -- Enable MLO access feature
Config.MloList = {
    {
        name = 'VIP Lounge',
        description = 'Access to the exclusive VIP Lounge',
        price = 100,
        mloId = 'viplounge', -- This is just an ID for internal use, it must be unique for each MLO
        image = 'https://r2.fivemanage.com/RxnHchmV04WVJzlhi9v4T/latest.webp' -- You can use a URL or a file in the html/images/mlos folder
    },
    {
        name = 'Luxury Apartment',
        description = 'Access to a luxury apartment in the city',
        price = 200,
        mloId = 'apa_milton', -- This is just an ID for internal use, it must be unique for each MLO
        image = 'apartment.png' -- You can use a URL or a file in the html/images/mlos folder
    }
}
Config.VehicleKeySystem = 'qb-vehiclekeys' -- 'qb-vehiclekeys' | 'qs-vehiclekeys' | 'wasabi-carlock' | 'cd_garage' | false for no key system
Config.GiveVehicleKey = function(vehicle) -- You can change vehicle key giving event here
    TriggerEvent('qb-vehiclekeys:client:SetOwner', GetVehicleNumberPlateText(vehicle))
    if Config.VehicleKeySystem == 'qb-vehiclekeys' then
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', GetVehicleNumberPlateText(vehicle))

    elseif Config.VehicleKeySystem == 'qs-vehiclekeys' then
        local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
        local plate = GetVehicleNumberPlateText(vehicle)
        exports['qs-vehiclekeys']:GiveKeys(plate, model)
    elseif Config.VehicleKeySystem == 'wasabi-carlock' then
        exports.wasabi_carlock:GiveKey(GetVehicleNumberPlateText(vehicle))
    elseif Config.VehicleKeySystem == 'cd_garage' then
        TriggerEvent('cd_garage:AddKeys', exports['cd_garage']:GetPlate(vehicle))
    else
        -- You can add your own logic here
    end
end
Config.RemoveKey = true -- Remove vehicle key on test drive end
Config.RemoveVehicleKey = function(vehicle) -- You can change vehicle key removing event here
    if Config.VehicleKeySystem == 'qb' then
        TriggerServerEvent('qb-vehiclekeys:client:RemoveKeys', GetVehicleNumberPlateText(vehicle))
    elseif Config.VehicleKeySystem == 'qs' then
        exports['qs-vehiclekeys']:RemoveKeys(GetVehicleNumberPlateText(vehicle))
    elseif Config.VehicleKeySystem == 'cd_garage' then
            TriggerServerEvent('cd_garage:RemovePersistentVehicles', exports['cd_garage']:GetPlate(vehicle))
    else
        -- You can add your own logic here
    end
end
Config.ClientNotification = function(message, type, length) -- You can change notification event here
    if Config.Framework == "newesx" or Config.Framework == "oldesx" then
        TriggerEvent("esx:showNotification", message)
    else
        TriggerEvent('QBCore:Notify', message, type, length)
    end
end
Config.ServerNotification = function(source, message, type, length) -- You can change notification event here
    if Config.Framework == "newesx" or Config.Framework == "oldesx" then
        TriggerClientEvent("esx:showNotification",source, message)
    else
        TriggerClientEvent('QBCore:Notify', source, message, type, length)
    end
end