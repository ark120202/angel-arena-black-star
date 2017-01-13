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
	--[[for _,v in ipairs(Entities:FindAllByName("target_mark_crafting_station")) do
		local craftingEnt = CreateItemOnPositionSync(v:GetAbsOrigin(), nil)
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
	end]]
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

function ContainersHelper:CreateLootBox(position, items)
	for i,v in ipairs(items) do
		local item = CreateItem(v, nil, nil)
		CreateItemOnPositionSync(position, item)
		item.CanOverrideOwner = true
		item:LaunchLoot(false, 300, 0.6, position + RotatePosition(Vector(0,0,0),QAngle(0,i*(360/#items),0),Vector(80,80)))
	end

	--[[
	local cont = Containers:CreateContainer({
		layoutFile = "file://{resources}/layout/custom_game/containers/alt_container_with_timer.xml",
		RemainingDuration = 60,
		layout =      ContainersHelper:CreateItemGrid(#items),
		headerText =  "containers_loot_boxes_box_name",
		buttons =     {"#containers_loot_boxes_take_all"},
		position =    "75% 60%",
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
					if unit:HasRoomForItem(item:GetName(), false, false) ~= 4 then
						container:RemoveItem(item)
						Containers:AddItemToUnit(unit,item)
					end
				end

				container:Close(playerID)
			end
		end,
		OnLeftClick = function(playerID, container, unit, item, slot)
			local forceActivatable = SHARED_CONTAINERS_USABLE_ITEMS[item:GetAbilityName()]
				
			if forceActivatable then -- or (not item:IsPassive() and item:GetShareability() == ITEM_FULLY_SHAREABLE and forceActivatable ~= false)) then
				item:SetOwner(unit)
				container:ActivateItem(unit, item, playerID)
			end
		end
	})
	return cont
	]]
end