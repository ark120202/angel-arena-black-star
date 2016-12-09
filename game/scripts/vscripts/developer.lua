if not IsInToolsMode() then return end

function Print(unit)
	for i = 0, unit:GetAbilityCount() - 1 do
		local a = unit:GetAbilityByIndex(i)
			print(i,a)
		if a then
		end
	end
end

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