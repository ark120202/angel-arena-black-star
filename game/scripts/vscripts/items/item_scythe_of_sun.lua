item_scythe_of_sun = class({})

LinkLuaModifier("modifier_item_scythe_of_sun", "items/item_scythe_of_sun.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_scythe_of_sun_hex", "items/item_scythe_of_sun.lua", LUA_MODIFIER_MOTION_NONE)

function item_scythe_of_sun:GetIntrinsicModifierName()
	return "modifier_item_scythe_of_sun"
end

if IsServer() then
	function item_scythe_of_sun:OnSpellStart()
		local target = self:GetCursorTarget()
		if not target:TriggerSpellAbsorb(self) then
			ParticleManager:CreateParticle("particles/arena/items_fx/scythe_of_sun.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			target:EmitSound("DOTA_Item.Sheepstick.Activate")
			local caster = self:GetCaster()
			if target:IsIllusion() then
				target:Kill(self, caster)
			else
				target:TriggerSpellReflect(self)
				target:AddNewModifier(caster, self, "modifier_item_scythe_of_sun_hex", {duration = self:GetSpecialValueFor("hex_duration")})
				ApplyDamage({
					attacker = caster,
					victim = target,
					damage = self:GetAbilityDamage(),
					damage_type = self:GetAbilityDamageType(),
					ability = self
				})
			end
		end
	end
end


modifier_item_scythe_of_sun = class({
	IsHidden      = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable    = function() return false end,
})

function modifier_item_scythe_of_sun:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
end

function modifier_item_scythe_of_sun:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_item_scythe_of_sun:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_agility")
end

function modifier_item_scythe_of_sun:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_scythe_of_sun:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_scythe_of_sun:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_scythe_of_sun:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_health_regen")
end

function modifier_item_scythe_of_sun:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_scythe_of_sun:GetModifierEvasion_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_evasion")
end

function modifier_item_scythe_of_sun:GetModifierCastRangeBonus()
	return self:GetAbility():GetSpecialValueFor("cast_range_bonus")
end

function modifier_item_scythe_of_sun:GetModifierSpellAmplify_Percentage()
	return self:GetAbility():GetSpecialValueFor("spell_amp_pct")
end


modifier_item_scythe_of_sun_hex = class({
	IsDebuff      = function() return true end,
	IsPurgable    = function() return false end,
})

function modifier_item_scythe_of_sun_hex:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
		[MODIFIER_STATE_BLOCK_DISABLED] = true,
		[MODIFIER_STATE_EVADE_DISABLED] = true,
		[MODIFIER_STATE_HEXED] = true,
	}
end

function modifier_item_scythe_of_sun_hex:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}
end

function modifier_item_scythe_of_sun_hex:GetModifierModelChange()
	return "models/items/hex/sheep_hex/sheep_hex_gold.vmdl"
end

function modifier_item_scythe_of_sun_hex:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("hex_movement_speed")
end
