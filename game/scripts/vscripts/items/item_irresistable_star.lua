LinkLuaModifier("modifier_item_irresistable_star", "items/item_irresistable_star.lua", LUA_MODIFIER_MOTION_NONE)

item_irresistable_star = class ({
	GetIntrinsicModifierName = function() return "modifier_item_irresistable_star" end
})

modifier_item_irresistable_star = class({
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
})

function modifier_item_irresistable_star:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
	}
end

function modifier_item_irresistable_star:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_irresistable_star:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_amp_pct")
end

function modifier_item_irresistable_star:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_irresistable_star:GetModifierCastRangeBonus()
	return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
end

function modifier_item_irresistable_star:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_irresistable_star:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

if IsServer() then
	function modifier_item_irresistable_star:OnTakeDamage(keys)
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local damage = keys.original_damage
		local caster = ability:GetCaster()
		local target = keys.unit
		if caster:HasModifier("modifier_item_unstable_quasar_passive") or caster:HasModifier("modifier_item_scythe_of_the_ancients_passive") then return end
		Timers:CreateTimer(2, function()
			if keys.attacker == parent and not target:IsMagicImmune() and keys.damage_type == 2 and damage > ability:GetSpecialValueFor("min_damage") then
				self.particle = ParticleManager:CreateParticle("particles/arena/items_fx/irresistable_star_start.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
				ParticleManager:SetParticleControlEnt(self.particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
				ApplyDamage({
					attacker = parent,
					victim = target,
					damage = damage * ability:GetSpecialValueFor("magic_damage_to_pure_pct") * 0.01,
					damage_type = DAMAGE_TYPE_PURE,
					damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
					ability = ability
				})
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, damage * ability:GetSpecialValueFor("magic_damage_to_pure_pct") * 0.01, nil)
			end
		end)
	end
end
