ModuleRequire(..., "data")

if PanoramaShop == nil then
	_G.PanoramaShop = class({})
	PanoramaShop._RawItemData = {}
	PanoramaShop._ItemData = {}
	PanoramaShop.FormattedData = {}
	PanoramaShop.StocksTable = {
		[DOTA_TEAM_GOODGUYS] = {},
		[DOTA_TEAM_BADGUYS] = {},
		[DOTA_TEAM_CUSTOM_1] = {},
		[DOTA_TEAM_CUSTOM_2] = {},
	}
end

Events:Register("activate", function ()
	GameRules:GetGameModeEntity():SetStickyItemDisabled(true)
	PanoramaShop.ShopTriggers = Entities:FindAllByClassname("trigger_shop")
	PanoramaShop:InitializeItemTable()
end)

function PanoramaShop:PushStockInfoToAllClients()
	for team,tt in pairs(PanoramaShop.StocksTable) do
		local ItemStocks = PlayerTables:GetTableValue("panorama_shop_data", "ItemStocks_team" .. team) or {}
		for item,v in pairs(tt) do
			ItemStocks[item] = {
				current_stock = v.current_stock,
				current_cooldown = v.current_cooldown,
				current_last_purchased_time = v.current_last_purchased_time,
			}
		end
		PlayerTables:SetTableValue("panorama_shop_data", "ItemStocks_team" .. team, ItemStocks)
	end
end

function PanoramaShop:GetItemStockCooldown(team, item)
	local t = PanoramaShop.StocksTable[team][item]
	return t ~= nil and (t.current_cooldown - (GameRules:GetGameTime() - t.current_last_purchased_time))
end

function PanoramaShop:GetItemStockCount(team, item)
	local t = PanoramaShop.StocksTable[team][item]
	return t ~= nil and t.current_stock
end

function PanoramaShop:AddItemStock(team, item, count)
	local t = PanoramaShop.StocksTable[team][item]
	if t then
		local added_stocks = t.current_stock + count
		if added_stocks > t.ItemStockMax then
			added_stocks = t.ItemStockMax
		end
		t.current_stock = added_stocks
		PanoramaShop:PushStockInfoToAllClients()
	end
end

function PanoramaShop:IncreaseItemStock(team, item)
	local t = PanoramaShop.StocksTable[team][item]
	if t and (t.ItemStockMax == -1 or t.current_stock < t.ItemStockMax) then
		t.current_stock = t.current_stock + 1
		if (t.ItemStockMax == -1 or t.current_stock < t.ItemStockMax) then
			PanoramaShop:StackStockableCooldown(team, item, t.ItemStockTime)
		end
		PanoramaShop:PushStockInfoToAllClients()
	end
end

function PanoramaShop:DecreaseItemStock(team, item)
	local t = PanoramaShop.StocksTable[team][item]
	if t and t.current_stock > 0 then
		if t.current_stock == t.ItemStockMax then
			PanoramaShop:StackStockableCooldown(team, item, t.ItemStockTime)
		end
		t.current_stock = t.current_stock - 1
		PanoramaShop:PushStockInfoToAllClients()
	end
end

function PanoramaShop:StackStockableCooldown(team, item, time)
	local t = PanoramaShop.StocksTable[team][item]
	if GameRules:State_Get() < DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		time = time - GameRules:GetDOTATime(false, true)
	end
	t.current_cooldown = time
	t.current_last_purchased_time = GameRules:GetGameTime()
	if t.timer then
		Timers:RemoveTimer(t.timer)
	end
	t.timer = Timers:CreateTimer(time, function()
		PanoramaShop:IncreaseItemStock(team, item)
		t.timer = nil
	end)
end

function PanoramaShop:InitializeItemTable()
	local RecipesToCheck = {}
	-- loading all items and splitting them by item/recipe
	for name, kv in pairs(KeyValues.ItemKV) do
		if type(kv) == "table" and (kv.ItemPurchasable or 1) == 1 then
			if kv.ItemRecipe == 1 then
				RecipesToCheck[kv.ItemResult] = name
			end
			PanoramaShop._RawItemData[name] = kv
		end
	end
	-- adding data for each item
	local itemsBuldsInto = {}
	for name, kv in pairs(PanoramaShop._RawItemData) do
		local itemdata = {
			id = kv.ID or -1,
			purchasable = (kv.ItemPurchasable or 1) == 1 and (kv.ItemPurchasableFilter or 1) == 1,
			cost = GetTrueItemCost(name),
			names = {name:lower()},
		}

		if kv.ItemAliases then
			for _,v in ipairs(string.split(kv.ItemAliases, ";")) do
				if not table.includes(itemdata.names, v:lower()) then
					table.insert(itemdata.names, v:lower())
				end
			end
		end

		if RecipesToCheck[name] then
			local recipedata = {
				visible = GetTrueItemCost(RecipesToCheck[name]) > 0,
				items = {},
				cost = GetTrueItemCost(RecipesToCheck[name]),
				recipeItemName = RecipesToCheck[name],
			}
			local recipeKv = KeyValues.ItemKV[RecipesToCheck[name]]

			if not itemsBuldsInto[RecipesToCheck[name]] then itemsBuldsInto[RecipesToCheck[name]] = {} end
			if not table.includes(itemsBuldsInto[RecipesToCheck[name]], name) then
				table.insert(itemsBuldsInto[RecipesToCheck[name]], name)
			end
			for key, ItemRequirements in pairsByKeys(recipeKv.ItemRequirements) do
				local itemParts = string.split(string.gsub(ItemRequirements, " ", ""), ";")
				table.insert(recipedata.items, itemParts)
				for _,v in ipairs(itemParts) do
					if not itemsBuldsInto[v] then itemsBuldsInto[v] = {} end
					if not table.includes(itemsBuldsInto[v], name) then
						table.insert(itemsBuldsInto[v], name)
					end
				end
			end
			itemdata.Recipe = recipedata
		end

		if kv.ItemStockMax or kv.ItemStockTime or kv.ItemInitialStockTime or kv.ItemStockInitial then
			local stocks = {
				ItemStockMax = kv.ItemStockMax or -1,
				ItemStockTime = kv.ItemStockTime or 0,
				current_stock = kv.ItemStockInitial,
				current_cooldown = kv.ItemInitialStockTime or 0,
				current_last_purchased_time = -1,
			}
			if not stocks.current_stock then
				if stocks.current_cooldown == 0 then
					stocks.current_stock = kv.ItemStockInitial or kv.ItemStockMax or 0
				else
					stocks.current_stock = 0
				end
			end
			for k,_ in pairs(PanoramaShop.StocksTable) do
				PanoramaShop.StocksTable[k][name] = {}
				table.merge(PanoramaShop.StocksTable[k][name], stocks)
			end
		end
		PanoramaShop.FormattedData[name] = itemdata
	end

	for unit,itemlist in pairs(DROP_TABLE) do
		for _,v in ipairs(itemlist) do
			local iteminfo = PanoramaShop.FormattedData[v.Item]
			if iteminfo.Recipe then
				print("[PanoramaShop] Item that has recipe is defined in unit drop table", itemName)
			else
				if not iteminfo.DropListData then
					iteminfo.DropListData = {}
				end
				if not iteminfo.DropListData[unit] then
					iteminfo.DropListData[unit] = {}
				end

				table.insert(iteminfo.DropListData[unit], v.DropChance)
			end
		end
	end

	for name,items in pairs(itemsBuldsInto) do
		if PanoramaShop.FormattedData[name] then
			PanoramaShop.FormattedData[name].BuildsInto = items
		end
	end

	-- checking all items in shop list
	local Items = {}
	for shopName, shopData in pairs(PANORAMA_SHOP_ITEMS) do
		Items[shopName] = {}
		for groupName, groupData in pairs(shopData) do
			Items[shopName][groupName] = {}
			for _, itemName in ipairs(groupData) do
				if not PanoramaShop.FormattedData[itemName] and itemName ~= "__indent__" then
					print("[PanoramaShop] Item defined in shop list is not defined in any of item KV files", itemName)
				else
					table.insert(Items[shopName][groupName], itemName)
				end
			end
		end
	end

	PanoramaShop._ItemData = Items
	CustomGameEventManager:RegisterListener("panorama_shop_item_buy", Dynamic_Wrap(PanoramaShop, "OnItemBuy"))
	PlayerTables:CreateTable("panorama_shop_data", {ItemData = PanoramaShop.FormattedData, ShopList = Items}, AllPlayersInterval)
	PanoramaShop:PushStockInfoToAllClients()
end

function PanoramaShop:StartItemStocks()
	for team,v in pairs(PanoramaShop.StocksTable) do
		for item,stocks in pairs(v) do
			if stocks.current_cooldown > 0 then
				PanoramaShop:StackStockableCooldown(team, item, stocks.current_cooldown)
			elseif stocks.ItemStockMax == -1 or stocks.current_stock < stocks.ItemStockMax then
				PanoramaShop:StackStockableCooldown(team, item, stocks.ItemStockTime)
			end
		end
	end
	PanoramaShop:PushStockInfoToAllClients()
end

function PanoramaShop:OnItemBuy(data)
	if data and data.itemName and data.unit then
		local ent = EntIndexToHScript(data.unit)
		if ent and ent.entindex and (ent:GetPlayerOwner() == PlayerResource:GetPlayer(data.PlayerID) or ent == Structures:GetCourier(data.PlayerID)) then
			PanoramaShop:BuyItem(data.PlayerID, ent, data.itemName)
		end
	end
end

function PanoramaShop:SellItem(playerId, unit, item)
	local itemname = item:GetAbilityName()
	local cost = item:GetCost()
	if unit.ChangingHeroProcessRunning or
		unit:IsIllusion() or
		unit:IsTempestDouble() or
		unit:IsStunned() then
		return
	end
	if GameRules:IsGamePaused() then
		Containers:DisplayError(playerId, "#dota_hud_error_game_is_paused")
		return
	end
	if not item:IsSellable() or MeepoFixes:IsMeepoClone(unit) then
		Containers:DisplayError(playerId, "dota_hud_error_cant_sell_item")
		return
	end
	if item:IsStackable() then
		local chargesRate = item:GetCurrentCharges() / item:GetInitialCharges()
		cost = cost * chargesRate
	end
	if GameRules:GetGameTime() - item:GetPurchaseTime() > 10 then
		cost = cost / 2
	end
	local itemName = item:GetAbilityName()
	local team = PlayerResource:GetTeam(playerId)
	if PanoramaShop.StocksTable[team][itemName] then
		local charges = item:GetCurrentCharges()
		if charges == 0 then charges = 1 end
		PanoramaShop:AddItemStock(team, itemName, charges)
	end
	UTIL_Remove(item)
	Gold:AddGoldWithMessage(unit, cost, playerId)
	GameMode:TrackInventory(unit)
end

function PanoramaShop:IsInShop(unit)
	for _, trigger in ipairs(PanoramaShop.ShopTriggers) do
		if IsInTriggerBox(trigger, 0, unit:GetAbsOrigin()) then
			return true
		end
	end
	return false
end

function PanoramaShop:PushItem(playerId, unit, itemName, bOnlyStash)
	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	local team = PlayerResource:GetTeam(playerId)
	local item = CreateItem(itemName, hero, hero)
	local isInShop = PanoramaShop:IsInShop(unit)
	item:SetPurchaseTime(GameRules:GetGameTime())
	item:SetPurchaser(hero)

	local itemPushed = false
	--If unit has slot for that item
	if isInShop and not bOnlyStash then
		if unit:UnitHasSlotForItem(itemName, true) then
			unit:AddItem(item)
			itemPushed = true
		end
	end

	--Try to add item to hero's stash
	if not itemPushed then
		if unit == Structures:GetCourier(playerId) then
			unit = hero
		end
		-- Stackable item abuse fix, not very good, but that's all I can do without smth like SetStackable
		local hasSameStackableItem = item:IsStackable() and unit:HasItemInInventory(itemName)
		if hasSameStackableItem then
			Notifications:Bottom(playerId, {text="panorama_shop_stackable_purchase", style = {color = "red"}, duration = 4.5})
		else
			if not isInShop then SetAllItemSlotsLocked(unit, true, true) end
			FillSlotsWithDummy(unit, false)
			for i = DOTA_STASH_SLOT_1 , DOTA_STASH_SLOT_6 do
				local current_item = unit:GetItemInSlot(i)
				if current_item and current_item:GetAbilityName() == "item_dummy" then
					UTIL_Remove(current_item)
					unit:AddItem(item)
					itemPushed = true
					break
				end
			end
			ClearSlotsFromDummy(unit, false)
			if not isInShop then SetAllItemSlotsLocked(unit, false, true) end
		end
	end

	if itemPushed then
		if item.OnPurchased then item:OnPurchased() end
	else
		-- At last drop an item on fountain
		local spawnPointName = "info_courier_spawn"
		local teamCared = true
		if PlayerResource:GetTeam(playerId) == DOTA_TEAM_GOODGUYS then
			spawnPointName = "info_courier_spawn_radiant"
			teamCared = false
		elseif PlayerResource:GetTeam(playerId) == DOTA_TEAM_BADGUYS then
			spawnPointName = "info_courier_spawn_dire"
			teamCared = false
		end
		local ent
		while true do
			ent = Entities:FindByClassname(ent, spawnPointName)
			if ent and (not teamCared or (teamCared and ent:GetTeam() == PlayerResource:GetTeam(playerId))) then
				CreateItemOnPositionSync(ent:GetAbsOrigin() + RandomVector(RandomInt(0, 300)), item)
				break
			end
		end
	end
end

function PanoramaShop:GetNumDroppedItemsForPlayer(playerId)
	local droppedItems = 0
	for i = 0, GameRules:NumDroppedItems() - 1 do
		local item = GameRules:GetDroppedItem(i):GetContainedItem()
		if IsValidEntity(item) then
			local owner = item:GetPurchaser()
			if IsValidEntity(owner) and owner:GetPlayerID() == playerId then
				droppedItems = droppedItems + 1
			end
		end
	end
	return droppedItems
end

SHOP_LIST_STATUS_IN_INVENTORY = 0
SHOP_LIST_STATUS_IN_STASH = 1
SHOP_LIST_STATUS_TO_BUY = 2
SHOP_LIST_STATUS_NO_STOCK = 3
SHOP_LIST_STATUS_NO_BOSS = 4

function PanoramaShop:GetAllItemsByNameInInventory(unit, itemname, bBackpack)
	local items = {}
	for slot = 0, bBackpack and DOTA_STASH_SLOT_6 or DOTA_ITEM_SLOT_10 do
		local item = unit:GetItemInSlot(slot)
		if item and item:GetAbilityName() == itemname and item:GetPurchaser() == unit then
			table.insert(items, item)
		end
	end
	return items
end

function PanoramaShop:GetAllPrimaryRecipeItems(unit, childItemName, baseItemName)
	local primary_items = {}
	local itemData = PanoramaShop.FormattedData[childItemName]
	local _tempItemCounter = {}
	_tempItemCounter[childItemName] = (_tempItemCounter[childItemName] or 0) + 1

	--local itemcount_all = #PanoramaShop:GetAllItemsByNameInInventory(unit, childItemName, true)
	local itemcount = #PanoramaShop:GetAllItemsByNameInInventory(unit, childItemName, true)
	--isInShop and itemcount_all or itemcount_all - #PanoramaShop:GetAllItemsByNameInInventory(unit, childItemName, false)
	if (childItemName == baseItemName or itemcount < _tempItemCounter[childItemName]) and itemData.Recipe then
		for _, newchilditem in ipairs(itemData.Recipe.items[1]) do
			local subitems, newCounter = PanoramaShop:GetAllPrimaryRecipeItems(unit, newchilditem, baseItemName)
			table.add(primary_items, subitems)
			for k,v in pairs(newCounter) do
				_tempItemCounter[k] = (_tempItemCounter[k] or 0) + v
			end
		end
		if itemData.Recipe.cost > 0 then
			table.insert(primary_items, itemData.Recipe.recipeItemName)
			_tempItemCounter[itemData.Recipe.recipeItemName] = (_tempItemCounter[itemData.Recipe.recipeItemName] or 0) + 1
		end
	end
	table.insert(primary_items, childItemName)
	return primary_items, _tempItemCounter
end

function PanoramaShop:HasAnyOfItemChildren(unit, team, childItemName, baseItemName)
	if not PanoramaShop.FormattedData[childItemName].Recipe then return false end
	local primary_items = PanoramaShop:GetAllPrimaryRecipeItems(unit, childItemName, baseItemName)
	table.removeByValue(primary_items, childItemName)
	for _,v in ipairs(primary_items) do
		local stocks = PanoramaShop:GetItemStockCount(team, v)
		if FindItemInInventoryByName(unit, v, true) or GetKeyValue(v, "ItemPurchasableFilter") == 0 or GetKeyValue(v, "ItemPurchasable") == 0 or stocks then
			return true
		end
	end
	return false
end

function PanoramaShop:BuyItem(playerId, unit, itemName)
	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	local team = PlayerResource:GetTeam(playerId)
	if GameRules:IsGamePaused() then
		Containers:DisplayError(playerId, "#dota_hud_error_game_is_paused")
		return
	end

	if Duel:IsDuelOngoing() then
		Containers:DisplayError(playerId, "#dota_hud_error_cant_purchase_duel_ongoing")
		return
	end

	if PanoramaShop:GetNumDroppedItemsForPlayer(playerId) >= PANORAMA_SHOP_DROPPED_ITEMS_LIMIT then
		Containers:DisplayError(playerId, "#arena_hud_error_panorama_shop_dropped_items_limit")
		return
	end

	if unit:IsIllusion() or unit:IsTempestDouble() or not unit:HasInventory() then
		unit = hero
	end
	local isInShop = unit:HasModifier("modifier_fountain_aura_arena")

	local itemCounter = {}
	local ProbablyPurchasable = {}

	function DefineItemState(name)
		local has = PanoramaShop:HasAnyOfItemChildren(unit, team, name, itemName)
		--print(name, has)
		if has then
			InsertItemChildrenToCheck(name)
		else
			itemCounter[name] = (itemCounter[name] or 0) + 1
			local itemcount_inv = #PanoramaShop:GetAllItemsByNameInInventory(unit, name, false)
			local itemcount_stash = #PanoramaShop:GetAllItemsByNameInInventory(unit, name, true) - itemcount_inv
			local stocks = PanoramaShop:GetItemStockCount(team, name)
			if name ~= itemName and itemcount_stash >= itemCounter[name] then
				ProbablyPurchasable[name .. "_index_" .. itemCounter[name]] = SHOP_LIST_STATUS_IN_STASH
			elseif name ~= itemName and itemcount_inv >= itemCounter[name] then
				ProbablyPurchasable[name .. "_index_" .. itemCounter[name]] = SHOP_LIST_STATUS_IN_INVENTORY
			elseif GetKeyValue(name, "ItemPurchasableFilter") == 0 or GetKeyValue(name, "ItemPurchasable") == 0 then
				ProbablyPurchasable[name .. "_index_" .. itemCounter[name]] = SHOP_LIST_STATUS_NO_BOSS
			elseif stocks and stocks < 1 then
				ProbablyPurchasable[name .. "_index_" .. itemCounter[name]] = SHOP_LIST_STATUS_NO_STOCK
			else
				ProbablyPurchasable[name .. "_index_" .. itemCounter[name]] = SHOP_LIST_STATUS_TO_BUY
			end
		end
	end

	function InsertItemChildrenToCheck(name)
		local itemData = PanoramaShop.FormattedData[name]
		if itemData.Recipe then
			for _, newchilditem in ipairs(itemData.Recipe.items[1]) do
				DefineItemState(newchilditem)
			end
			if itemData.Recipe.cost > 0 then
				DefineItemState(itemData.Recipe.recipeItemName)
			end
		end
	end

	DefineItemState(itemName)

	local ItemsInInventory = {}
	local ItemsInStash = {}
	local ItemsToBuy = {}
	local wastedGold = 0
	for name,status in pairs(ProbablyPurchasable) do
		name = string.gsub(name, "_index_%d+", "")
		if status == SHOP_LIST_STATUS_NO_BOSS then
			Containers:DisplayError(playerId, "dota_hud_error_item_from_bosses")
			return
		elseif status == SHOP_LIST_STATUS_NO_STOCK then
			Containers:DisplayError(playerId, "dota_hud_error_item_out_of_stock")
			return
		elseif status == SHOP_LIST_STATUS_TO_BUY then
			wastedGold = wastedGold + GetTrueItemCost(name)
			table.insert(ItemsToBuy, name)
		elseif status == SHOP_LIST_STATUS_IN_INVENTORY then
			table.insert(ItemsInInventory, name)
		elseif status == SHOP_LIST_STATUS_IN_STASH then
			table.insert(ItemsInStash, name)
		end
	end

	if Gold:GetGold(playerId) >= wastedGold then
		Containers:EmitSoundOnClient(playerId, "General.Buy")
		Gold:RemoveGold(playerId, wastedGold)

		if isInShop then
			for _,v in ipairs(ItemsInStash) do
				local removedItem = FindItemInInventoryByName(unit, v, true, not isInShop)
				if not removedItem then removedItem = FindItemInInventoryByName(unit, v, false) end
				unit:RemoveItem(removedItem)
			end
			for _,v in ipairs(ItemsInInventory) do
				local removedItem = FindItemInInventoryByName(unit, v, false)
				if not removedItem then removedItem = FindItemInInventoryByName(unit, v, true, true) end
				unit:RemoveItem(removedItem)
			end
			for _,v in ipairs(ItemsToBuy) do
				if PanoramaShop.StocksTable[team][v] then
					PanoramaShop:DecreaseItemStock(team, v)
				end
			end
			PanoramaShop:PushItem(playerId, unit, itemName)
			if PanoramaShop.StocksTable[team][itemName] then
				PanoramaShop:DecreaseItemStock(team, itemName)
			end
		elseif #ItemsInInventory == 0 and #ItemsInStash > 0 then
			for _,v in ipairs(ItemsInStash) do
				unit:RemoveItem(FindItemInInventoryByName(unit, v, true, false))
			end
			PanoramaShop:PushItem(playerId, unit, itemName, true)
			if PanoramaShop.StocksTable[team][itemName] then
				PanoramaShop:DecreaseItemStock(team, itemName)
			end
		else
			for _,v in ipairs(ItemsToBuy) do
				PanoramaShop:PushItem(playerId, unit, v)
				if PanoramaShop.StocksTable[team][v] then
					PanoramaShop:DecreaseItemStock(team, v)
				end
			end
		end

		GameMode:TrackInventory(unit)
	end
end
