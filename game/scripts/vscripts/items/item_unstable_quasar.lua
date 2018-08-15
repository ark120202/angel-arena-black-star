LinkLuaModifier("modifier_item_unstable_quasar_passive", "items/item_unstable_quasar.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_unstable_quasar_slow", "items/item_unstable_quasar.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_unstable_quasar_aura", "items/item_unstable_quasar.lua", LUA_MODIFIER_MOTION_NONE)

item_unstable_quasar = class({
	GetIntrinsicModifierName = function() return "modifier_item_unstable_quasar_passive" end,
})

function item_unstable_quasar:GetManaCost()
	local caster = self:GetCaster()
	if not caster then return end

	local percentage = caster:GetMaxMana() * self:GetSpecialValueFor("manacost_pct") * 0.01
	return self:GetSpecialValueFor("manacost") + percentage
end


modifier_item_unstable_quasar_passive = class({
	IsHidden   = function() return true end,
	IsPurgable = function() return false end,
	RemoveOnDeath = function() return false end,
})

function modifier_item_unstable_quasar_passive:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
	}
end

if IsServer() then
	function modifier_item_unstable_quasar_passive:OnAbilityExecuted(keys)
		local caster = self:GetParent()
		if caster ~= keys.unit then return end
		local ability = self:GetAbility()
		local usedAbility = keys.ability
		local team = caster:GetTeam()
		local pos = caster:GetAbsOrigin()
		local radius = ability:GetSpecialValueFor("singularity_radius")

		if (
			usedAbility:GetCooldown(usedAbility:GetLevel()) >= ability:GetSpecialValueFor("min_ability_cooldown") and
			usedAbility:GetManaCost(usedAbility:GetLevel()) ~= 0 and
			ability:PerformPrecastActions()
		) then
			for _,v in ipairs(FindUnitsInRadius(team, pos, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
				local enemyPos = v:GetAbsOrigin()
				local damage = v:GetHealth() * ability:GetSpecialValueFor(caster:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT and "intelligence_damage_pct" or "damage_pct") * 0.01 + ability:GetSpecialValueFor("base_damage")

				ApplyDamage({
					attacker = caster,
					victim = v,
					damage = damage,
					damage_type = ability:GetAbilityDamageType(),
					damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
					ability = self:GetAbility()
				})

				local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(
					particle,
					0,
					caster,
					PATTACH_POINT_FOLLOW,
					"attach_attack1",
					caster:GetAbsOrigin(),
					true
				)
				ParticleManager:SetParticleControl(particle, 1, enemyPos)

				v:AddNewModifier(caster, ability, "modifier_item_unstable_quasar_slow", {duration = ability:GetSpecialValueFor("slow_duration")})

				local direction = (pos - enemyPos):Normalized()
				local distance = ability:GetSpecialValueFor("offset_range")

				FindClearSpaceForUnit(v, GetGroundPosition(enemyPos + direction * distance, caster), true)
			end
		end
	end

	function modifier_item_unstable_quasar_passive:OnTakeDamage(keys)
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local damage = keys.original_damage
		local caster = ability:GetCaster()
		if caster:HasModifier("modifier_item_scythe_of_the_ancients_passive") then return end
		Timers:CreateTimer(2, function()
		if keys.attacker == parent and not keys.unit:IsMagicImmune() and keys.damage_type == 2 and damage > ability:GetSpecialValueFor("min_damage_to_pure") then
			ApplyDamage({
				attacker = parent,
				victim = keys.unit,
				damage = damage * ability:GetSpecialValueFor("magic_damage_to_pure_pct") * 0.01,
				damage_type = DAMAGE_TYPE_PURE,
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				ability = ability
			})
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, keys.unit, damage * ability:GetSpecialValueFor("magic_damage_to_pure_pct") * 0.01, nil)
			end
		end)
	end
end

function modifier_item_unstable_quasar_passive:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor("bonus_day_vision")
end

function modifier_item_unstable_quasar_passive:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("bonus_night_vision")
end

function modifier_item_unstable_quasar_passive:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_unstable_quasar_passive:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_amp_pct")
end

function modifier_item_unstable_quasar_passive:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_unstable_quasar_passive:GetModifierCastRangeBonus()
	return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
end

function modifier_item_unstable_quasar_passive:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_unstable_quasar_passive:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end


function modifier_item_unstable_quasar_passive:GetModifierAura()
	return "modifier_item_unstable_quasar_aura"
end

function modifier_item_unstable_quasar_passive:IsAura()
	return true
end

function modifier_item_unstable_quasar_passive:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_item_unstable_quasar_passive:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end

function modifier_item_unstable_quasar_passive:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end


modifier_item_unstable_quasar_slow = class({
	IsHidden   = function() return false end,
	IsPurgable = function() return true end,
	IsDebuff = function() return true end,
	GetEffectName = function() return "particles/items_fx/diffusal_slow.vpcf" end,
})

function modifier_item_unstable_quasar_slow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
	}
end

function modifier_item_unstable_quasar_slow:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("slow_speed")
end

function modifier_item_unstable_quasar_slow:GetModifierMoveSpeed_Max()
	return self:GetAbility():GetSpecialValueFor("slow_speed")
end

function modifier_item_unstable_quasar_slow:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor("slow_speed")
end


modifier_item_unstable_quasar_aura = class({
	DeclareFunctions = function() return { MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS } end,
	GetPriority = function() return { MODIFIER_PRIORITY_HIGH } end,
})

function modifier_item_unstable_quasar_aura:GetModifierMagicalResistanceBonus()
	return -self:GetAbility():GetSpecialValueFor("aura_resist_debuff_pct")
end

function modifier_item_unstable_quasar_aura:CheckState()
	return {
		[MODIFIER_STATE_INVISIBLE] = false,
	}
end
