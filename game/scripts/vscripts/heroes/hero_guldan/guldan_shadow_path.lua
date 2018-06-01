LinkLuaModifier("modifier_guldan_shadow_path", "heroes/hero_guldan/guldan_shadow_path.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_guldan_shadow_path_effect", "heroes/hero_guldan/guldan_shadow_path.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_guldan_shadow_path_effect_slow', "heroes/hero_guldan/guldan_shadow_path.lua", LUA_MODIFIER_MOTION_NONE)

guldan_shadow_path = class({
	GetInstricModifierName = function() return "modifier_guldan_shadow_path" end
})

function guldan_shadow_path:GetCastRange()
	if self:GetCaster():HasScepter() then
	return self:GetSpecialValueFor("aura_radius_scepter")
	else return self:GetSpecialValueFor("aura_radius")
	end
end

modifier_guldan_shadow_path = class ({})

if IsServer() then
	function guldan_shadow_path:OnSpellStart()
		local caster = self:GetCaster()
		caster:EmitSound("DOTA_Item.MagicWand.Activate")
		local duration = self:GetSpecialValueFor("duration")
		if caster:HasScepter() then
			duration = self:GetSpecialValueFor("duration_scepter")
		end
		caster:AddNewModifier(caster, self, "modifier_guldan_shadow_path", {duration = duration})
	end

	function modifier_guldan_shadow_path:OnCreated()
		self:StartIntervalThink(0.1)
	end

	function modifier_guldan_shadow_path:OnIntervalThink()
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()
		local radius = self:GetAbility():GetSpecialValueFor("aura_radius")
		if not caster:HasScepter() then
			radius = self:GetAbility():GetSpecialValueFor("aura_radius_scepter")
		end

		for _,v in ipairs(FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)) do
			local modifier = v:FindModifierByNameAndCaster("modifier_guldan_shadow_path_effect", target)
			if not modifier then
				v:AddNewModifier(target, ability, "modifier_guldan_shadow_path_effect", {duration = 0.11})
			else
				modifier:SetDuration(0.11, false)
			end
		end
	end
end


function modifier_guldan_shadow_path:GetEffectName()
	return "particles/arena/units/heroes/hero_guldan/guldan_shadow_path.vpcf"
end

function modifier_guldan_shadow_path:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

modifier_guldan_shadow_path_effect = class({
	IsPurgable = function() return false end,
})

if IsServer() then
	modifier_guldan_shadow_path_effect.interval_think = 0.13

	function modifier_guldan_shadow_path_effect:OnCreated()
		self:StartIntervalThink(self.interval_think)
	end

	function modifier_guldan_shadow_path_effect:OnIntervalThink()
		local parent = self:GetParent()
		parent:EmitSound("DOTA_Item.MagicWand.Activate")
		parent:EmitSound("DOTA_Item.MagicWand.Activate")
		local damage = self:GetAbility():GetSpecialValueFor('damage_per_second')
		local damagetype = DAMAGE_TYPE_MAGICAL

		if self:GetCaster():HasScepter() then
			local damage = self:GetAbility():GetSpecialValueFor('damage_per_second_scepter')
			local damagetype = DAMAGE_TYPE_PURE
		end
		ApplyDamage({
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = damagetype,
			ability = self:GetAbility()
		})
	end

	function modifier_guldan_shadow_path_effect:OnDestroy()
		local parent = self:GetParent()
		if not parent:FindModifierByNameAndCaster("modifier_guldan_shadow_path", self:GetAbility():GetCaster()) then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_guldan_shadow_path_effect_slow", {duration = self:GetAbility():GetSpecialValueFor("duration_slow_after")})
		end
	end

end

function modifier_guldan_shadow_path_effect:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
end

function modifier_guldan_shadow_path_effect:GetModifierMoveSpeedBonus_Percentage()
	if self:GetCaster():HasScepter() then
		return self:GetAbility():GetSpecialValueFor('movement_speed_reduce_scepter')
	else
		return self:GetAbility():GetSpecialValueFor('movement_speed_reduce')
	end
end

modifier_guldan_shadow_path_effect_slow = class({
	IsPurgable = function() return true end,
})

function modifier_guldan_shadow_path_effect_slow:DeclareFunctions()
	return {MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,}
end

function modifier_guldan_shadow_path_effect_slow:GetModifierMoveSpeedBonus_Percentage()
	if self:GetCaster():HasScepter() then
		return self:GetAbility():GetSpecialValueFor('movement_speed_reduce_after_scepter')
	else
		return self:GetAbility():GetSpecialValueFor('movement_speed_reduce_after')
	end
end
