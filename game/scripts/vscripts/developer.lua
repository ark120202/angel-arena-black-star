if not IsInToolsMode() then return end

function Print(unit)
	for i = 0, unit:GetAbilityCount() - 1 do
		local a = unit:GetAbilityByIndex(i)
			print(i,a)
		if a then
		end
	end
end

function MOROZHENKA()
	_G.UNET = CreateHeroForPlayer("npc_dota_hero_chen", PlayerResource:GetPlayer(0))
	UNET:SetOwner(PlayerResource:GetPlayer(0))
	UNET:SetControllableByPlayer(0, false)
	CustomWearables:EquipCustomModelToSlot(UNET, "mount", "models/heroes/beastmaster/beastmaster_beast.vmdl")
end
--[[local asd = {}
for ho,t in pairs(RANDOM_OMG_SETTINGS.Abilities) do
	for _,v in ipairs(t) do
		if not asd[v.hero] then
			asd[v.hero] = {}
		end
		local p = 1
		if ho == "Ultimates" then
			p = 8
		end
		asd[v.hero][v.ability] = p
	end
end
for h,abs in pairs(asd) do
	print("[\"" .. h .. "\"] = {")
		for abil,points in pairs(abs) do
			print("[\"" .. abil .. "\"] = { point_cost = " .. points .. ", banned_combintaions = {}},")
		end
	print("},")
end]]
--[[unit = CreateUnitByName("npc_dota_creature",Vector(0,0,0),true,nil,nil,2)
unit:SetModel("models/items/courier/catakeet/catakeet.vmdl")
unit:SetOriginalModel("models/items/courier/catakeet/catakeet.vmdl")
unit:SetMaterialGroup(2)]]
--MOROZHENKA()

--[[for k,v in pairs(LoadKeyValues("scripts/npc/npc_items_custom.txt")) do
	if not string.starts(k, "item_recipe_") then
		print(k)
	end
end]]

--[[local override = LoadKeyValues("scripts/npc/".."npc_abilities_override.txt")
for abilityName,abilityData in pairs(KeyValues.AbilityKV) do
	if abilityData and type(abilityData) == "table" and abilityData.MaxLevel and abilityData["AbilitySpecial"] and override[abilityName] and not string.starts(abilityName, "invoker_") then
		for _,specialData in pairs(abilityData["AbilitySpecial"]) do
			for k,v in pairs(specialData) do
				if k ~= "var_type" then
					local s = string.split(v)
					if #s ~= abilityData.MaxLevel and #s ~= 1 then
						print(abilityName .. " -- " .. k .. " -- " .. #s)
					end
				end
			end
			
		end
	end
end]]

--[[for k,v in pairs(_G) do
	if (string.starts(k, "DOTA_UNIT_ORDER_")) then
		print(k,v)
	end
end]]

--GameRules:SetGameWinner(2)
if true or not PlayerResource then return end
local h = PlayerResource:GetSelectedHeroEntity(0)
if false then
	CustomWearables:EquipWearable(h, {
		hero = "npc_dota_hero_crystal_maiden",
		models = {
			{
				model = "models/items/alchemist/prison_ballchain.vmdl",
				attachPoint = "attach_attack1",
				scale = 1
			},
			{
				model = "models/items/alchemist/caustic_hair/caustic_hair.vmdl",
				attachPoint = "attach_head",
				scale = 1.1,
				callback = function(a)
					a:SetRenderColor(100, 100, 200)
				end
			},
			{
				model = "models/items/magnataur/defender_horn/defender_horn.vmdl",
				attachPoint = "attach_head",
				scale = 0.8,
				callback = function(a)
					a:SetRenderColor(255, 92, 217)
				end
			},
		},
		hidden_slots = { "head", "weapon", "back" }
	})
end
if false then
	CustomWearables:EquipWearable(h, {
		hero = "npc_dota_hero_lina",
		models = {
			{
				model = "models/items/alchemist/caustic_hair/caustic_hair.vmdl",
				attachPoint = "attach_head",
				scale = 1.2,
				callback = function(a)
					a:SetRenderColor(255,100,100)
				end
			},
		},
		hidden_slots = { "head" }
	})
end