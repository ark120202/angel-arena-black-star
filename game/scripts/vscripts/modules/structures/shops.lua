function Structures:CreateShops()
	for _,v in ipairs(Entities:FindAllByName("target_mark_containers_shop_duel")) do
		local DuelShop = CreateItemOnPositionSync(v:GetAbsOrigin(), nil)
		DuelShop:SetModel("models/heroes/shopkeeper/shopkeeper.vmdl")
		DuelShop:SetForwardVector(Vector(0, -1, 0))
		DuelShop:SetModelScale(1.6)
		Structures:CreateShop(DuelShop, ShopsData.Duel, "#containers_shop_duel_name", 192, {3})
	end
end

function Structures:CreateShop(baseUnit, itemTable, shopName, radius, customItemGrid)
	local sItems, prices, stocks, grid = Structures:_CreateShopTable(itemTable)

	itemShop = Containers:CreateShop({
		layout =      customItemGrid or grid,
		skins =       {},
		headerText =  shopName,
		pids =        {},
		position =    "entity",
		entity =      baseUnit,
		items =       sItems,
		prices =      prices,
		stocks =      stocks,
		closeOnOrder= true,
		range =       radius,
		OnEntityOrder=function(playerId, container, unit, target)
			if unit and unit:IsAlive() and unit:IsTrueHero() then
				container:Open(playerId)
				unit:Stop()
			end
		end,
	})
end

function Structures:_CreateShopTable(ii)
	local sItems = {}
	local prices = {}
	local stocks = {}

	for _,i in ipairs(ii) do
		if type(i) == "table" then
			item = CreateItem(i.item, unit, unit)
			local index = item:GetEntityIndex()
			sItems[#sItems+1] = item
			prices[index] = i.cost or item:GetCost()
		else
			item = CreateItem(i, unit, unit)
			local index = item:GetEntityIndex()
			sItems[#sItems+1] = item
			prices[index] = item:GetCost()
			--if i[3] ~= nil then stocks[index] = i[3] end
		end
	end
	local grid = {}
	local gridSize = math.ceil(math.sqrt(#ii))
	for i = 1, gridSize do
		if gridSize * #grid < #ii then
			table.insert(grid, gridSize)
		end
	end

	return sItems, prices, stocks, grid
end
