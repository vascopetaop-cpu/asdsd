function InteractionHandler()
    Debug('^5[mg-vipsystem] ^0InteractionHandler started')

    if Config.VipStashInteraction == 'qb-target' then
        exports['qb-target']:AddBoxZone("VipStash", Config.VipStashCoords, 2.0, 2.0, {
            name = "vip_stash",
            heading = 0,
            debugPoly = Config.Debug,
            minZ = Config.VipStashCoords.z - 1,
            maxZ = Config.VipStashCoords.z + 1
        }, {
            options = {
                {
                    num = 1,
                    type = "client",
                    icon = 'fas fa-briefcase',
                    label = 'Open VIP Stash',
                    action = function()
                        TriggerServerEvent('mg-vipsystem:openVipStash')
                    end
                }
            },
            distance = 2.0
        })

    elseif Config.VipStashInteraction == 'ox-target' then
        exports.ox_target:addBoxZone({
            name = "vip_stash",
            coords = Config.VipStashCoords,
            size = vec3(2.0, 2.0, 2.0),
            drawSprite = true,
            options = {
                {
                    type = "client",
                    icon = 'fas fa-briefcase',
                    label = 'Open VIP Stash',
                    onSelect = function()
                        TriggerServerEvent('mg-vipsystem:openVipStash')
                    end
                }
            }
        })

    else
        local isTextUiOpen = false
        CreateThread(function()
            while true do
                local playerPed = PlayerPedId()
                local sleep = 1500
                local playerCoords = GetEntityCoords(playerPed)
                local distance = #(playerCoords - Config.VipStashCoords)

                if distance < 2.0 then
                    sleep = 5

                    if Config.VipStashInteraction == 'codem-textui' then
                        if not isTextUiOpen then
                            exports["codem-textui"]:OpenTextUI('Open Vip Stash', 'E', 'thema-6')
                            isTextUiOpen = true
                        end
                    else
                        DrawText3D(Config.VipStashCoords.x, Config.VipStashCoords.y, Config.VipStashCoords.z, '[~g~ E ~w~] ' .. 'Open VIP Stash')
                    end

                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('mg-vipsystem:openVipStash')
                    end
                else
                    if isTextUiOpen and Config.VipStashInteraction == 'codem-textui' then
                        exports["codem-textui"]:CloseTextUI()
                        isTextUiOpen = false
                    end
                end

                Wait(sleep)
            end
        end)
    end
end

function OpenStash(stashID)
    if Config.Inventory == 'codem-inventory' then
        TriggerServerEvent('codem-inventory:server:openstash', stashID, 50, 1000000, 'VIP Stash')
    elseif Config.Inventory == 'qb-inventory' then
        TriggerServerEvent('qb-inventory:server:OpenInventory', 'stash', stashID, {
            maxweight = 1000000,
            slots = 50,
            label = 'VIP Stash'
        })
    elseif Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:openInventory('stash', stashID)
    elseif Config.Inventory == 'qs-inventory' then
        local other = {}
        other.maxweight = 10000 -- Custom weight stash
        other.slots = 50 -- Custom slots spaces
        TriggerServerEvent("inventory:server:OpenInventory", "stash", stashID, other)
        TriggerEvent("inventory:client:SetCurrentStash", stashID)
    end
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
    local factor = (string.len(text)) / 370
    DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
end

RegisterNetEvent('mg-vipsystem:client:OpenCodemStash', function(stashID)
    TriggerServerEvent('codem-inventory:server:openstash', stashID, 50, 1000000, 'VIP Stash')
end)

function Debug(text)
    if Config.DebugPrint then
        print(text)
    end
end
