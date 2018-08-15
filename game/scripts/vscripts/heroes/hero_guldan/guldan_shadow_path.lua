LinkLuaModifier("modifier_guldan_shadow_path", "heroes/hero_guldan/guldan_shadow_path.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_guldan_shadow_path_effect", "heroes/hero_guldan/guldan_shadow_path.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_guldan_shadow_path_effect_slow', "heroes/hero_guldan/guldan_shadow_path.lua", LUA_MODIFIER_MOTION_NONE)

guldan_shadow_path = class({
	GetInstricModifierName = function() return "modifier_guldan_shadow_path" end
})

function guldan_shadow_path:GetCastRange()
	return self:GetSpecialValueFor(self:GetCaster():HasScepter()  and "aura_radius_scepter" or "aura_radius")
end

modifier_guldan_shadow_path = class ({})

if IsServer() then
	function guldan_shadow_path:OnSpellStart()
		local caster = self:GetCaster()
		caster:EmitSound("Arena.Hero_Guldan.ShadowPath.Start")
		local duration = self:GetSpecialValueFor(caster:HasScepter() and "duration_scepter" or "duration")

		caster:AddNewModifier(caster, self, "modifier_guldan_shadow_path", {duration = duration})
	end

	function modifier_guldan_shadow_path:OnCreated()
		local interval = self:GetCaster():HasScepter() and self:GetAbility():GetSpecialValueFor("interval_scepter") or self:GetAbility():GetSpecialValueFor("interval")
		self:StartIntervalThink(interval)
	end

	function modifier_guldan_shadow_path:OnIntervalThink()
		local caster = self:GetCaster()
		local target = self:GetParent()
		local ability = self:GetAbility()
		local interval = self:GetCaster():HasScepter() and self:GetAbility():GetSpecialValueFor("interval_scepter") or self:GetAbility():GetSpecialValueFor("interval")
		self:GetParent():EmitSound("Arena.Hero_Guldan.ShadowPath.Cast")
		local radius = self:GetAbility():GetSpecialValueFor(self:GetCaster():HasScepter() and "aura_radius_scepter" or "aura_radius")

		for _,v in ipairs(FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)) do
			local modifier = v:FindModifierByNameAndCaster("modifier_guldan_shadow_path_effect", target)
			if not modifier then
				v:AddNewModifier(target, ability, "modifier_guldan_shadow_path_effect", {duration = interval + 0.1})
			else
				modifier:SetDuration(interval + 0.1, false)
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

	function modifier_guldan_shadow_path_effect:OnCreated()
		local interval = self:GetCaster():HasScepter() and self:GetAbility():GetSpecialValueFor("interval_scepter") or self:GetAbility():GetSpecialValueFor("interval")
		self:StartIntervalThink(interval)
	end

	function modifier_guldan_shadow_path_effect:OnIntervalThink()
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local damage = ability:GetSpecialValueFor(self:GetCaster():HasScepter() and 'damage_per_second_scepter' or 'damage_per_second')
		local damagetype = self:GetCaster():HasScepter() and DAMAGE_TYPE_PURE or DAMAGE_TYPE_MAGICAL

		ApplyDamage({
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = damagetype,
			ability = ability
		})
	end

	function modifier_guldan_shadow_path_effect:OnDestroy()
		local parent = self:GetParent()
		if not self:GetCaster():HasModifier("modifier_guldan_shadow_path") then
			parent:AddNewModifier(parent, self:GetAbility(), "modifier_guldan_shadow_path_effect_slow", {duration = self:GetAbility():GetSpecialValueFor("duration_slow_after")})
		end
	end

end

function modifier_guldan_shadow_path_effect:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_guldan_shadow_path_effect:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor(self:GetCaster():HasScepter() and 'movement_speed_reduce_scepter' or 'movement_speed_reduce')
end

modifier_guldan_shadow_path_effect_slow = class({
	IsPurgable = function() return true end,
})

function modifier_guldan_shadow_path_effect_slow:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end

function modifier_guldan_shadow_path_effect_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetCaster():HasScepter() and self:GetAbility():GetSpecialValueFor('movement_speed_reduce_after_scepter') or self:GetAbility():GetSpecialValueFor('movement_speed_reduce_after')
end
