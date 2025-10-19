

SVConfig = {
    logSystem = false, -- if true logs are enabled, if false they are disabled
    webhooks = {
        tebexPurchase = '',
        purchaseRedeem = '',
        tierExpired = '',
        purchases = {
            item = '',
            weapon = '',
            vehicle = '',
            tier = '',
            money = '',
            mlo = '',
            
        },
        adminActions = {
            giveDiamonds = '',
            removeDiamonds = '',
            setDiamonds = '',
            setVIP = '',
            removeVIP = '',
        }
    }
}


function SendLogToDiscord(typeOrUrl, data)
    -- Even if the log system is disabled it will send the log for the mlo purchases if its enabled
    if not SVConfig.logSystem and typeOrUrl ~= SVConfig.webhooks.purchases.mlo then return end
    local webhook = type(typeOrUrl) == "string" and SVConfig.webhooks[typeOrUrl] or typeOrUrl
    if not webhook or webhook == '' then return end

    local embed = {
        title = data.title or "Vip System Logs",
        fields = {},
        color = 16753920, -- By default this is orange, you can change to whatever color you want
        timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
        footer = {
            text = "mg-vipsystem"
        }
    }

    if data.thumbnail and type(data.thumbnail) == "string" and data.thumbnail ~= "" then
        embed.thumbnail = { url = data.thumbnail }
    end

    for _, v in ipairs(data.fields or {}) do
        table.insert(embed.fields, {
            name = v.name,
            value = v.value,
            inline = v.inline == nil and true or v.inline
        })
    end

    local payload = {
        embeds = { embed }
    }

    PerformHttpRequest(webhook, function(code, body)
        if code ~= 204 then
            if Config.Debug then
                print('^5[mg-vipsystem] ^1Error^0 while sending log ('..tostring(typeOrUrl)..'): ', code, body)
            end
        end
    end, "POST", json.encode(payload), { ["Content-Type"] = "application/json" })
end
