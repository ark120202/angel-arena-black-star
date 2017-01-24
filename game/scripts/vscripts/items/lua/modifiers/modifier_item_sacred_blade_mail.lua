modifier_item_blade_mail_arena = class({})

function modifier_item_blade_mail_arena:IsHidden()
	return true
end

function modifier_item_blade_mail_arena:DeclareFunctions()
	return { 
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_item_blade_mail_arena:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_blade_mail_arena:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_blade_mail_arena:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_blade_mail_arena:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_strength")
end

function modifier_item_blade_mail_arena:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_magical_armor")
end

function modifier_item_blade_mail_arena:GetModifierHealthRegenPercentage()
	return self:GetAbility():GetSpecialValueFor("bonus_hp_regen_pct")
end


if IsServer() then
	function modifier_item_blade_mail_arena_active:OnTakeDamage(keys)
		local unit = self:GetParent()
		local ability = self:GetAbility()
		if unit == keys.unit and IsValidEntity(ability) and IsValidEntity(keys.inflictor) and ability:GetSpecialValueFor("buff_chance") and PreformAbilityPrecastActions(unit, ability) then
			unit:AddNewModifier(unit, ability, "modifier_item_blade_mail_arena_buff", {duration = ability:GetSpecialValueFor("buff_duration")})
		end
	end
end


modifier_item_blade_mail_arena_active = class({})
function modifier_item_blade_mail_arena_active:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end
function modifier_item_blade_mail_arena_active:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_item_blade_mail_arena_active:GetStatusEffectName()
	return "particles/status_fx/status_effect_blademail.vpcf"
end
function modifier_item_blade_mail_arena_active:StatusEffectPriority()
	return 10
end
if IsServer() then
	function modifier_item_blade_mail_arena_active:DeclareFunctions()
		return { MODIFIER_EVENT_ON_TAKEDAMAGE }
	end

	function modifier_item_blade_mail_arena_active:OnTakeDamage(keys)
		local unit = self:GetParent()
		local inflictor = keys.inflictor
		if unit == keys.unit and unit:IsAlive() and (not IsValidEntity(inflictor) or not NOT_DAMAGE_REFRLECTABLE_ABILITIES[inflictor:GetAbilityName()]) then
			local ability = self:GetAbility()
			keys.attacker:EmitSound("DOTA_Item.BladeMail.Damage")
			ApplyDamage({
				victim = keys.attacker,
				attacker = self:GetCaster(),
				damage = keys.original_damage * ability:GetSpecialValueFor("reflected_damage_pct") * 0.01,
				damage_type = keys.damage_type,
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				ability = ability
			})
		end
	end
end


modifier_item_blade_mail_arena_buff = class({})
function modifier_item_blade_mail_arena_buff:CheckState()
	return {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true
	}
end
if IsServer() then
	function modifier_item_blade_mail_arena_buff:OnCreated()
		local parent = self:GetParent()
		parent:EmitSound("DOTA_Item.BlackKingBar.Activate")
		local pfx = ParticleManager:CreateParticle("particles/arena/items_fx/holy_knight_shield_avatar.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(pfx, 0, parent, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
		self:AddParticle(pfx, false, false, -1, true, false)
	end
end