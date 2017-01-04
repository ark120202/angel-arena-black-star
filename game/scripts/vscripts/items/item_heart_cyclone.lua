function modifier_item_heart_cyclone_regen_on_take_damage(keys)
	local attacker = keys.attacker
	local ability = keys.ability
	local caster = keys.caster
	if attacker then
		if keys.Damage > 0 and ((attacker.IsControllableByAnyPlayer and attacker:IsControllableByAnyPlayer()) or attacker:IsBoss()) then
			if caster:IsRangedAttacker() then
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_heart_cyclone_regen_cooldown", {duration=keys.CooldownRanged})
			else
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_heart_cyclone_regen_cooldown", {duration=keys.CooldownMelee})
			end
		end
	end
end

function item_heart_cyclone_on_spell_start(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target then
		if target:GetTeamNumber() == caster:GetTeamNumber() then
			target:Purge(false, true, false, true, false)
			ability:ApplyDataDrivenModifier(caster, target, "modifier_item_heart_cyclone_active_regen", {})
		else
			target:Purge(true, false, false, true, false)
			ability:ApplyDataDrivenModifier(caster, target, "modifier_item_heart_cyclone_active_damage", {})
		end
	end
end

function modifier_item_heart_cyclone_active_damage_on_interval_think(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ApplyDamage({
		victim = target,
		attacker = caster,
		damage = target:GetMaxHealth()*keys.damage*0.001,
		damage_type = DAMAGE_TYPE_PURE,
		ability = ability,
		damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION
	})
end