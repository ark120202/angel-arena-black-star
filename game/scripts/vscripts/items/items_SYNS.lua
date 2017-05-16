function sange_lesser_maim_stacks(keys)
	local ability = keys.ability
	local target = keys.target
	local caster = keys.caster
	local modifier = keys.modifier
	if IsModifierStrongest(caster, string.gsub(modifier, "lesser_maim", "unique"), MODIFIER_PROC_PRIORITY.sange) then
		target:EmitSound("DOTA_Item.Maim")
		if target:GetModifierStackCount(modifier, caster) < ability:GetSpecialValueFor("maim_max_stacks") then
			AddStacks(ability, caster, target, modifier, 1, true)
		else
			ability:ApplyDataDrivenModifier(caster, target, modifier, {})
		end
	end
end

function yasha_fast_attack_stacks(keys)
	local ability = keys.ability
	local caster = keys.caster
	local modifier = keys.modifier
	if IsModifierStrongest(caster, string.gsub(modifier, "fast_attack", "unique"), MODIFIER_PROC_PRIORITY.yasha) then
		if caster:GetModifierStackCount(modifier, caster) < ability:GetSpecialValueFor("fast_attack_max_stacks") then
			AddStacks(ability, caster, caster, modifier, 1, true)
		else
			ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
		end
	end
end

function CooldownReduction(keys)
	local caster = keys.caster
	local cooldown_reducted = keys.cooldown_reducted
	local modifier = keys.modifier
	if IsModifierStrongest(caster, modifier, MODIFIER_PROC_PRIORITY.nightshadow) then
		for i = 0, caster:GetAbilityCount() - 1 do
			local ability = caster:GetAbilityByIndex(i)
			if ability then
				local cooldown_remaining = ability:GetCooldownTimeRemaining()
				ability:EndCooldown()
				if cooldown_remaining > cooldown_reducted then
					ability:StartCooldown(cooldown_remaining - cooldown_reducted)
				end
			end
		end
	end
end
