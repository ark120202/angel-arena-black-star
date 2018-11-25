item_piercing_blade = {
	GetIntrinsicModifierName = function() return "modifier_item_piercing_blade" end
}


LinkLuaModifier("modifier_item_piercing_blade", "items/item_piercing_blade.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_piercing_blade = {
	IsHidden      = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable    = function() return false end,
}

function modifier_item_piercing_blade:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_item_piercing_blade:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

if IsServer() then
	function modifier_item_piercing_blade:OnAttackLanded(keys)
		local attacker = keys.attacker
		if attacker ~= self:GetParent() then return end
		local ability = self:GetAbility()
		local target = keys.target

		if attacker:FindAllModifiersByName(self:GetName())[1] ~= self then return end

		if IsModifierStrongest(attacker, self:GetName(), MODIFIER_PROC_PRIORITY.pure_damage) then
			ApplyDamage({
				victim = target,
				attacker = attacker,
				damage = keys.original_damage * ability:GetSpecialValueFor("attack_damage_to_pure_pct") * 0.01,
				damage_type = ability:GetAbilityDamageType(),
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			})
		end
	end
end
