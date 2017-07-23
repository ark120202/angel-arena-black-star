--[[ ============================================================================================================
	Author: Rook
	Date: January 29, 2015
	Called when Bloodstone is cast.  Denies the unit.
================================================================================================================= ]]
function item_bloodstone_arena_on_spell_start(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster.PocketItem then
		caster.BloodstoneDeny = true
		caster:SetHealth(1)
		ApplyDamage({victim = caster, attacker = caster, damage = 99999, damage_type = DAMAGE_TYPE_PURE, ability = ability, damage_flags = DOTA_DAMAGE_FLAG_IGNORES_MAGIC_ARMOR + DOTA_DAMAGE_FLAG_IGNORES_PHYSICAL_ARMOR + DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_BYPASSES_BLOCK + DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NO_DIRECTOR_EVENT + DOTA_DAMAGE_FLAG_USE_COMBAT_PROFICIENCY + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS})
		if caster:IsAlive() then
			caster:TrueKill(ability, caster)
		end
	else
		ability:RefundManaCost()
		ability:EndCooldown()
	end
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 29, 2015
	Called when a hero affected by Bloodstone's hidden aura (i.e. a hero within range of an enemy with a Bloodstone) dies.
	Increases the charges on the item.
================================================================================================================= ]]
function modifier_item_bloodstone_arena_aura_on_death(keys)
	local ability = keys.ability
	local caster = keys.caster
	if caster:IsIllusion() then
		caster = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerID())
	end

	local bloodstone_in_highest_slot = nil
	for i = 0, 5 do
		local current_item = caster:GetItemInSlot(i)
		if current_item and current_item:GetAbilityName() == ability:GetAbilityName() then
			bloodstone_in_highest_slot = current_item
		end
	end

	if bloodstone_in_highest_slot then
		bloodstone_in_highest_slot:SetCurrentCharges(bloodstone_in_highest_slot:GetCurrentCharges() + 1)
	end
	item_bloodstone_arena_recalculate_charge_bonuses(keys)
end


--[[ ============================================================================================================
	Author: Rook
	Date: January 26, 2015
	Called when a hero is killed by the player.  Increases the charges on the Bloodstone if the killed hero was not within range.
================================================================================================================= ]]
function modifier_item_bloodstone_arena_aura_emitter_on_hero_kill(keys)
	local unit = keys.unit
	if unit and unit:IsRealHero() and unit:GetTeam() ~= keys.attacker:GetTeam() and not unit:HasModifier("modifier_item_bloodstone_arena_aura") then
		modifier_item_bloodstone_arena_aura_on_death(keys)
	end
end

function item_bloodstone_arena_recalculate_charge_bonuses(keys)
	local caster = keys.caster
	local ability = keys.ability
	local total_charge_count = 0
	for i = 0, 5 do
		local current_item = caster:GetItemInSlot(i)
		if current_item and current_item:GetAbilityName() == "item_bloodstone_arena" then
			total_charge_count = total_charge_count + current_item:GetCurrentCharges()
		end
	end

	local modifier = caster:FindModifierByName("modifier_item_bloodstone_arena_charge")
	if total_charge_count > 0 then
		if not modifier then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_bloodstone_arena_charge", {})
			Timers:CreateTimer(function()
				if IsValidEntity(caster) then
					modifier = caster:FindModifierByName("modifier_item_bloodstone_arena_charge")
					if modifier then
						modifier:SetStackCount(total_charge_count)
					end
					if caster.CalculateStatBonus then
						caster:CalculateStatBonus()
					end
				end
			end)
		else
			modifier:SetStackCount(total_charge_count)
		end
	elseif modifier then
		modifier:Destroy()
	end
	if caster.CalculateStatBonus then
		caster:CalculateStatBonus()
	end
end

function modifier_item_bloodstone_arena_aura_emitter_on_death(keys)
	local caster = keys.caster
	if caster:IsRealHero() then
		local total_charge_count = 0
		for i = 0, 5 do
			local current_item = caster:GetItemInSlot(i)
			if current_item and current_item:GetAbilityName() == "item_bloodstone_arena" then
				local current_charges = current_item:GetCurrentCharges()
				total_charge_count = total_charge_count + current_charges

				--Reduce the number of charges left on this Bloodstone.
				local charges_left = math.floor(current_charges * keys.OnDeathChargePercent * 0.01)
				current_item:SetCurrentCharges(math.max(charges_left, 0))
			end
		end

		local nearby_allied_units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, keys.HealOnDeathRange,
			DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		for i, nearby_ally in ipairs(nearby_allied_units) do
			SafeHeal(nearby_ally, keys.HealOnDeathBase + (keys.HealOnDeathPerCharge * total_charge_count), caster)
			ParticleManager:CreateParticle("particles/items_fx/bloodstone_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, nearby_ally)
		end

		local bloodstone_glyph = ParticleManager:CreateParticle("particles/items_fx/bloodstone_glyph.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(bloodstone_glyph, 1, Vector(new_time_until_respawn))

		local modelDummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, nil, nil, caster:GetTeamNumber())
		modelDummy:SetModel("models/props_items/bloodstone.vmdl")
		modelDummy:SetHullRadius(32)
		modelDummy:SetDayTimeVisionRange(caster:GetDayTimeVisionRange())
		modelDummy:SetNightTimeVisionRange(caster:GetNightTimeVisionRange())
		caster.BloodstoneDummies = modelDummy

		caster.RespawnTimeModifierBloodstone = -(total_charge_count * keys.RespawnTimeReductionPerCharge)
		item_bloodstone_arena_recalculate_charge_bonuses(keys)
	end
end
