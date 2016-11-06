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
	table.merge(allItembuilds, VALVE_ITEMBUILDS)

	local itembuilds = {}
	for _,v in ipairs(allItembuilds) do
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
	PlayerTables:CreateTable("panorama_shop_data", {ItemData = PanoramaShop.FormattedData, ShopList = Items, Itembuilds = itembuilds}, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
end

--[[function PanoramaShop:OnItemBuy(data)
	if data and type(data) == "table" and data.PlayerID and data.itemName and data.unit and IsValidEntity(EntIndexToHScript(data.unit)) then
		PanoramaShop:BuyItem(data.PlayerID, EntIndexToHScript(data.unit), data.itemName)
	end
end

function PanoramaShop:BuyItem(playerID, unit, itemName, baseItem)
	--[[local newOrder = {
 		UnitIndex = unit:GetEntityIndex(), 
 		OrderType = DOTA_UNIT_ORDER_PURCHASE_ITEM,
 		AbilityIndex = GetItemIdByName(itemName),
 		TargetIndex = 0,
 		Queue = 0,
 		playerID = playerID,
 	}
	PrintTable(newOrder)
	ExecuteOrderFromTable(newOrder)

	local cost = GetTrueItemCost(itemName)
	local itemData = PanoramaShop.FormattedData[itemName]
	local hero = PlayerResource:GetSelectedHeroEntity(playerID)
	if GetKeyValue(itemName, "ItemPurchasableFilter") ~= 0 and GetKeyValue(itemName, "ItemPurchasable") ~= 0 and Gold:GetGold(playerID) >= cost then
		if itemData.Recipe then
			for _, item in ipairs(itemData.Recipe.items[1]) do
				if not FindItemInInventoryByName(unit, item, true) then
					PanoramaShop:BuyItem(playerID, unit, item, baseItem or itemName)
				end
			end
			if itemData.Recipe.cost > 0 then
				PanoramaShop:BuyItem(playerID, unit, itemData.Recipe.recipeItemName, baseItem or itemName)
			end
		else
			if not FindItemInInventoryByName(unit, itemName, true) or FindItemInInventoryByName(unit, baseItem or itemName, true) then
				Gold:ModifyGold(playerID, -cost, nil, DOTA_ModifyGold_PurchaseItem)
				local item = CreateItem(itemName, hero, hero)
				item:SetPurchaseTime(Time())
				item:SetPurchaser(hero)
				local itemPushed = false
				local isInShop = table.contains(Heroes_In_Shop_Zone, unit)
				if isInShop then
					FillSlotsWithDummy(unit)
					for i = 0, 5 do
						local citem = unit:GetItemInSlot(i)
						if citem and citem:GetName() == "item_dummy" then
							UTIL_Remove(citem)
							unit:AddItem(item)
							itemPushed = true
							break
						end
					end
					ClearSlotsFromDummy(unit)
				end
				if not itemPushed then
					--[[FillSlotsWithDummy(unit)
					local dummy_inv = {}
					local avaliable_slot_index
					for i = 0, 5 do
						local citem = unit:GetItemInSlot(i)
						--unit:RemoveItem(citem)
						dummy_inv[i] = citem
						unit:DropItemAtPositionImmediate(citem, Vector(0,0,0))
					end

					for i = 6, 11 do
						local citem = unit:GetItemInSlot(i)
						if citem and citem:GetName() == "item_dummy" and not avaliable_slot_index then
							avaliable_slot_index = i
						end
					end
					if avaliable_slot_index then
						FillSlotsWithDummy(unit)
						local citem = unit:GetItemInSlot(avaliable_slot_index)
						if citem and citem:GetName() == "item_dummy" then
							UTIL_Remove(citem)
							unit:AddItem(item)
							ClearSlotsFromDummy(unit)
							Timers:CreateTimer(0.01, function()
									GameRules:GetGameModeEntity():SetStashPurchasingDisabled(false)
								for i,v in pairs(dummy_inv) do
									if i ~= avaliable_slot_index then
										unit:AddItem(v)
									end
								end
									GameRules:GetGameModeEntity():SetStashPurchasingDisabled(true)
								ClearSlotsFromDummy(unit)
							end)
							itemPushed = true
						end
					end
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
		end
	end
end]]