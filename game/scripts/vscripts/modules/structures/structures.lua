Structures = Structures or class({})

ModuleRequire(..., "data")
ModuleRequire(..., "shops")
ModuleLinkLuaModifier(..., "modifier_arena_healer")
ModuleLinkLuaModifier(..., "modifier_arena_courier")
ModuleLinkLuaModifier(..., "modifier_fountain_aura_arena")
ModuleLinkLuaModifier(..., "modifier_fountain_aura_invulnerability", "modifier_fountain_aura_arena")
ModuleLinkLuaModifier(..., "modifier_fountain_aura_enemy")

Events:Register("activate", function ()
	local gameMode = GameRules:GetGameModeEntity()
	gameMode:SetFountainConstantManaRegen(0)
	gameMode:SetFountainPercentageHealthRegen(0)
	gameMode:SetFountainPercentageManaRegen(0)
	Structures:AddHealers()
	Structures:CreateShops()
end)

Events:Register("bosses/kill/cursed_zeld", function ()
	Notifications:TopToAll({ text="#structures_fountain_protection_weak_line1", duration = 7 })
	Notifications:TopToAll({ text="#structures_fountain_protection_weak_line2", duration = 7 })
end)

Events:Register("bosses/respawn/cursed_zeld", function ()
	Notifications:TopToAll({ text="#structures_fountain_protection_strong_line1", duration = 7 })
	Notifications:TopToAll({ text="#structures_fountain_protection_strong_line2", duration = 7 })
end)

function Structures:AddHealers()
	for _,v in ipairs(Entities:FindAllByClassname("npc_dota_healer")) do
		local model = TEAM_HEALER_MODELS[v:GetTeamNumber()]
		v:SetOriginalModel(model.mdl)
		v:SetModel(model.mdl)
		if model.color then v:SetRenderColor(unpack(model.color)) end
		v:RemoveModifierByName("modifier_invulnerable")
		v:AddNewModifier(v, nil, "modifier_arena_healer", nil)
		v:FindAbilityByName("healer_taste_of_armor"):SetLevel(1)
		v:FindAbilityByName("healer_bottle_refill"):SetLevel(1)
	end
end

function Structures:GiveCourier(hero)
	local playerId = hero:GetPlayerID()
	local tn = hero:GetTeamNumber()
	local cour_item = hero:AddItem(CreateItem("item_courier", hero, hero))
	TEAMS_COURIERS[hero:GetTeamNumber()] = true
	Timers:CreateTimer(0.03, function()
		for _,courier in ipairs(Entities:FindAllByClassname("npc_dota_courier")) do
			local owner = courier:GetOwner()
			if IsValidEntity(owner) and owner:GetPlayerID() == playerId then
				courier:SetOwner(nil)
				courier:UpgradeToFlyingCourier()

				courier:AddNewModifier(courier, nil, "modifier_arena_courier", nil)

				TEAMS_COURIERS[tn] = courier
			end
		end
	end)
end
