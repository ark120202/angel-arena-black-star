function StartCooldown(keys)
	local ability = keys.ability
	local a = keys.caster:FindAbilityByName(keys.new)
	a:StartCooldown(ability:GetCooldownTimeRemaining())
end

function ApplyStacks(keys)
	local target = keys.target
	local ability = keys.ability
	local stacks = target:GetPhysicalArmorBaseValue() * ability:GetAbilitySpecial("armor_cut_pct") * 0.01
	local m = ability:ApplyDataDrivenModifier(keys.caster, target, "modifier_apocalypse_armor_tear", nil)
	if m:GetStackCount() < stacks then
		m:SetStackCount(stacks)
	end
end
