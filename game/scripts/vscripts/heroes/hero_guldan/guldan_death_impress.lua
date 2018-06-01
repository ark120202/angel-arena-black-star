LinkLuaModifier("modifier_guldan_death_impress", "heroes/hero_guldan/guldan_death_impress.lua", LUA_MODIFIER_MOTION_NONE)

guldan_death_impress = class ({
	GetInstricModifierName = function() return 'modifier_guldan_death_impress' end
})

if IsServer() then
	function guldan_death_impress:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		target:EmitSound("Hero_Medusa.MysticSnake.Cast")
		target:AddNewModifier(caster, self, "modifier_guldan_death_impress", {duration = ability:GetSpecialValueFor("duration")})
		local particle = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_guldan/guldan_death_impress.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
	end
end

modifier_guldan_death_impress = class({
	IsPurgable = true,
})

function modifier_guldan_death_impress:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}
end

function modifier_guldan_death_impress:DeclareFunctions()
	return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS}
end

function modifier_guldan_death_impress:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor('magic_damage_debuff')
end

