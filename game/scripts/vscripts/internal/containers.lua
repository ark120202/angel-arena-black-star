if ContainersHelper == nil then
	ContainersHelper = class({})
	ContainersHelper._OpenedContainers = {}
end

function ContainersHelper:CreateShops()
	for _,v in ipairs(Entities:FindAllByName("target_mark_containers_shop_secret")) do
		local SecretShop = CreateItemOnPositionSync(v:GetAbsOrigin(), nil) 
		SecretShop:SetModel("models/courier/smeevil_magic_carpet/smeevil_magic_carpet.vmdl")
		SecretShop:SetForwardVector(Vector(0, -1, 0))
		SecretShop:SetModelScale(2)
		ContainersHelper:CreateShop(SecretShop, ShopsData.Secret, "#containers_shop_secret_name", 192)
	end
	for _,v in ipairs(Entities:FindAllByName("target_mark_containers_shop_duel")) do
		local DuelShop = CreateItemOnPositionSync(v:GetAbsOrigin(), nil) 
		DuelShop:SetModel("models/courier/greevil/gold_greevil.vmdl")
		DuelShop:SetForwardVector(Vector(0, 1, 0.2))
		DuelShop:SetModelScale(1.75)
		ContainersHelper:CreateShop(DuelShop, ShopsData.Duel, "#containers_shop_duel_name", 192, {3})
	end
end

function ContainersHelper:CreateShop(baseUnit, itemTable, shopName, radius, customItemGrid)
	local sItems,prices,stocks = ContainersHelper:CreateShopTable(itemTable)

	itemShop = Containers:CreateShop({
		layout =      customItemGrid or ContainersHelper:CreateItemGrid(#itemTable),
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
		OnEntityOrder=function(playerID, container, unit, target)
			if unit and unit:IsAlive() and unit:IsTrueHero() then
				container:Open(playerID)
				unit:Stop()
			end
		end,
	})
end

function ContainersHelper:CreateShopTable(ii)
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

	return sItems, prices, stocks
end

function ContainersHelper:CreateItemGrid(numberOfItems)
	local itemgrid = {}
	local gridSize = math.ceil(math.sqrt(numberOfItems))
	for i = 1, gridSize do
		if gridSize * #itemgrid < numberOfItems then
			table.insert(itemgrid, gridSize)
		end
	end

	return itemgrid
end