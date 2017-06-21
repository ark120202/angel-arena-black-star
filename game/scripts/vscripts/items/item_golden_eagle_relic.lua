LinkLuaModifier("modifier_item_golden_eagle_relic", "items/item_golden_eagle_relic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_golden_eagle_relic_enabled", "items/item_golden_eagle_relic.lua", LUA_MODIFIER_MOTION_NONE)

item_golden_eagle_relic = class({
	GetIntrinsicModifierName = function() return "modifier_item_golden_eagle_relic" end,
})

if IsServer() then
	function item_golden_eagle_relic:OnSpellStart()
		local caster = self:GetCaster()
		if caster:HasModifier("modifier_item_golden_eagle_relic_enabled") then
			caster:RemoveModifierByName("modifier_item_golden_eagle_relic_enabled")
			caster:EmitSound("DOTA_Item.Armlet.DeActivate")
		else
			caster:AddNewModifier(caster, self, "modifier_item_golden_eagle_relic_enabled", nil)
			caster:EmitSound("DOTA_Item.MaskOfMadness.Activate")
		end
	end
end


modifier_item_golden_eagle_relic = class({
	IsHidden      = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable    = function() return false end,
})

function modifier_item_golden_eagle_relic:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end
function modifier_item_golden_eagle_relic:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_attackspeed")
end
function modifier_item_golden_eagle_relic:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end


modifier_item_golden_eagle_relic_enabled = class({
	GetEffectName =       function() return "particles/arena/items_fx/golden_eagle_relic_buff.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
})

function modifier_item_golden_eagle_relic_enabled:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end
function modifier_item_golden_eagle_relic_enabled:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("active_bonus_attackspeed")
end
function modifier_item_golden_eagle_relic_enabled:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("active_bonus_movespeed_pct")
end

if IsServer() then
	function modifier_item_golden_eagle_relic_enabled:OnCreated()
		self.interval = 0.5
		self:StartIntervalThink(self.interval)
		self:OnIntervalThink()
		self:GetParent():UpdateAttackProjectile()
	end

	function modifier_item_golden_eagle_relic_enabled:OnDestroy()
		self:GetParent():UpdateAttackProjectile()
	end

	function modifier_item_golden_eagle_relic_enabled:OnIntervalThink()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local gold = Gold:GetGold(parent) * ability:GetAbilitySpecial("active_gold_lost_per_sec_pct") * 0.01 * self.interval
		Gold:RemoveGold(parent, math.max(gold, ability:GetAbilitySpecial("active_gold_lost_per_sec_min")))
	end

	function modifier_item_golden_eagle_relic_enabled:OnAttackLanded(keys)
		local target = keys.target
		local attacker = keys.attacker
		if attacker == self:GetParent() then
			local ability = self:GetAbility()
			if not (target.IsBoss and target:IsBoss()) and not attacker:IsIllusion() then
				local dmg = Gold:GetGold(attacker) * ability:GetSpecialValueFor("active_gold_as_damage_pct") * 0.01
				ApplyDamage({
					victim = target,
					attacker = attacker,
					damage = dmg,
					damage_type = ability:GetAbilityDamageType(),
					ability = ability
				})
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, dmg, nil)
			end

		end
	end
end
