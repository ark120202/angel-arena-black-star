function Disarm(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability

	if ability:GetLevel() > 0 and not attacker:IsMagicImmune() and not attacker:IsInvulnerable() and PreformAbilityPrecastActions(caster, ability) then
		if caster:HasScepter() then
			attacker:AddNewModifier(caster, ability, "modifier_sheepstick_debuff", { duration = ability:GetLevelSpecialValueFor("disarm_duration", ability:GetLevel() - 1), sheep_movement_speed = ability:GetLevelSpecialValueFor("sheep_movement_speed_scepter", ability:GetLevel() - 1)})
		else
			ability:ApplyDataDrivenModifier(caster, attacker, "modifier_dragon_blood_arena_disarm_enemy", {})
		end
	end
end