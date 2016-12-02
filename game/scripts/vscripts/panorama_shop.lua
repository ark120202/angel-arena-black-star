if PanoramaShop == nil then
	_G.PanoramaShop = class({})
	PanoramaShop._RawItemData = {}
	PanoramaShop._ItemData = {}
	PanoramaShop.FormattedData = {}
end

function PanoramaShop:InitializeItemTable()
	local RecipesToCheck = {}
	--загрузка всех предметов, разделение на предмет/рецепт
	for name, kv in pairs(KeyValues.ItemKV) do
		if not table.contains(SHOP_IGNORED_ITEMS, name) and kv and type(kv) == "table" then
			if kv.ItemRecipe == 1 then
				RecipesToCheck[kv.ItemResult] = name
			end
			PanoramaShop._RawItemData[name] = kv
		end
	end
	--заполнение данных для каждого предмета
	local itemsBuldsInto = {}
	for name, kv in pairs(PanoramaShop._RawItemData) do
		local itemdata = {
			id = kv.ID or -1,
			purchasable = (kv.ItemPurchasable or 1) == 1 and (kv.ItemPurchasableFilter or 1) == 0,
			hidden = ((kv.ItemPurchasable or 1) == 0) or ((kv.ItemHidden or 0) == 1),
			cost = GetTrueItemCost(name),
			names = {name:lower()},
			Recipe = nil,
		}
		if kv.ItemAliases then
			for _,v in ipairs(string.split(kv.ItemAliases, ";")) do
				if not table.contains(itemdata.names, v:lower()) then
					table.insert(itemdata.names, v:lower())
				end
			end
		end
		local translated_english = LANG_ENGLISH["DOTA_Tooltip_Ability_" .. name] or LANG_ENGLISH["DOTA_Tooltip_ability_" .. name]
		if translated_english then
			if not table.contains(itemdata.names, translated_english:lower()) then
				table.insert(itemdata.names, translated_english:lower())
			end
		end
		local translated_russian = LANG_RUSSIAN["DOTA_Tooltip_Ability_" .. name] or LANG_RUSSIAN["DOTA_Tooltip_ability_" .. name]
		if translated_russian then
			if not table.contains(itemdata.names, translated_russian:lower()) then
				table.insert(itemdata.names, translated_russian:lower())
			end
		end
		if RecipesToCheck[name] then
			local recipedata = {
				visible = GetTrueItemCost(RecipesToCheck[name]) > 0,
				items = {},
				customLayout = false,
				cost = GetTrueItemCost(RecipesToCheck[name]),
				recipeItemName = RecipesToCheck[name],
			}
			local recipeKv = KeyValues.ItemKV[RecipesToCheck[name]]

			if not itemsBuldsInto[RecipesToCheck[name]] then itemsBuldsInto[RecipesToCheck[name]] = {} end
			if not table.contains(itemsBuldsInto[RecipesToCheck[name]], name) then
				table.insert(itemsBuldsInto[RecipesToCheck[name]], name)
			end
			for key, ItemRequirements in pairsByKeys(recipeKv.ItemRequirements) do
				local itemParts = string.split(string.gsub(ItemRequirements, " ", ""), ";")
				table.insert(recipedata.items, itemParts)
				for _,v in ipairs(itemParts) do
					if not itemsBuldsInto[v] then itemsBuldsInto[v] = {} end
					if not table.contains(itemsBuldsInto[v], name) then
						table.insert(itemsBuldsInto[v], name)
					end
				end
			end
			itemdata.Recipe = recipedata
		end
		PanoramaShop.FormattedData[name] = itemdata
	end
	for name,items in pairs(itemsBuldsInto) do
		if PanoramaShop.FormattedData[name] then
			PanoramaShop.FormattedData[name].BuildsInto = items
		end
	end
	--распределение данных по вкладкам и группам
	local Items = {}
	for shopName, shopData in pairs(PANORAMA_SHOP_ITEMS) do
		Items[shopName] = {}
		for groupName, groupData in pairs(shopData) do
			Items[shopName][groupName] = {}
			for _, itemName in ipairs(groupData) do
				if not PanoramaShop.FormattedData[itemName] then
					print("[PanoramaShop] Item defined in shop list is not defined in any of item KV files", itemName)
				else
					table.insert(Items[shopName][groupName], itemName)
				end
			end
		end
	end
	local allItembuilds = {}
	table.add(allItembuilds, ARENA_ITEMBUILDS)
	table.add(allItembuilds, VALVE_ITEMBUILDS)

	local itembuilds = {}
	for k,v in ipairs(allItembuilds) do
		if not itembuilds[v.hero] then itembuilds[v.hero] = {} end
		table.insert(itembuilds[v.hero], {
			title = v.title,
			author = v.author,
			patch = v.patch,
			description = v.description,
			items = v.items,
		})
	end
	PanoramaShop._ItemData = Items
	CustomGameEventManager:RegisterListener("panorama_shop_item_buy", Dynamic_Wrap(PanoramaShop, "OnItemBuy"))
	CustomGameEventManager:RegisterListener("panorama_shop_sell_item", Dynamic_Wrap(PanoramaShop, "OnItemSell"))
	PlayerTables:CreateTable("panorama_shop_data", {ItemData = PanoramaShop.FormattedData, ShopList = Items, Itembuilds = itembuilds}, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
end

function PanoramaShop:OnItemSell(data)
	if data and data.itemIndex and data.unit then
		local player = PlayerResource:GetPlayer(data.PlayerID)
		local itemEnt = EntIndexToHScript(tonumber(data.itemIndex))
		local ent = EntIndexToHScript(data.unit)

		if GetKeyValue(data.itemIndex, "ItemPurchasableFilter") ~= 0 and ent and ent.entindex and ent:GetPlayerOwner() == player and itemEnt and itemEnt:GetOwner():GetPlayerOwner() == player then
			local cost = GetTrueItemCost(itemEnt:GetAbilityName())
			if GameRules:GetGameTime() - itemEnt:GetPurchaseTime() > 10 then
				cost = cost / 2
			end
			if itemEnt:GetAbilityName() == "item_pocket_riki" then
				gold = Kills:GetGoldForKill(ability.RikiContainer)
				TrueKill(unit, ability, ability.RikiContainer)
				Kills:ClearStreak(ability.RikiContainer:GetPlayerID())
				unit:RemoveItem(ability)
				unit:RemoveModifierByName("modifier_item_pocket_riki_invisibility_fade")
				unit:RemoveModifierByName("modifier_item_pocket_riki_permanent_invisibility")
				unit:RemoveModifierByName("modifier_invisible")
				GameRules:SendCustomMessage("#riki_pocket_riki_chat_notify_text", 0, unit:GetTeamNumber()) 
			end
			UTIL_Remove(itemEnt)
			Gold:AddGoldWithMessage(ent, cost)
		end
	end
end

function PanoramaShop:OnItemBuy(data)
	if data and data.itemName and data.unit then
		local ent = EntIndexToHScript(data.unit)
		if ent and ent.entindex and ent:GetPlayerOwner() == PlayerResource:GetPlayer(data.PlayerID) then
			PanoramaShop:BuyItem(data.PlayerID, ent, data.itemName)
		end
	end
end

function PanoramaShop:BuyItem(playerID, unit, itemName)
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	local itemCounter = {}
	if Duel:IsDuelOngoing() then
		Containers:DisplayError(issuer_player_id_const, "#dota_hud_error_cant_purchase_duel_ongoing")
		return
	end
	local function GetPrimaryRecipeItems(childItemName)
		local primary_items = {}
		local itemData = PanoramaShop.FormattedData[childItemName]
		if itemData.Recipe and itemData.Recipe then
			for _, newchilditem in ipairs(itemData.Recipe.items[1]) do
				table.add(primary_items, GetPrimaryRecipeItems(newchilditem))
			end
			if itemData.Recipe.cost > 0 then
				table.insert(primary_items, itemData.Recipe.recipeItemName)
			end
		else
			table.insert(primary_items, childItemName)
		end
		return primary_items
	end
	local function GetAllPrimaryRecipeItems(childItemName)
		local primary_items = {}
		local itemData = PanoramaShop.FormattedData[childItemName]
		if itemData.Recipe and itemData.Recipe then
			for _, newchilditem in ipairs(itemData.Recipe.items[1]) do
				table.add(primary_items, GetAllPrimaryRecipeItems(newchilditem))
			end
			if itemData.Recipe.cost > 0 then
				table.insert(primary_items, itemData.Recipe.recipeItemName)
			end
		end
		table.insert(primary_items, childItemName)
		return primary_items
	end
	local function HasAnyOfItemChildren(childItemName)
		local primary_items = GetAllPrimaryRecipeItems(childItemName)
		for _,v in ipairs(primary_items) do
			if FindItemInInventoryByName(unit, v, true) then
				return true
			end
		end
		return false
	end
	local function IsItemChildrenPurchasable(childItemName)
		local primary_items = GetAllPrimaryRecipeItems(childItemName)
		table.insert(primary_items, childItemName)
		for _,v in ipairs(primary_items) do
			if GetKeyValue(v, "ItemPurchasableFilter") == 0 or GetKeyValue(v, "ItemPurchasable") == 0 then
				return false
			end
		end
		return true
	end
	local function GetItemCostRemaining(childItemName, _tempItemCounter, _cost)
		if not _tempItemCounter then
			_tempItemCounter = {}
		end
		if not _cost then
			_cost = 0
		end
		local itemData = PanoramaShop.FormattedData[childItemName]
		local itemcount = #GetAllItemsByNameInInventory(unit, childItemName, true)
		if (itemcount <= (_tempItemCounter[childItemName] or 0) or childItemName == itemName) and GetKeyValue(childItemName, "ItemPurchasableFilter") ~= 0 and GetKeyValue(childItemName, "ItemPurchasable") ~= 0 then
			if itemData.Recipe and HasAnyOfItemChildren(childItemName) then
				for _, newchilditem in ipairs(itemData.Recipe.items[1]) do
					_cost = _cost + GetItemCostRemaining(newchilditem, _tempItemCounter)
				end
				if itemData.Recipe.cost > 0 then
					_cost = _cost + itemData.Recipe.cost
				end
			else
				_cost = _cost + GetTrueItemCost(childItemName)
			end
		end
		_tempItemCounter[childItemName] = (_tempItemCounter[childItemName] or 0) + 1
		return _cost
	end
	local function DirectPurchaseItem(childItemName)
		Gold:ModifyGold(playerID, -GetTrueItemCost(childItemName))
		local item = CreateItem(childItemName, hero, hero)
		item:SetPurchaseTime(GameRules:GetGameTime())
		item:SetPurchaser(hero)

		local itemPushed = false
		local isInShop = unit:HasModifier("modifier_fountain_aura_arena")
		if isInShop then
			if unit:HasRoomForItem(itemName, true, true) ~= 4 then
				unit:AddItem(item)
				itemPushed = true
			end
		end
		if not itemPushed then
			if not isInShop then SetAllItemSlotsLocked(unit, true, true) end
			FillSlotsWithDummy(unit, false)
			for i = 6, 11 do
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
		if not itemPushed then
			local spawnPointName = "info_courier_spawn"
			local teamCared = true
			if PlayerResource:GetTeam(playerID) == DOTA_TEAM_GOODGUYS then
				spawnPointName = "info_courier_spawn_radiant"
				teamCared = false
			elseif PlayerResource:GetTeam(playerID) == DOTA_TEAM_BADGUYS then
				spawnPointName = "info_courier_spawn_dire"
				teamCared = false
			end
			local ent
			while true do
				ent = Entities:FindByClassname(ent, spawnPointName)
				if ent and (not teamCared or (teamCared and ent:GetTeam() == PlayerResource:GetTeam(playerID))) then
					local spawnPointAbs = ent:GetAbsOrigin()
					CreateItemOnPositionSync(spawnPointAbs, item)
					break
				end
			end
		end
	end
	local function purchaseItemPart(childItemName)
		local itemData = PanoramaShop.FormattedData[childItemName]
		local itemcount = #GetAllItemsByNameInInventory(unit, childItemName, true)
		if (itemcount <= (itemCounter[childItemName] or 0) or childItemName == itemName) and Gold:GetGold(playerID) >= GetItemCostRemaining(childItemName) then
			if itemData.Recipe and HasAnyOfItemChildren(childItemName) then
				for _, newchilditem in ipairs(itemData.Recipe.items[1]) do
					purchaseItemPart(newchilditem)
				end
				if itemData.Recipe.cost > 0 then
					purchaseItemPart(itemData.Recipe.recipeItemName)
				end
			else
				DirectPurchaseItem(childItemName)
			end
		end
		itemCounter[childItemName] = (itemCounter[childItemName] or 0) + 1
	end
	if Gold:GetGold(playerID) >= GetItemCostRemaining(itemName) then
		if IsItemChildrenPurchasable(itemName) then
			purchaseItemPart(itemName)
			Containers:EmitSoundOnClient(playerID, "General.Buy")
		else
			Containers:DisplayError(playerID, "dota_hud_error_item_from_bosses")
		end
	end
end