function TrueFlame(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:IsInvulnerable() then
		local hp = caster:GetHealth()
		ApplyDamage({
			victim = caster,
			attacker = caster,
			damage = caster:GetHealth() * ability:GetAbilitySpecial("hp_as_damage_pct") * 0.01,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
			ability = ability
		})
		if caster:IsAlive() then
			ability.OldHealth = hp
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_vermillion_robe_delay", nil)
			ParticleManager:CreateParticle("particles/arena/items_fx/vermillion_robe_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		end
	end
end


function TrueFlameDamage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local damage = ability.OldHealth - caster:GetHealth()
	ability.OldHealth = nil
	
	ParticleManager:CreateParticle("particles/arena/items_fx/vermillion_robe_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetAbilitySpecial("damage_radius"), ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
		ApplyDamage({
			victim = v,
			attacker = caster,
			damage = damage,
			damage_type = ability:GetAbilityDamageType(),
			ability = ability
		})
	end
end

function CheckDust(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local pctMissing = 100 - caster:GetHealthPercent()
	local modifier = caster:FindModifierByName("modifier_item_vermillion_robe_dust")
	if pctMissing <= 0 then
		if modifier then
			modifier:Destroy()
		end
	else
		if not modifier then
			modifier = ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_vermillion_robe_dust", nil)
		end
		if modifier then
			modifier:SetStackCount(pctMissing)
		end
	end
end