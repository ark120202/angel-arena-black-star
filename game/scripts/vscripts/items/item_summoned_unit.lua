function DoSummon(keys)
	local caster = keys.caster
	local ability = keys.ability
	local max_units = keys.max_units
	if not caster:IsRealHero() then
		ability:EndCooldown()
		ability:RefundManaCost()
		return
	end
	local unit
	if caster.custom_summoned_unit_ability_item_summoned_unit then
		unit = caster.custom_summoned_unit_ability_item_summoned_unit
		unit:RespawnUnit()
		unit:SetMana(unit:GetMaxMana())
		FindClearSpaceForUnit(unit, caster:GetAbsOrigin(), true)
	else
		unit = CreateUnitByName("npc_arena_item_summoned_unit", caster:GetAbsOrigin(), true, caster, nil, caster:GetTeamNumber())
		caster.custom_summoned_unit_ability_item_summoned_unit = unit
		unit:SetControllableByPlayer(caster:GetPlayerID(), true)
		unit:SetOwner(caster)
		for i = 1, 6 - keys.item_slots do
			unit:AddItem(CreateItem("item_slot_locked", unit, unit))
		end
	end
	if caster.CustomWearables and caster.CustomWearables.PlayerKeys and caster.CustomWearables.PlayerKeys.item_summoned_unit then
		local t = caster.CustomWearables.PlayerKeys.item_summoned_unit
		if t.model then
			unit:SetModel(t.model)
			unit:SetOriginalModel(t.model)
		end
		if t.model_scale then
			unit:SetModelScale(t.model_scale)
		end
	end
	unit:SetBaseMaxHealth(keys.health)
	unit:SetMaxHealth(keys.health)
	unit:SetHealth(keys.health)
	unit:SetBaseHealthRegen(keys.health_regen)
	unit:SetBaseDamageMin(keys.damage)
	unit:SetBaseDamageMax(keys.damage)
	unit:SetPhysicalArmorBaseValue(keys.armor)
	ParticleManager:CreateParticle("particles/units/heroes/hero_lone_druid/lone_druid_bear_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
end

function ReturnBack(keys)
	local caster = keys.caster
	caster:EmitSound("LoneDruid_SpiritBear.ReturnStart")
	FindClearSpaceForUnit(caster, caster:GetOwner():GetAbsOrigin(), true)
	caster:EmitSound("LoneDruid_SpiritBear.Return")
end

function ReturnDamage(keys)
	local attacker = keys.attacker
	if attacker then
		local attacker_name = attacker:GetUnitName()
		if keys.Damage > 0 and ((attacker.IsControllableByAnyPlayer and attacker:IsControllableByAnyPlayer()) or attacker:IsBoss()) then
			if keys.ability:GetCooldownTimeRemaining() < keys.cooldown then
				keys.ability:StartCooldown(keys.cooldown)
			end
		end
	end
end

function KillSummon(keys)
	local caster = keys.caster
	local ability = keys.ability
	local unit = caster.custom_summoned_unit_ability_item_summoned_unit
	if not IsValidEntity(unit) or not unit:IsAlive() then return end
	unit:ForceKill(false)
end
