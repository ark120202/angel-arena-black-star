function SpellCheck(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if PERSONALITY_STEAL_BANNED_HEROES[GetFullHeroName(target)] then
		ability:EndCooldown()
		ability:RefundManaCost()
		Containers:DisplayError(caster:GetPlayerID(), "#dota_hud_error_cant_steal_spell")
	else
		caster:EmitSound("Hero_Rubick.SpellSteal.Cast")
		target:EmitSound("Hero_Rubick.SpellSteal.Target")
		ability.new_steal_target = target
		ProjectileManager:CreateTrackingProjectile({
			Target = caster,
			Source = target,
			Ability = ability,
			EffectName = keys.particle,
			bDodgeable = false,
			bProvidesVision = false,
			iMoveSpeed = ability:GetAbilitySpecial("projectile_speed"),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
		})
	end
end

function SpellSteal(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = ability.new_steal_target
	if caster:HasModifier("modifier_rubick_personality_steal") then
		ability:EndCooldown()
		ability:RefundManaCost()
		return
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_rubick_personality_steal", {})
	caster.rubick_spell_steal = {
		model = caster:GetModelName(),
		model_scale = caster:GetModelScale(),
		attack_capability = caster:GetAttackCapability(),
		primary_attribute = caster:GetPrimaryAttribute(),
	}
	ability:SetHidden(true)
	for i = 0, caster:GetAbilityCount() - 1 do
		local a = caster:GetAbilityByIndex(i)
		if a and a ~= ability then
			UTIL_Remove(a)
		end
	end
	local model = target:GetModelName()
	caster:SetModel(model)
	caster:SetOriginalModel(model)
	caster:SetModelScale(target:GetModelScale())
	caster:SetAttackCapability(target:GetAttackCapability())
	caster:SetRangedProjectileName(target:GetKeyValue("ProjectileModel"))
	caster:AddNewModifier(caster, ability, "modifier_set_attack_range", {AttackRange = target:GetAttackRange()})
	caster:SetPrimaryAttribute(target:GetPrimaryAttribute())

	caster:CalculateStatBonus()
	local targetname = target:GetFullName()
	Timers:CreateTimer(0.03, function()
		local hc = NPC_HEROES_CUSTOM[targetname]
		if hc then
			for k,v in pairsByKeys(hc) do
				if string.starts(k, "Ability") and v ~= "" then
					AddNewAbility(caster, v, true)
				end
			end
		end
		caster:CalculateStatBonus()
	end)
	
	caster:ResetAbilityPoints()
end

function RemoveSpell(keys)
	local caster = keys.caster
	local ability = keys.ability
	for i = 0, caster:GetAbilityCount() - 1 do
		local a = caster:GetAbilityByIndex(i)
		if a and a ~= ability then
			RemoveAbilityWithModifiers(caster, a)
		end
	end
	ability:SetHidden(false)
	caster:SetModel(caster.rubick_spell_steal.model)
	caster:SetOriginalModel(caster.rubick_spell_steal.model)
	caster:SetModelScale(caster.rubick_spell_steal.model_scale)
	caster:SetAttackCapability(caster.rubick_spell_steal.attack_capability)
	caster:SetRangedProjectileName(caster:GetKeyValue("ProjectileModel"))
	caster:RemoveModifierByNameAndCaster("modifier_set_attack_range", caster)
	caster:SetPrimaryAttribute(caster.rubick_spell_steal.primary_attribute)
	caster.rubick_spell_steal = nil
	caster:ResetAbilityPoints()
end