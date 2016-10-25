function DoubleAttack(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not caster:HasModifier("modifier_item_echo_sabre_2") and PreformAbilityPrecastActions(caster, ability) then
		Timers:CreateTimer(ability:GetAbilitySpecial("attack_delay"), function()
			local can = true
			if caster.AttackFuncs and caster.AttackFuncs.bNoDoubleAttackMelee ~= nil then
				can = not caster.AttackFuncs.bNoDoubleAttackMelee
			end
			if not IsRangedUnit(caster) and can then
				PerformGlobalAttack(caster, target, true, true, true, true, true, {bNoDoubleAttackMelee = true})
				ability:ApplyDataDrivenModifier(caster, target, "modifier_item_echo_sabre_arena_debuff", nil)
			end
		end)
	end
end

function DoubleAttack2(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if PreformAbilityPrecastActions(caster, ability) then
		Timers:CreateTimer(ability:GetAbilitySpecial("attack_delay"), function()
			local can = true
			if caster.AttackFuncs and caster.AttackFuncs.bNoDoubleAttackMelee ~= nil then
				can = not caster.AttackFuncs.bNoDoubleAttackMelee
			end
			if not IsRangedUnit(caster) and can then
				PerformGlobalAttack(caster, target, true, true, true, true, true, {bNoDoubleAttackMelee = true})
				ability:ApplyDataDrivenModifier(caster, target, "modifier_item_echo_sabre_2_debuff", nil)
			end
		end)
	end
end