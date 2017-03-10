function OnSpellStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local duration = ability:GetLevelSpecialValueFor("duration", level)
	local creep_duration = ability:GetLevelSpecialValueFor("creep_duration", level)
	local damage_interval = ability:GetLevelSpecialValueFor("damage_interval", level)
	if target:IsHero() or target:IsBoss() then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_frost_bite_root_arena", {duration = duration})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_frost_bite_damage_arena", {duration = duration - damage_interval})
	else
		ability:ApplyDataDrivenModifier(caster, target, "modifier_frost_bite_root_arena", {duration = creep_duration})
		ability:ApplyDataDrivenModifier(caster, target, "modifier_frost_bite_damage_arena", {duration = creep_duration - damage_interval})
	end
end