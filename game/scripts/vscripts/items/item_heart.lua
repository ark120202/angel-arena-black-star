function DamageStartCooldown(keys)
	local attacker = keys.attacker
	if attacker then
		if keys.Damage > 0 and ((attacker.IsControllableByAnyPlayer and attacker:IsControllableByAnyPlayer()) or IsBossEntity(attacker)) then
			keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()))
		end
	end
end

function UpdateCooldownModifiers(keys)
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	if ability:IsCooldownReady() and not caster:HasModifier(modifier) then
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
	elseif not ability:IsCooldownReady() and caster:HasModifier(modifier) then
		caster:RemoveModifierByName(modifier)
	end
end