function GetCore()
    local object = nil

    if Config.Framework == "oldesx" then
        local counter = 0
        while not object  do
            TriggerEvent('esx:getSharedObject', function(obj) object = obj end)
            counter = counter + 1
            if counter == 3 then
                break
            end
            Citizen.Wait(1000)
        end
        if not object then
          print("^5[mg-vipsystem] ^0 :> Framework is not selected in the config correctly if you're sure it's correct please check your events to get framework object")
        else
           print("^5[mg-vipsystem] ^0 :> Selected Framework : ", Config.Framework)
        end
    end

    if Config.Framework == "newesx" then
        local counter = 0
        local status = pcall(function()
            exports['es_extended']:getSharedObject()
        end)
        if status then
            while not object do
                object = exports['es_extended']:getSharedObject()
                counter = counter + 1
                if counter == 3 then
                    break
                end
                Citizen.Wait(1000)
            end
        end
        if not object then
          print("^5[mg-vipsystem] ^0 :> Framework is not selected in the config correctly if you're sure it's correct please check your events to get framework object")
        else
           print("^5[mg-vipsystem] ^0 :> Selected Framework : ", Config.Framework)
        end
    end

    if Config.Framework == "newqb" then
        local counter = 0
        local status = pcall(function ()
            exports["qb-core"]:GetCoreObject()
        end)
        if status then
            while not object  do
                object = exports["qb-core"]:GetCoreObject()
                counter = counter + 1
                if counter == 3 then
                    break
                end
                Citizen.Wait(1000)
            end
        end
        if not object then
          print("^5[mg-vipsystem] ^0 :> Framework is not selected in the config correctly if you're sure it's correct please check your events to get framework object")
        else
          print("^5[mg-vipsystem] ^0 :> Selected Framework : ", Config.Framework)
        end

    end

    if Config.Framework == "oldqb" then
        local counter = 0

        while  not object do
            counter = counter + 1
            TriggerEvent('QBCore:GetObject', function(obj) object = obj end)
            if counter == 3 then
                break
            end
            Citizen.Wait(1000)
        end
        if not object then
           print("^5[mg-vipsystem] ^0 :> Framework is not selected in the config correctly if you're sure it's correct please check your events to get framework object")
        else
           print("^5[mg-vipsystem] ^0 :> Selected Framework : ", Config.Framework)
        end
    end

    if Config.Framework == 'autodetect' then
        local counter = 0
        local breakLoop = false
        Citizen.CreateThread(function()
            while not object do
                counter = counter + 1
                if counter == 3 then
                    breakLoop = true
                    counter = 0
                end
                Citizen.Wait(700)
            end
        end)

        while not object do
            local status = pcall(function ()
                object = exports['es_extended']:getSharedObject()
            end)
            Citizen.Wait(1000)
            break
        end

        if object and Config.Framework == 'autodetect' then
            Config.Framework = 'newesx'
        end

        while not object do
            TriggerEvent('esx:getSharedObject', function(obj) object = obj end)
            if breakLoop then
                break
            end
            Citizen.Wait(1000)
        end

        if object and Config.Framework == 'autodetect' then
            Config.Framework = 'oldesx'
        end

        while not object do
            local status = pcall(function ()
                object = exports["qb-core"]:GetCoreObject()
            end)
            Citizen.Wait(1000)
            break
        end

        if object and Config.Framework == 'autodetect' then
            Config.Framework = 'newqb'
        end

        while not object do
            TriggerEvent('QBCore:GetObject', function(obj) object = obj end)
            if breakLoop then
                break
            end
            Citizen.Wait(1000)
        end

        if object and Config.Framework == 'autodetect' then
            Config.Framework = 'oldqb'
        end

        if not object then
          print("^5[mg-vipsystem] ^0 :> Auto detect couldn't detect your framework please check your event to get framework object")
        else
          print("^5[mg-vipsystem] ^0] :> Framework object found! You are using ", Config.Framework , "^0")
        end
    end

    return object
end