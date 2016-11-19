if ContainersHelper == nil then
	ContainersHelper = class({})
	ContainersHelper._OpenedContainers = {}
end

function ContainersHelper:CreateShops()
	for _,v in ipairs(Entities:FindAllByName("containers_shop_secret")) do
		v:AddNewModifier(v, nil, "modifier_shopkeeper", {})
		ContainersHelper:CreateShop(v, ShopsData.Shards, "#containers_shop_secret_name", 300)
	end
	_G.craftingEnt = Entities:FindByName(nil, "target_mark_crafting_station")
	craftingEnt = CreateItemOnPositionSync(craftingEnt:GetAbsOrigin(), nil)
	craftingEnt:SetModel("models/props_structures/bad_base_shop002.vmdl")
	craftingEnt:SetForwardVector(Vector(-1, 0, 0))
	crafting = Containers:CreateContainer({
		layout =      {3,3,3},
		skins =       {},
		headerText =  "Crafting Station",
		pids =        {},
		position =    "entity",
		entity =      craftingEnt,
		closeOnOrder= true,
		range =       200,
		buttons =     {"Craft"},
		OnEntityOrder=function(playerID, container, unit, target)
			if unit and unit:IsAlive() and unit:IsRealHero() and not unit:HasModifier("modifier_arc_warden_tempest_double") then
				container:Open(playerID)
				unit:Stop()
			end
		end,
		OnButtonPressed = function(playerID, container, unit, button, buttonName)
			if button == 1 then
				for _, recipe in ipairs(CRAFT_RECIPES) do
					local isMatch = true
					if not recipe.condition or recipe.condition(playerID, unit, container) then
						if not recipe.IsShapeless then
							for row, rowData in ipairs(recipe.recipe) do
								for col, recipeItem in ipairs(rowData) do
									local itemInSlot = container:GetItemInRowColumn(row, col)
									if not (itemInSlot and recipeItem == itemInSlot:GetName()) and not (recipeItem == "" and itemInSlot == nil) then
										isMatch = false
										break
									end
								end
							end
						else
							local allRecipeItems = {}
							local itemcount = 0
							for _, rowData in ipairs(recipe.recipe) do
								for _, recipeItem in ipairs(rowData) do
									if recipeItem ~= "" then
										allRecipeItems[recipeItem] = (allRecipeItems[recipeItem] or 0) + 1
										itemcount = itemcount + 1
									end
								end
							end
							print(#container:GetAllItems(), itemcount)
							if #container:GetAllItems() == itemcount then
								for itemName,count in pairs(allRecipeItems) do
									local itemsByName = container:GetItemsByName(itemName)
									if #itemsByName ~= count then
										isMatch = false
										break
									end
								end
							else
								isMatch = false
							end
						end
					else
						isMatch = false
					end
					if isMatch then
						for _,item in ipairs(container:GetAllItems()) do
							container:RemoveItem(item)
						end
						local t = recipe.results
						if type(recipe.results) ~= "table" then
							t = {recipe.results}
						end
						local slots = {
							[1] = { {2, 2}, },
							[2] = { {2, 1}, {2, 3}, },
							[3] = { {2, 1}, {2, 2}, {2, 3}, },
							[4] = { {2, 1}, {2, 2}, {2, 3}, {1, 2}, },
							[5] = { {2, 1}, {2, 2}, {2, 3}, {1, 2}, {3, 2}, },
							[6] = { {1, 1}, {1, 2}, {1, 3}, {3, 1}, {3, 2}, {3, 3}, },
							[7] = { {1, 1}, {1, 2}, {1, 3}, {3, 1}, {3, 2}, {3, 3}, {2, 2}, },
							[8] = { {1, 1}, {1, 2}, {1, 3}, {2, 1}, {2, 3}, {3, 1}, {3, 2}, {3, 3}, },
							[9] = { {1, 1}, {1, 2}, {1, 3}, {2, 1}, {2, 2}, {2, 3}, {3, 1}, {3, 2}, {3, 3}, },
						}
						for i,v in ipairs(t) do
							local pos = slots[#t][i]
							container:AddItem(CreateItem(v,unit,unit), pos[1], pos[2])
						end
					end
				end
			end
		end,
	})
end
--ContainersHelper:CreateShops()
function ContainersHelper:CreateShop(baseUnit, itemTable, shopName, radius)
	local sItems,prices,stocks = ContainersHelper:CreateShopTable(itemTable)

	itemShop = Containers:CreateShop({
		layout =      ContainersHelper:CreateItemGrid(#itemTable),
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
			if unit and unit:IsAlive() and unit:IsRealHero() and not unit:HasModifier("modifier_arc_warden_tempest_double") then
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

function ContainersHelper:CreateLootBox(entity, items)
	local cont = Containers:CreateContainer({
		layout =      ContainersHelper:CreateItemGrid(#items),
		headerText =  "containers_loot_boxes_box_name",
		buttons =     {"#containers_loot_boxes_take_all"},
		position =    "entity",
		OnClose = function(playerID, container)
			if next(container:GetAllOpen()) == nil and #container:GetAllItems() == 0 then
				container:GetEntity():RemoveSelf()
				container:Delete()
			end
		end,
		closeOnOrder= true,
		items = items,
		entity = entity,
		range = 150,
		OnEntityOrder = function(playerID, container, unit, target)
			if unit and unit:IsAlive() and unit:IsRealHero() and not unit:HasModifier("modifier_arc_warden_tempest_double") then
				container:Open(playerID)
				unit:Stop()
			end
		end,
		OnButtonPressed = function(playerID, container, unit, button, buttonName)
			if button == 1 then
				local items = container:GetAllItems()
				for _,item in ipairs(items) do
					if unit:HasRoomForItem(item:GetName(), false, false) then
						container:RemoveItem(item)
						Containers:AddItemToUnit(unit,item)
					end
				end

				container:Close(playerID)
			end
		end
	})
	return cont
end
--[[function ContainersHelper:CreateMiddleLootBox(loc, lootboxTable)
	local tempTable = {}
	local min = math.floor(GetDOTATimeInMinutesFull() / 10) + 1
	local boxindex = math.min(min, 10)
	table.merge(tempTable, lootboxTable[boxindex].Items)
	local phys = CreateItemOnPositionSync(loc:GetAbsOrigin(), nil)
	phys:SetForwardVector(Vector(0,-1,0))
	phys:SetModelScale(1.5)

	local items = {}
	local slots = {1,2,3,4}
	for i=1,RandomInt(1,3) do
		items[table.remove(slots, RandomInt(1,#slots))] = CreateItem(table.remove(tempTable, RandomInt(1, #tempTable)), nil, nil)
	end
	local cont = Containers:CreateContainer({
		layout =      ContainersHelper:CreateItemGrid(#items),
		headerText =  "Loot Box",
		buttons =     {"Take All"},
		position =    "entity", --"mouse",--"900px 200px 0px",
		OnClose = function(playerID, container)
			if next(container:GetAllOpen()) == nil and #container:GetAllItems() == 0 then
				container:GetEntity():RemoveSelf()
				container:Delete()
				loc.container = nil

				Timers:CreateTimer(lootboxTable[boxindex].Delay, function()
					ContainersHelper:CreateMiddleLootBox(loc, lootboxTable)
				end)
			end
		end,
		closeOnOrder= true,
		items = items,
		entity = phys,
		range = 128,
		OnButtonPressed = function(playerID, container, unit, button, buttonName)
			if button == 1 then
				local items = container:GetAllItems()
				for _,item in ipairs(items) do
					container:RemoveItem(item)
					Containers:AddItemToUnit(unit,item)
				end

				container:Close(playerID)
			end
		end,
		OnEntityOrder = function(playerID, container, unit, target)
			container:Open(playerID)
			unit:Stop()
		end
	})
	loc.container = cont
	loc.phys = phys
end]]