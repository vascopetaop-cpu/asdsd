CodeMItemList = {}
Citizen.CreateThread(function()
    while not Framework do
        Wait(100)
    end
    if Config.Inventory == 'codem-inventory' then
        CodeMItemList = exports['codem-inventory']:GetItemList()
    end
    InitializeDatabase() 
    LoadCommands()
    if Config.Framework == 'newqb' or Config.Framework == 'oldqb' then
        AddEventHandler('QBCore:Server:PlayerLoaded', function(playerInfo)
            CheckAndClearExpiredVIP(playerInfo.PlayerData.source)
        end)
    else
        AddEventHandler('esx:playerLoaded', function(playerId)
            CheckAndClearExpiredVIP(playerId)
        end)
    end
    Debug("^5[mg-vipsystem] ^2 Server Side Successfully loaded^0")
end)

function _U(str, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        return string.format(Locales[Config.Locale][str], ...)
    else
        return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
    end
end
function LoadCommands()
    RegisterCommand(Config.Commands.giveDiamonds, function(source, args, rawCommand)
        if not IsPlayerStaff(source) then
            Config.ServerNotification(source, _U('no_permission'), 'error', 5000)
            return
        end
        if not args[1] or not args[2] then
            return
        end
        
        local playerId = tonumber(args[1])
        local amount = tonumber(args[2])
        
        if not playerId or not amount then
            return
        end
        
        local identifier = GetPlayerIdentifier(playerId)
        if not identifier then
            return
        end
        
        local vipData = GetPlayerVIPData(identifier)
        if not vipData then
            vipData = CreatePlayerVIPData(identifier)
        end
        
        local newDiamonds = vipData.diamonds + amount
        UpdatePlayerDiamonds(identifier, newDiamonds)
        
        Debug(string.format("^5[mg-vipsystem] ^0Gave %d diamonds to player %d (Total: %d)", amount, playerId, newDiamonds))
        SendLogToDiscord(SVConfig.webhooks.adminActions.giveDiamonds, {
            title = _U('admin_give_diamonds'),
            fields = {
                { name = _U('staff_name'), value = "\n```"..GetName(source).."\n```", inline = false},
                { name = _U('player_name'), value = "\n```"..GetName(playerId).."\n```", inline = false},
                { name = _U('diamonds_amount'), value = "\n```"..amount.."\n```", inline = false},
                { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
            }
        })
        TriggerClientEvent('mg-vipsystem:updatePlayerData', playerId, {
            diamonds = newDiamonds,
            totalSpent = vipData.total_spent,
            vipTier = GetPlayerVIPTier(identifier),
            purchaseHistory = GetPurchaseHistory(identifier)
        })
    end, false)
    RegisterCommand(Config.Commands.removeDiamonds, function(source, args, rawCommand)
        if not IsPlayerStaff(source) then
            Config.ServerNotification(source, _U('no_permission'), 'error', 5000)
            return
        end
        if not args[1] or not args[2] then
            return
        end
        
        local playerId = tonumber(args[1])
        local amount = tonumber(args[2])
        
        if not playerId or not amount then
            return
        end
        
        local identifier = GetPlayerIdentifier(playerId)
        if not identifier then
            return
        end
        
        local vipData = GetPlayerVIPData(identifier)
        if not vipData then
            return
        end
        
        local newDiamonds = math.max(vipData.diamonds - amount, 0)
        UpdatePlayerDiamonds(identifier, newDiamonds)
        
        Debug(string.format("^5[mg-vipsystem] ^0Removed %d diamonds from player %d (Total: %d)", amount, playerId, newDiamonds))
        SendLogToDiscord(SVConfig.webhooks.adminActions.removeDiamonds, {
            title = _U('admin_remove_diamonds'),
            fields = {
                { name = _U('staff_name'), value = "\n```"..GetName(source).."\n```", inline = false},
                { name = _U('player_name'), value = "\n```"..GetName(playerId).."\n```", inline = false},
                { name = _U('diamonds_amount'), value = "\n```"..amount.."\n```", inline = false},
                { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
            }
        })
        TriggerClientEvent('mg-vipsystem:updatePlayerData', playerId, {
            diamonds = newDiamonds,
            totalSpent = vipData.total_spent,
            vipTier = GetPlayerVIPTier(identifier),
            purchaseHistory = GetPurchaseHistory(identifier)
        })
    end, false)
    RegisterCommand(Config.Commands.setDiamonds, function(source, args, rawCommand)
        if not IsPlayerStaff(source) then
            Config.ServerNotification(source, _U('no_permission'), 'error', 5000)
            return
        end
        if not args[1] or not args[2] then
            return
        end
        
        local playerId = tonumber(args[1])
        local amount = tonumber(args[2])
        
        if not playerId or not amount then
            return
        end
        
        local identifier = GetPlayerIdentifier(playerId)
        if not identifier then
            return
        end
        
        UpdatePlayerDiamonds(identifier, amount)
        
        Debug(string.format("^5[mg-vipsystem] ^0Set %d diamonds for player %d", amount, playerId))
        SendLogToDiscord(SVConfig.webhooks.adminActions.setDiamonds, {
            title = _U('admin_set_diamonds'),
            fields = {
                { name = _U('staff_name'), value = "\n```"..GetName(source).."\n```", inline = false},
                { name = _U('player_name'), value = "\n```"..GetName(playerId).."\n```", inline = false},
                { name = _U('diamonds_amount'), value = "\n```"..amount.."\n```", inline = false},
                { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
            }
        })
        TriggerClientEvent('mg-vipsystem:updatePlayerData', playerId, {
            diamonds = amount,
            totalSpent = GetPlayerVIPData(identifier).total_spent,
            vipTier = GetPlayerVIPTier(identifier),
            purchaseHistory = GetPurchaseHistory(identifier)
        })
    end, false)
    RegisterCommand(Config.Commands.setVIP, function(source, args, rawCommand)
        if not IsPlayerStaff(source) then
            Config.ServerNotification(source, _U('no_permission'), 'error', 5000)
            return
        end
        if not args[1] or not args[2] then
            return
        end
        
        local playerId = tonumber(args[1])
        local tier = tonumber(args[2])
        
        if not playerId or not tier or tier < 1 or tier > #Config.VIPTiers then
            return
        end
        
        local identifier = GetPlayerIdentifier(playerId)
        if not identifier then
            return
        end
        
        ExecuteSql("UPDATE mg_vip_players SET vip_tier = ? WHERE identifier = ?", {tier, identifier})
        
        Debug(string.format("^5[mg-vipsystem] ^0Set VIP tier %d for player %d", tier, playerId))
        SendLogToDiscord(SVConfig.webhooks.adminActions.setVIP, {
            title = _U('admin_set_vip'),
            fields = {
                { name = _U('staff_name'), value = "\n```"..GetName(source).."\n```", inline = false},
                { name = _U('player_name'), value = "\n```"..GetName(playerId).."\n```", inline = false},
                { name = _U('vip_tier'), value = "\n```"..tier.."\n```", inline = false},
                { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
            }
        })
        TriggerClientEvent('mg-vipsystem:updatePlayerData', playerId, {
            diamonds = GetPlayerVIPData(identifier).diamonds,
            totalSpent = GetPlayerVIPData(identifier).total_spent,
            vipTier = tier,
            purchaseHistory = GetPurchaseHistory(identifier)
        })
    end, false)
    RegisterCommand(Config.Commands.removeVIP, function(source, args, rawCommand)
        if not IsPlayerStaff(source) then
            Config.ServerNotification(source, _U('no_permission'), 'error', 5000)
            return
        end
        if not args[1] then
            return
        end
        
        local playerId = tonumber(args[1])
        
        if not playerId then
            return
        end
        
        local identifier = GetPlayerIdentifier(playerId)
        if not identifier then
            return
        end
        
        ExecuteSql("UPDATE mg_vip_players SET vip_tier = NULL WHERE identifier = ?", {identifier})
        
        Debug(string.format("^5[mg-vipsystem] ^0Removed VIP tier for player %d", playerId))
        SendLogToDiscord(SVConfig.webhooks.adminActions.removeVIP, {
            title = _U('admin_remove_vip'),
            fields = {
                { name = _U('staff_name'), value = "\n```"..GetName(source).."\n```", inline = false},
                { name = _U('player_name'), value = "\n```"..GetName(playerId).."\n```", inline = false},
                { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
            }
        })
        TriggerClientEvent('mg-vipsystem:updatePlayerData', playerId, {
            diamonds = GetPlayerVIPData(identifier).diamonds,
            totalSpent = GetPlayerVIPData(identifier).total_spent,
            vipTier = nil,
            purchaseHistory = GetPurchaseHistory(identifier)
        })
    end, false)
    Debug("^5[mg-vipsystem] ^2All Staff Commands loaded successfully^0")
end

function InitializeDatabase()
    local queries = {
        [[
        CREATE TABLE IF NOT EXISTS `mg_vip_players` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `identifier` varchar(50) NOT NULL,
            `diamonds` int(11) NOT NULL DEFAULT 0,
            `total_spent` int(11) NOT NULL DEFAULT 0,
            `vip_tier` varchar(50) DEFAULT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            `vip_expire_at` int(11) DEFAULT NULL,
            PRIMARY KEY (`id`),
            UNIQUE KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
        ]],
        [[
        CREATE TABLE IF NOT EXISTS `mg_vip_purchases` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `identifier` varchar(50) NOT NULL,
            `item_type` enum('item','vehicle','weapon','money','tier','mlo') NOT NULL,
            `item_name` varchar(255) NOT NULL,
            `diamonds_cost` int(11) NOT NULL,
            `purchase_data` text DEFAULT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`),
            KEY `identifier` (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
        ]],
        [[
        CREATE TABLE IF NOT EXISTS `mg_vip_transactions` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `transaction_id` varchar(255) NOT NULL,
            `diamonds_amount` int(11) NOT NULL,
            `status` enum('pending','completed','failed') NOT NULL DEFAULT 'pending',
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`),
            UNIQUE KEY `transaction_id` (`transaction_id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
        ]]
    }
    for _, query in ipairs(queries) do
        ExecuteSql(query)
    end
    Debug("^5[mg-vipsystem] ^2Database tables initialized successfully^0")
end

function GetPlayerVIPData(identifier)
    local result = ExecuteSql("SELECT * FROM mg_vip_players WHERE identifier = ?", {identifier})
    if result and result[1] then
        return result[1]
    end
    return nil
end

function CreatePlayerVIPData(identifier)
    ExecuteSql("INSERT INTO mg_vip_players (identifier, diamonds) VALUES (?, ?)", {identifier, Config.StartingDiamonds})
    return GetPlayerVIPData(identifier)
end

function UpdatePlayerDiamonds(identifier, diamonds)
    ExecuteSql("UPDATE mg_vip_players SET diamonds = ?, updated_at = NOW() WHERE identifier = ?", {diamonds, identifier})
end

function GetPlayerVIPTier(identifier)
    local result = ExecuteSql("SELECT vip_tier FROM mg_vip_players WHERE identifier = ?", {identifier})
    if result and result[1] then
        return result[1].vip_tier
    end
    return nil
end

function LogTransaction(transactionId)
    ExecuteSql("UPDATE mg_vip_transactions SET status = 'completed' WHERE transaction_id = ?", {transactionId})
end


function LogPurchase(identifier, itemType, itemName, cost, data)
    ExecuteSql("INSERT INTO mg_vip_purchases (identifier, item_type, item_name, diamonds_cost, purchase_data) VALUES (?, ?, ?, ?, ?)", 
               {identifier, itemType, itemName, cost, json.encode(data or {})})
end

function GetPurchaseHistory(identifier)
    local result = ExecuteSql("SELECT * FROM mg_vip_purchases WHERE identifier = ? ORDER BY created_at DESC LIMIT 50", {identifier})
    return result or {}
end
RegisterCommand('addDiamonds', function(source, args)
    if source ~= 0 then return print('Only tebex') end
    local transactionId = args[1]
    local amount = tonumber(args[2])

    if not transactionId or not amount then
        return
    end

    local existing = ExecuteSql("SELECT * FROM mg_vip_transactions WHERE transaction_id = ?", {transactionId})
    if existing and #existing > 0 then
        Debug('^5[mg-vipsystem] ^2!! ATENTION !!^0 Tebex Dupe Attempt for transaction id : ' .. transactionId)
        return
    end

    ExecuteSql("INSERT INTO mg_vip_transactions (transaction_id, diamonds_amount) VALUES (?, ?)", {
        transactionId,
        amount
    })

    Debug(('^5[mg-vipsystem] ^0New tebex transaction registered %s - x%s diamonds'):format(transactionId, amount))
    SendLogToDiscord(SVConfig.webhooks.tebexPurchase, {
        title = _U('vip_purchase'),
        fields = {
            { name = _U('vip_purchase_amount'), value = "\n```"..amount.."\n```", inline = false},
            { name = _U('vip_purchase_transaction_id'), value = "\n```" .. transactionId .. "\n```", inline = false},
            { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
        }
    })
end)

function ValidateTebexTransaction(transactionId)
    local result = ExecuteSql("SELECT * FROM mg_vip_transactions WHERE transaction_id = ?", {transactionId})

    if result and result[1] and result[1].status == "pending" then
        return true, tonumber(result[1].diamonds_amount)
    end

    return false, 0
end

RegisterNetEvent('mg-vipsystem:getPlayerData', function()
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then
        return
    end
    
    local vipData = GetPlayerVIPData(identifier)
    if not vipData then
        vipData = CreatePlayerVIPData(identifier)
    end
    
    local tier = GetPlayerVIPTier(identifier)
    local history = GetPurchaseHistory(identifier)
    
    TriggerClientEvent('mg-vipsystem:updatePlayerData', source, {
        diamonds = vipData.diamonds,
        totalSpent = vipData.total_spent,
        vipTier = tier,
        purchaseHistory = history
    })
end)

RegisterNetEvent('mg-vipsystem:redeemTransaction', function(transactionId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then
        TriggerClientEvent('mg-vipsystem:transactionResult', source, false, _U('error'))
        return
    end
    
    local isValid, diamonds = ValidateTebexTransaction(transactionId)
    
    if not isValid then
        TriggerClientEvent('mg-vipsystem:transactionResult', source, false, _U('invalid_transaction'))
        return
    end

    local vipData = GetPlayerVIPData(identifier)
    if not vipData then
        vipData = CreatePlayerVIPData(identifier)
    end

    local newDiamonds = vipData.diamonds + diamonds
    UpdatePlayerDiamonds(identifier, newDiamonds)

    LogTransaction(transactionId)

    TriggerClientEvent('mg-vipsystem:transactionResult', source, true, _U('redeem_success'), newDiamonds)

    
    local message = string.format("Player %s redeemed %d diamonds with transaction ID: %s", identifier, diamonds, transactionId)
    Debug("^5[mg-vipsystem] ^2" .. message .. "^0")
    SendLogToDiscord(SVConfig.webhooks.purchaseRedeem, {
        title = _U('transaction_redeemed'),
        fields = {
            { name = _U('player_name'), value = "\n```"..GetName(source).."\n```", inline = false},
            { name = _U('vip_purchase_transaction_id'), value = "\n```"..transactionId.."\n```", inline = false},
            { name = _U('diamonds_amount'), value = "\n```" .. diamonds .. "\n```", inline = false},
            { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
        }
    })
end)


RegisterNetEvent('mg-vipsystem:purchaseItem', function(itemId, itemType)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then
        Debug('^5[mg-vipsystem] ^0Player identifier not found for source: ' .. source .. ' - cannot purchase item, please contact the server owner.')
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('error'), itemType)
        return
    end
    local item = Config.VIPItems[itemId]
    if not item then
        Debug('^5[mg-vipsystem] ^0Item not found for ID: ' .. itemId .. ' - cannot purchase item, please contact the server owner.')
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('error'), itemType)
        return
    end
    
    local vipData = GetPlayerVIPData(identifier)
    if not vipData or vipData.diamonds < item.price then
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('insufficient_diamonds'), itemType)
        return
    end
    
    if Config.GiveItemsToPlayer then
        if AddItem(source, item.item, 1) then
            local newDiamonds = vipData.diamonds - item.price
            UpdatePlayerDiamonds(identifier, newDiamonds)
            
            ExecuteSql("UPDATE mg_vip_players SET total_spent = total_spent + ? WHERE identifier = ?", {item.price, identifier})
            
            LogPurchase(identifier, 'item', item.name, item.price, {item = item.item})
            
            TriggerClientEvent('mg-vipsystem:purchaseResult', source, true, _U('item_purchased'), itemType, newDiamonds)
            
            TriggerClientEvent('mg-vipsystem:updatePlayerData', source, {
                diamonds = newDiamonds,
                totalSpent = vipData.total_spent + item.price,
                vipTier = GetPlayerVIPTier(identifier),
                purchaseHistory = GetPurchaseHistory(identifier)
            })
            local message = string.format("Player %s purchased item %s for %d diamonds", identifier, item.name, item.price)
            Debug("^5[mg-vipsystem] ^2" .. message .. "^0")
            SendLogToDiscord(SVConfig.webhooks.purchases.item, {
                title = _U('player_bought_item'),
                fields = {
                    { name = _U('player_name'), value = "\n```"..GetName(source).."\n```", inline = false},
                    { name = _U('item_name'), value = "\n```"..item.name.."\n```", inline = false},
                    { name = _U('price'), value = "\n```" .. item.price .. "\n```", inline = false},
                    { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
                }
            })
        else
            TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('inventory_full'), itemType)
        end
    else
        local stashID = 'vip_stash_' .. identifier
        if Config.Inventory == 'codem-inventory' then
            AddItemToCodemStash(stashID, item.item)
        else
            AddItemToStash(source, stashID, item.item, 1)
        end
        local newDiamonds = vipData.diamonds - item.price
        UpdatePlayerDiamonds(identifier, newDiamonds)
        
        ExecuteSql("UPDATE mg_vip_players SET total_spent = total_spent + ? WHERE identifier = ?", {item.price, identifier})
        
        LogPurchase(identifier, 'item', item.name, item.price, {item = item.item})
        
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, true, _U('item_purchased'), itemType, newDiamonds)

        TriggerClientEvent('mg-vipsystem:updatePlayerData', source, {
            diamonds = newDiamonds,
            totalSpent = vipData.total_spent + item.price,
            vipTier = GetPlayerVIPTier(identifier),
            purchaseHistory = GetPurchaseHistory(identifier)
        })

        local message = string.format("Player %s purchased item %s for %d diamonds", identifier, item.name, item.price)
        Debug("^5[mg-vipsystem] ^2" .. message .. "^0")
        SendLogToDiscord(SVConfig.webhooks.purchases.item, {
            title = _U('player_bought_item'),
            fields = {
                { name = _U('player_name'), value = "\n```"..GetName(source).."\n```", inline = false},
                { name = _U('item_name'), value = "\n```"..item.name.."\n```", inline = false},
                { name = _U('price'), value = "\n```" .. item.price .. "\n```", inline = false},
                { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
            }
        })
    end
end)
RegisterNetEvent('mg-vipsystem:purchaseWeapon', function(weaponId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then
        Debug('^5[mg-vipsystem] ^0Player identifier not found for source: ' .. source .. ' - cannot purchase weapon, please contact the server owner.')
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('error'), 'weapon')
        return
    end
    
    local weapon = Config.VIPWeapons[weaponId]
    if not weapon then
        Debug('^5[mg-vipsystem] ^0Weapon not found for ID: ' .. weaponId .. ' - cannot purchase weapon, please contact the server owner.')
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('error'), 'weapon')
        return
    end
    
    local vipData = GetPlayerVIPData(identifier)
    if not vipData or vipData.diamonds < weapon.price then
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('insufficient_diamonds'), 'weapon')
        return
    end
    
    if Config.GiveItemsToPlayer then
        if Config.WeaponAsItem then
            AddItem(source, weapon.weapon, 1)
        else
            GiveWeapon(source, weapon.weapon, weapon.ammo)
        end
        local newDiamonds = vipData.diamonds - weapon.price
        UpdatePlayerDiamonds(identifier, newDiamonds)
        
        ExecuteSql("UPDATE mg_vip_players SET total_spent = total_spent + ? WHERE identifier = ?", {weapon.price, identifier})
        LogPurchase(identifier, 'weapon', weapon.name, weapon.price, {weapon = weapon.weapon})
        
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, true, _U('item_purchased'), 'weapon', newDiamonds)
        
        TriggerClientEvent('mg-vipsystem:updatePlayerData', source, {
            diamonds = newDiamonds,
            totalSpent = vipData.total_spent + weapon.price,
            vipTier = GetPlayerVIPTier(identifier),
            purchaseHistory = GetPurchaseHistory(identifier)
        })
        local message = string.format("Player %s purchased weapon %s for %d diamonds", identifier, weapon.weapon, weapon.price)
        Debug("^5[mg-vipsystem] ^2" .. message .. "^0")
        SendLogToDiscord(SVConfig.webhooks.purchases.weapon, {
            title = _U('player_bought_weapon'),
            fields = {
                { name = _U('player_name'), value = "\n```"..GetName(source).."\n```", inline = false},
                { name = _U('weapon_name'), value = "\n```"..weapon.name.."\n```", inline = false},
                { name = _U('price'), value = "\n```" .. weapon.price .. "\n```", inline = false},
                { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
            }
        })
    else
        local stashID = 'vip_stash_' .. identifier
        if Config.Inventory == 'codem-inventory' then
            AddItemToCodemStash(stashID, weapon.weapon)
        else
            AddItemToStash(source, stashID, weapon.weapon, 1)
        end
        local newDiamonds = vipData.diamonds - weapon.price
        UpdatePlayerDiamonds(identifier, newDiamonds)
        
        ExecuteSql("UPDATE mg_vip_players SET total_spent = total_spent + ? WHERE identifier = ?", {weapon.price, identifier})

        LogPurchase(identifier, 'weapon', weapon.name, weapon.price, {weapon = weapon.weapon})

        TriggerClientEvent('mg-vipsystem:purchaseResult', source, true, _U('item_purchased'), 'weapon', newDiamonds)

        TriggerClientEvent('mg-vipsystem:updatePlayerData', source, {
            diamonds = newDiamonds,
            totalSpent = vipData.total_spent + weapon.price,
            vipTier = GetPlayerVIPTier(identifier),
            purchaseHistory = GetPurchaseHistory(identifier)
        })

        local message = string.format("Player %s purchased item %s for %d diamonds", identifier, weapon.weapon, weapon.price)
        Debug("^5[mg-vipsystem] ^2" .. message .. "^0")
        SendLogToDiscord(SVConfig.webhooks.purchases.weapon, {
            title = _U('player_bought_weapon'),
            fields = {
                { name = _U('player_name'), value = "\n```"..GetName(source).."\n```", inline = false},
                { name = _U('weapon_name'), value = "\n```"..weapon.name.."\n```", inline = false},
                { name = _U('price'), value = "\n```" .. weapon.price .. "\n```", inline = false},
                { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
            }
        })
    end
end)

RegisterNetEvent('mg-vipsystem:purchaseVehicle', function(vehicleId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then
        Debug('^5[mg-vipsystem] ^0Player identifier not found for source: ' .. source .. ' - cannot purchase vehicle, please contact the server owner.')
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('error'), 'vehicle')
        return
    end
    
    local vehicle = Config.VIPVehicles[vehicleId]
    if not vehicle then
        Debug('^5[mg-vipsystem] ^0Vehicle not found for ID: ' .. vehicleId .. ' - cannot purchase vehicle, please contact the server owner.')
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('error'), 'vehicle')
        return
    end
    
    local vipData = GetPlayerVIPData(identifier)
    if not vipData or vipData.diamonds < vehicle.price then
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('insufficient_diamonds'), 'vehicle')
        return
    end
    
    GiveVehicle(source, vehicle.model, vehicle.category)
    local newDiamonds = vipData.diamonds - vehicle.price
    UpdatePlayerDiamonds(identifier, newDiamonds)
    
    ExecuteSql("UPDATE mg_vip_players SET total_spent = total_spent + ? WHERE identifier = ?", {vehicle.price, identifier})
    
    LogPurchase(identifier, 'vehicle', vehicle.name, vehicle.price, {model = vehicle.model})
    
    TriggerClientEvent('mg-vipsystem:purchaseResult', source, true, _U('vehicle_purchased'), 'vehicle', newDiamonds)
    
    TriggerClientEvent('mg-vipsystem:updatePlayerData', source, {
        diamonds = newDiamonds,
        totalSpent = vipData.total_spent + vehicle.price,
        vipTier = GetPlayerVIPTier(identifier),
        purchaseHistory = GetPurchaseHistory(identifier)
    })
    local message = string.format("Player %s purchased vehicle %s for %d diamonds", identifier, vehicle.name, vehicle.price)
    Debug("^5[mg-vipsystem] ^2" .. message .. "^0")
    SendLogToDiscord(SVConfig.webhooks.purchases.vehicle, {
        title = _U('player_bought_vehicle'),
        fields = {
            { name = _U('player_name'), value = "\n```"..GetName(source).."\n```", inline = false},
            { name = _U('vehicle_name'), value = "\n```"..vehicle.name.."\n```", inline = false},
            { name = _U('price'), value = "\n```" .. vehicle.price .. "\n```", inline = false},
            { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
        }
    })
end)
RegisterNetEvent('mg-vipsystem:purchaseMlo', function(mloId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then
        Debug('^5[mg-vipsystem] ^0Player identifier not found for source: ' .. source .. ' - cannot purchase MLO, please contact the server owner.')
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('error'), 'mlo')
        return
    end
    
    local mlo = Config.MloList[mloId]
    if not mlo then
        Debug('^5[mg-vipsystem] ^0MLO not found for ID: ' .. mloId .. ' - cannot purchase MLO, please contact the server owner.')
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('error'), 'mlo')
        return
    end
    
    local vipData = GetPlayerVIPData(identifier)
    if not vipData or vipData.diamonds < mlo.price then
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('insufficient_diamonds'), 'mlo')
        return
    end
    
    local newDiamonds = vipData.diamonds - mlo.price
    UpdatePlayerDiamonds(identifier, newDiamonds)
    
    ExecuteSql("UPDATE mg_vip_players SET total_spent = total_spent + ? WHERE identifier = ?", {mlo.price, identifier})
    
    LogPurchase(identifier, 'mlo', mlo.name, mlo.price, {mlo = mlo.mloId})
    
    TriggerClientEvent('mg-vipsystem:purchaseResult', source, true, _U('mlo_purchased'), 'mlo', newDiamonds)
    
    TriggerClientEvent('mg-vipsystem:updatePlayerData', source, {
        diamonds = newDiamonds,
        totalSpent = vipData.total_spent + mlo.price,
        vipTier = GetPlayerVIPTier(identifier),
        purchaseHistory = GetPurchaseHistory(identifier)
    })
    local message = string.format("Player %s purchased MLO %s for %d diamonds", identifier, mlo.name, mlo.price)
    Debug("^5[mg-vipsystem] ^2" .. message .. "^0")
    SendLogToDiscord(SVConfig.webhooks.purchases.mlo, {
        title = _U('player_bought_mlo'),
        fields = {
            { name = _U('player_name'), value = "\n```"..GetName(source).."\n```", inline = false},
            { name = _U('mlo_name'), value = "\n```"..mlo.name.."\n```", inline = false},
            { name = _U('price'), value = "\n```" .. mlo.price .. "\n```", inline = false},
            { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
        }
    })
end)

RegisterNetEvent("mg-vipsystem:setBucket", function(bucket)
    local src = source
    SetPlayerRoutingBucket(src, bucket)
end)

RegisterNetEvent("mg-vipsystem:resetBucket", function()
    local src = source
    SetPlayerRoutingBucket(src, 0)
end)

RegisterNetEvent('mg-vipsystem:purchaseTier', function(tierId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then
        Debug('^5[mg-vipsystem] ^0Player identifier not found for source: ' .. source .. ' - cannot purchase tier, please contact the server owner.')
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('error'), 'tier')
        return
    end
    
    local tier = Config.VIPTiers[tierId]
    if not tier then
        Debug('^5[mg-vipsystem] ^0Tier not found for ID: ' .. tierId .. ' - cannot purchase tier, please contact the server owner.')
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('error'), 'tier')
        return
    end
    
    local vipData = GetPlayerVIPData(identifier)
    if not vipData or vipData.diamonds < tier.price then
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('insufficient_diamonds'), 'tier')
        return
    end
    if vipData.vip_tier == tier.id then
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, 'You already have this rank', 'tier')     
        return
    end
    local newDiamonds = vipData.diamonds - tier.price
    UpdatePlayerDiamonds(identifier, newDiamonds)

    ExecuteSql("UPDATE mg_vip_players SET total_spent = total_spent + ? WHERE identifier = ?", {tier.price, identifier})

    LogPurchase(identifier, 'tier', tier.label, tier.price, {id = tier.id, duration = tier.duration})
    local expiresAt = os.time() + (tier.duration * 86400)
    ExecuteSql("UPDATE mg_vip_players SET vip_tier = ?, vip_expire_at = ? WHERE identifier = ?", {
        tier.id, expiresAt, identifier
    })

    TriggerClientEvent('mg-vipsystem:purchaseResult', source, true, _U('vip_purchased'), 'tier', newDiamonds)
    
    TriggerClientEvent('mg-vipsystem:updatePlayerData', source, {
        diamonds = newDiamonds,
        totalSpent = vipData.total_spent + tier.price,
        vipTier = tier.id,
        purchaseHistory = GetPurchaseHistory(identifier)
    })
    local message = string.format("Player %s exchanged %d diamonds for %s", identifier, tier.price, tier.label)
    Debug("^5[mg-vipsystem] ^2" .. message .. "^0")
    SendLogToDiscord(SVConfig.webhooks.purchases.tier, {
        title = _U('player_bought_vip_tier'),
        fields = {
            { name = _U('player_name'), value = "\n```"..GetName(source).."\n```", inline = false},
            { name = _U('vip_tier_name'), value = "\n```"..tier.label.."\n```", inline = false},
            { name = _U('price'), value = "\n```" .. tier.price .. "\n```", inline = false},
            { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
        }
    })
end)

RegisterNetEvent('mg-vipsystem:exchangeMoney', function(exchangeId)
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('error'), 'money')
        return
    end
    
    local exchange = Config.MoneyExchange[exchangeId]
    if not exchange then
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('error'), 'money')
        return
    end
    
    local vipData = GetPlayerVIPData(identifier)
    if not vipData or vipData.diamonds < exchange.price then
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('insufficient_diamonds'), 'money')
        return
    end
    
    if AddMoney(source, exchange.amount) then
        local newDiamonds = vipData.diamonds - exchange.price
        UpdatePlayerDiamonds(identifier, newDiamonds)
        
        ExecuteSql("UPDATE mg_vip_players SET total_spent = total_spent + ? WHERE identifier = ?", {exchange.price, identifier})
        
        LogPurchase(identifier, 'money', exchange.label, exchange.price, {amount = exchange.amount})
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, true, _U('exchange_success'), 'money', newDiamonds)

        TriggerClientEvent('mg-vipsystem:updatePlayerData', source, {
            diamonds = newDiamonds,
            totalSpent = vipData.total_spent + exchange.price,
            vipTier = GetPlayerVIPTier(identifier),
            purchaseHistory = GetPurchaseHistory(identifier)
        })

        local message = string.format("Player %s exchanged %d diamonds for %s", identifier, exchange.price, exchange.label)
        Debug("^5[mg-vipsystem] ^2" .. message .. "^0")
        SendLogToDiscord(SVConfig.webhooks.purchases.money, {
            title = _U('player_bought_money'),
            fields = {
                { name = _U('player_name'), value = "\n```"..GetName(source).."\n```", inline = false},
                { name = _U('money_amount'), value = "\n```"..exchange.label.."\n```", inline = false},
                { name = _U('price'), value = "\n```" .. exchange.price .. "\n```", inline = false},
                { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
            }
        })
    else
        TriggerClientEvent('mg-vipsystem:purchaseResult', source, false, _U('exchange_failed'), 'money')
    end
end)

RegisterServerEvent('mg-vipsystem:openVipStash')
AddEventHandler('mg-vipsystem:openVipStash', function()
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then
        Config.ServerNotification(source, _U('error'), 'error', 5000)
        print('^5[mg-vipsystem] ^0Player identifier not found for source: ' .. source .. ' - cannot open VIP stash, please contact the server owner.')
        return
    end
    local stashID = 'vip_stash_' .. identifier
    
    TriggerClientEvent('mg-vipsystem:openVipStash', source, stashID)
end)

RegisterServerEvent('mg-vipsystem:clearPurchaseHistory')
AddEventHandler('mg-vipsystem:clearPurchaseHistory', function()
    local source = source
    local identifier = GetPlayerIdentifier(source)
    
    if not identifier then
        Config.ServerNotification(source, _U('error'), 'error', 5000)
        print('^5[mg-vipsystem] ^0Player identifier not found for source: ' .. source .. ' - cannot clear purchase history, please contact the server owner.')
        return
    end
    
    ExecuteSql("DELETE FROM mg_vip_purchases WHERE identifier = ?", {identifier})
end)

function CheckAndClearExpiredVIP(src)
    local identifier = GetPlayerIdentifier(src)
    if not identifier then return end
    local vipData = GetPlayerVIPData(identifier)
    if vipData and vipData.vip_tier and vipData.vip_expire_at then
        local currentTime = os.time()
        if currentTime >= vipData.vip_expire_at then
            Debug('^5[mg-vipsystem] ^0VIP from player '.. identifier.. ' has expired - Removing tier...')
            SendLogToDiscord(SVConfig.webhooks.purchases.vehicle, {
                title = _U('player_vip_expired'),
                fields = {
                    { name = _U('player_name'), value = "\n```"..GetName(src).."\n```", inline = false},
                    { name = _U('date'), value = "\n```"..os.date().."\n```", inline = false},
                }
            })
            ExecuteSql("UPDATE mg_vip_players SET vip_tier = NULL, vip_expire_at = NULL WHERE identifier = ?", {identifier})
        end
    end
end

function AddDiamonds(playerId, amount)
    local identifier = GetPlayerIdentifier(playerId)
    if not identifier then return false end
    
    local vipData = GetPlayerVIPData(identifier)
    if not vipData then
        vipData = CreatePlayerVIPData(identifier)
    end
    
    local newDiamonds = vipData.diamonds + amount
    UpdatePlayerDiamonds(identifier, newDiamonds)
    
    TriggerClientEvent('mg-vipsystem:updatePlayerData', playerId, {
        diamonds = newDiamonds,
        totalSpent = vipData.total_spent,
        vipTier = GetPlayerVIPTier(identifier),
        purchaseHistory = GetPurchaseHistory(identifier)
    })
    
    return true
end
-- exports['mg-vipsystem']:AddDiamonds(source, amount)

function RemoveDiamonds(playerId, amount)
    local identifier = GetPlayerIdentifier(playerId)
    if not identifier then return false end
    
    local vipData = GetPlayerVIPData(identifier)
    if not vipData then return false end
    
    local newDiamonds = math.max(vipData.diamonds - amount, 0)
    UpdatePlayerDiamonds(identifier, newDiamonds)
    
    TriggerClientEvent('mg-vipsystem:updatePlayerData', playerId, {
        diamonds = newDiamonds,
        totalSpent = vipData.total_spent,
        vipTier = GetPlayerVIPTier(identifier),
        purchaseHistory = GetPurchaseHistory(identifier)
    })
    
    return true
end
-- exports['mg-vipsystem']:RemoveDiamonds(source, amount)
function SetVIP(playerId, tier)
    local identifier = GetPlayerIdentifier(playerId)
    if not identifier then return false end
    
    if tier and (tier < 1 or tier > #Config.VIPTiers) then
        return false
    end

    ExecuteSql("UPDATE mg_vip_players SET vip_tier = ? WHERE identifier = ?", {tier, identifier})
    
    TriggerClientEvent('mg-vipsystem:updatePlayerData', playerId, {
        diamonds = GetPlayerVIPData(identifier).diamonds,
        totalSpent = GetPlayerVIPData(identifier).total_spent,
        vipTier = tier,
        purchaseHistory = GetPurchaseHistory(identifier)
    })
    
    return true
end
-- exports['mg-vipsystem']:SetVIP(source, 2)
function RemoveVIP(playerId)
    return SetVIP(playerId, nil)
end
-- exports['mg-vipsystem']:RemoveVIP(source)
function CheckVIP(playerId)
    local identifier = GetPlayerIdentifier(playerId)
    if not identifier then return nil end
    
    local vipData = GetPlayerVIPData(identifier)
    if not vipData then return nil end
    
    if vipData.vip_tier and vipData.vip_expire_at then
        return {
            tier = vipData.vip_tier,
            expiresAt = vipData.vip_expire_at,
            active = os.time() < vipData.vip_expire_at
        }
    end
    
    return nil
end
-- exports['mg-vipsystem']:CheckVIP(source)
exports('AddDiamonds', AddDiamonds)
exports('RemoveDiamonds', RemoveDiamonds)
exports('SetVIP', SetVIP)
exports('RemoveVIP', RemoveVIP)
exports('CheckVIP', CheckVIP)


-- =========================
-- Sugerencias de chat (descripciones de comandos)
-- =========================

local function RegisterCommandSuggestionsFor(playerId)
    if not playerId then return end
    -- Dar diamantes
    TriggerClientEvent('chat:addSuggestion', playerId, '/'..Config.Commands.giveDiamonds,
        'Dar diamantes a un jugador.',
        {
            { name = 'playerId', help = 'ID del jugador (source)' },
            { name = 'amount',   help = 'Cantidad de diamantes a añadir' },
        }
    )

    -- Quitar diamantes
    TriggerClientEvent('chat:addSuggestion', playerId, '/'..Config.Commands.removeDiamonds,
        'Quitar diamantes a un jugador.',
        {
            { name = 'playerId', help = 'ID del jugador (source)' },
            { name = 'amount',   help = 'Cantidad de diamantes a quitar' },
        }
    )

    -- Fijar diamantes
    TriggerClientEvent('chat:addSuggestion', playerId, '/'..Config.Commands.setDiamonds,
        'Establecer los diamantes de un jugador.',
        {
            { name = 'playerId', help = 'ID del jugador (source)' },
            { name = 'amount',   help = 'Nuevo total de diamantes' },
        }
    )

    -- Set VIP
    TriggerClientEvent('chat:addSuggestion', playerId, '/'..Config.Commands.setVIP,
        'Asignar un nivel VIP a un jugador.',
        {
            { name = 'playerId', help = 'ID del jugador (source)' },
            { name = 'tier',     help = 'Nivel VIP (1 - #'..tostring(#Config.VIPTiers)..')' },
        }
    )

    -- Remove VIP
    TriggerClientEvent('chat:addSuggestion', playerId, '/'..Config.Commands.removeVIP,
        'Quitar el nivel VIP a un jugador.',
        {
            { name = 'playerId', help = 'ID del jugador (source)' },
        }
    )

    -- addDiamonds (Tebex) – solo consola
    TriggerClientEvent('chat:addSuggestion', playerId, '/darzcoins',
        'Registra/Canjea una transacción de Tebex (solo consola).',
        {
            { name = 'transactionId', help = 'ID de transacción de Tebex' },
            { name = 'amount',        help = 'Cantidad de diamantes' },
        }
    )
end

local function RegisterCommandSuggestionsAll()
    for _, src in ipairs(GetPlayers()) do
        RegisterCommandSuggestionsFor(tonumber(src))
    end
end
