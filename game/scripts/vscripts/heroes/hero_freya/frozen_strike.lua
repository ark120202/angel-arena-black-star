function CritProc(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_freya_frozen_strike_crit", {})
	local crit = ability:GetLevelSpecialValueFor("base_crit_pct", ability:GetLevel() - 1) + (ability:GetLevelSpecialValueFor("stat_to_crit_pct", ability:GetLevel() - 1) * caster:GetPrimaryStatValue() * 0.01)
	caster:SetModifierStackCount("modifier_freya_frozen_strike_crit", caster, crit)
	caster:EmitSound("Arena.Hero_Freya.FrozenStrike.Charge")
end