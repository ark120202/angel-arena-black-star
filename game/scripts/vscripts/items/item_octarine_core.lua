function OnDealDamage(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	if ability:RollPRD(ability:GetLevelSpecialValueFor("bash_chance", ability:GetLevel() - 1), "bash_chance_PRD") then
		target:AddNewModifier(caster, ability, "modifier_stunned", {duration = ability:GetLevelSpecialValueFor("bash_duration", ability:GetLevel() - 1)})
	end
end
