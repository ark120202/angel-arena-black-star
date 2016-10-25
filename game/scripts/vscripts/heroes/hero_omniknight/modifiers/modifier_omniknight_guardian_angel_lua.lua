modifier_omniknight_guardian_angel_lua = class({})

function modifier_omniknight_guardian_angel_lua:GetEffectName()
	return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf"
end

function modifier_omniknight_guardian_angel_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_omniknight_guardian_angel_lua:GetStatusEffectName()
	return "particles/status_fx/status_effect_guardian_angel.vpcf"
end

function modifier_omniknight_guardian_angel_lua:StatusEffectPriority()
	return 10
end


function modifier_omniknight_guardian_angel_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL
	}
end

function modifier_omniknight_guardian_angel_lua:GetAbsoluteNoDamagePhysical()
	return 1
end