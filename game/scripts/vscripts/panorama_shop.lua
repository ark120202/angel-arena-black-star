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