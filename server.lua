local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('onResourceStart', function(resource) if GetCurrentResourceName() ~= resource then return end
	for k, v in pairs(Config.SellItems) do if not QBCore.Shared.Items[k] then print("Selling: Missing Item from QBCore.Shared.Items: '"..k.."'") end end
	for i = 1, #Config.CrackPool do if not QBCore.Shared.Items[Config.CrackPool[i]] then print("CrackPool: Missing Item from QBCore.Shared.Items: '"..Config.CrackPool[i].."'") end end
	for i = 1, #Config.WashPool do if not QBCore.Shared.Items[Config.WashPool[i]] then print("WashPool: Missing Item from QBCore.Shared.Items: '"..Config.WashPool[i].."'") end end
	for i = 1, #Config.PanPool do if not QBCore.Shared.Items[Config.PanPool[i]] then print("PanPool: Missing Item from QBCore.Shared.Items: '"..Config.PanPool[i].."'") end end
	for i = 1, #Config.Items.items do if not QBCore.Shared.Items[Config.Items.items[i].name] then print("Shop: Missing Item from QBCore.Shared.Items: '"..Config.Items.items[i].name.."'") end end
	local itemcheck = {}
	for _, v in pairs(Crafting) do for _, b in pairs(v) do for k, l in pairs(b) do if k ~= "amount" then itemcheck[k] = {} for j in pairs(l) do itemcheck[j] = {} end end end end end
	for k in pairs(itemcheck) do
		if not QBCore.Shared.Items[k] then print("Crafting recipe couldn't find item '"..k.."' in the shared") end
	end
end)

QBCore.Functions.CreateCallback('jim-mining:Check', function(source, cb, item, crafttable)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local hasitem = true
	local testtable = {}
	for k in pairs(crafttable[item]) do
		testtable[k] = false end
	for k, v in pairs(crafttable[item]) do
		if QBCore.Functions.GetPlayer(source).Functions.GetItemByName(k) and QBCore.Functions.GetPlayer(source).Functions.GetItemByName(k).amount >= v then
			testtable[k] = true if Config.Debug then print(k.." (x"..v..") found") end
		end
	end
	for k, v in pairs(testtable) do
		if not v then hasitem = false if Config.Debug then print(QBCore.Shared.Items[k].label.." NOT found") end end
	end
	Wait(0)
	if hasanyitem ~= nil then hasitem = false end
	if hasitem then cb(true) else cb(false) end
end)

QBCore.Functions.CreateCallback('jim-mining:ItemCheck', function(source, cb, item, cost)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local hasitem = false
	if Player.Functions.GetItemByName(item) then if Player.Functions.GetItemByName(item).amount >= cost then hasitem = true end end
	cb(hasitem)
end)

---Crafting
RegisterServerEvent('jim-mining:GetItem', function(data)
	print(json.encode(data.craftable[data.tablenumber]))
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	--This grabs the table from client and removes the item requirements
	if data.craftable[data.tablenumber]["amount"] then amount = data.craftable[data.tablenumber]["amount"] else amount = 1 end
	for k,v in pairs(data.craftable[data.tablenumber][data.item]) do
		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[tostring(k)], "remove", v)
		Player.Functions.RemoveItem(tostring(k), v)
		if Config.Debug then print("Removing "..tostring(k)) end
	end
	--This should give the item, while the rest removes the requirements
	Player.Functions.AddItem(data.item, amount)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[data.item], "add", amount)
	if Config.Debug then print("Giving Player "..tostring(data.item).." x"..amount) end
	TriggerClientEvent("jim-mining:CraftMenu", src, data)
end)

RegisterServerEvent('jim-mining:MineReward', function()
    local Player = QBCore.Functions.GetPlayer(source)
    local randomChance = math.random(1, 3)
    Player.Functions.AddItem('stone', randomChance, false, {["quality"] = nil})
    TriggerClientEvent("inventory:client:ItemBox", source, QBCore.Shared.Items["stone"], "add", randomChance)
end)

--Stone Cracking Checking Triggers
--Command here to check if any stone is in inventory
RegisterServerEvent('jim-mining:CrackReward', function(cost)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem('stone', cost)
    TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["stone"], "remove", 1)
	for i = 1, math.random(1,3) do
		local randItem = Config.CrackPool[math.random(1, #Config.CrackPool)]
		amount = math.random(1, 2)
		Player.Functions.AddItem(randItem, amount)
		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[randItem], 'add', amount)
	end
end)

--Stone Cracking Checking Triggers
--Command here to check if any stone is in inventory
RegisterServerEvent('jim-mining:WashReward', function(cost)
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem('stone', cost)
    TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["stone"], "remove", 1)
	for i = 1, math.random(1,2) do
		local randItem = Config.WashPool[math.random(1, #Config.WashPool)]
		amount = 1
		Player.Functions.AddItem(randItem, amount)
		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[randItem], 'add', amount)
		randItem = nil
	end
end)

RegisterServerEvent('jim-mining:PanReward', function()
	local src = source
    local Player = QBCore.Functions.GetPlayer(src)
	for i = 1, math.random(1,3) do
		local randItem = Config.PanPool[math.random(1, #Config.PanPool)]
		amount = 1
		Player.Functions.AddItem(randItem, amount)
		TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[randItem], 'add', amount)
		randItem = nil
	end
end)

RegisterNetEvent("jim-mining:Selling", function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.GetItemByName(data.item) ~= nil then
        local amount = Player.Functions.GetItemByName(data.item).amount
        local pay = (amount * Config.SellItems[data.item])
        Player.Functions.RemoveItem(data.item, amount)
        Player.Functions.AddMoney('cash', pay)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[data.item], 'remove', amount)
    else
        TriggerClientEvent("QBCore:Notify", src, Loc[Config.Lan].error["dont_have"].." "..QBCore.Shared.Items[data.item].label, "error")
    end
end)