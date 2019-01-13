function OnAttackLanded(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not target:IsMagicImmune() and not target:IsInvulnerable() and not caster:IsIllusion() then
		local manaburn = keys.feedback_mana_burn
		local manadrain = manaburn * keys.feedback_mana_drain_pct * 0.01
		target:SpendMana(manaburn, ability)
		caster:GiveMana(manadrain)
		ApplyDamage({
			victim = target,
			attacker = caster,
			damage = manaburn * keys.damage_per_burn_pct * 0.01,
			damage_type = ability:GetAbilityDamageType(),
			ability = ability
		})
		ParticleManager:CreateParticle("particles/generic_gameplay/generic_manaburn.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:CreateParticle("particles/arena/generic_gameplay/generic_manasteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	end
end

function Purge(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ParticleManager:CreateParticle("particles/generic_gameplay/generic_purge.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	caster:EmitSound("DOTA_Item.DiffusalBlade.Activate")
	if target:IsSummoned() then
		target:EmitSound("DOTA_Item.DiffusalBlade.Kill")
	else
		target:EmitSound("DOTA_Item.DiffusalBlade.Target")
	end
	if target:GetTeamNumber() == caster:GetTeamNumber() then
		target:Purge(false, true, false, false, false)
	else
		if target:IsSummoned() then
			target:TrueKill(ability, caster)
		else
			target:Purge(true, false, false, false, false)
			if not target:IsMagicImmune() and not target:IsInvulnerable() then
				ability:ApplyDataDrivenModifier(caster, target, keys.modifier_root, {})
				ability:ApplyDataDrivenModifier(caster, target, keys.modifier_slow, {})
			end
		end
	end
end
