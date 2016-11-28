function AutoSheepstick(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target:IsHero() then
		if PreformAbilityPrecastActions(caster, ability) then
			caster:SetCursorCastTarget(target)
			ability:OnSpellStart()
		end
	end
end

function CastHex(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target:IsIllusion() then
		ability:EndCooldown()
		ability:StartCooldown(ability:GetLevelSpecialValueFor("cooldown_illusion", ability:GetLevel() - 1))
		target:Kill(ability, caster)
	else
		if not target:TriggerSpellAbsorb(ability) then
			target:TriggerSpellReflect(ability)
			target:EmitSound("Ability.StarfallImpact")
			ApplyDamage({victim = target, attacker = caster, damage = ability:GetAbilityDamage(), damage_type = ability:GetAbilityDamageType(), ability = ability})
			target:AddNewModifier(caster, ability, "modifier_sheepstick_debuff", {duration = keys.hex_duration, sheep_movement_speed = keys.sheep_movement_speed})
		end
	end
end