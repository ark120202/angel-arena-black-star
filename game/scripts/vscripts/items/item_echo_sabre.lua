function DoubleAttack(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local level_map = {
		[1] = "modifier_item_echo_sabre_arena",
		[2] = "modifier_item_echo_sabre_2",
		[3] = "modifier_item_fallhammer",
	}
	for i,v in ipairs(level_map) do
		if i > keys.level then
			if caster:HasModifier(v) then
				return
			end
		end
	end
	if ability:PerformPrecastActions() and not caster:IsIllusion() and (not caster:IsRangedUnit() or not (caster.AttackFuncs ~= nil and caster.AttackFuncs.bNoDoubleAttackMelee)) then
		Timers:CreateTimer(ability:GetAbilitySpecial("attack_delay"), function()
			if IsValidEntity(caster) and IsValidEntity(ability) then
				local can = true
				if can and not caster:IsRangedUnit() and caster.AttackFuncs and caster.AttackFuncs.bNoDoubleAttackMelee ~= nil then
					can = not caster.AttackFuncs.bNoDoubleAttackMelee
				end
				if can and IsValidEntity(target) then
					if not caster:IsRangedUnit() then
						PerformGlobalAttack(caster, target, true, true, true, true, true, false, true, {bNoDoubleAttackMelee = true})
					end
					if not target:IsMagicImmune() then
						ability:ApplyDataDrivenModifier(caster, target, keys.modifier, nil)
					end
					if keys.Damage then
						ApplyDamage({
							victim = target,
							attacker = caster,
							damage = keys.Damage,
							damage_type = ability:GetAbilityDamageType(),
							ability = ability
						})
					end
					if keys.TargetSound then
						target:EmitSound(keys.TargetSound)
					end
				end
			end
		end)
	end
end
