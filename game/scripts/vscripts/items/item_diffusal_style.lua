function item_diffusal_style_on_spell_start(keys)
	local caster = keys.caster
	local ability = keys.ability

	local manta_particle = ParticleManager:CreateParticle("particles/items2_fx/manta_phase.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	Timers:CreateTimer(keys.InvulnerabilityDuration, function() ParticleManager:DestroyParticle(manta_particle, false) end)
	caster:EmitSound("DOTA_Item.Manta.Activate")
	caster:Purge(false, true, false, false, false)
	ProjectileManager:ProjectileDodge(caster)
	if caster:IsHero() then
		ability:CreateVisibilityNode(caster:GetAbsOrigin(), keys.VisionRadius, keys.InvulnerabilityDuration)
		caster:AddNoDraw()
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_diffusal_style_invulnerability", nil)

		if caster.MantaIllusions then
			for _,v in ipairs(caster.MantaIllusions) do
				if v and not v:IsNull() and v:IsAlive() then
					v:ForceKill(false)
				end
			end
		end
	end
end

function modifier_item_diffusal_style_invulnerability_on_destroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	local caster_origin = caster:GetAbsOrigin()
	FindClearSpaceForUnit(caster, caster_origin + RandomVector(100), true)
	caster.MantaIllusions = {}
	for i = 1, ability:GetLevelSpecialValueFor("images_count", ability:GetLevel()-1) do
		local illusion = Illusions:create({
			unit = caster,
			ability = ability,
			origin = caster_origin + RandomVector(100),
			damageIncoming = ability:GetSpecialValueFor("illusion_damage_percent_incoming_tooltip"),
			damageOutgoing = ability:GetSpecialValueFor("illusion_damage_percent_outgoing_tooltip"),
			duration = ability:GetSpecialValueFor("illusion_duration"),
		})
		table.insert(caster.MantaIllusions, illusion)
	end

	caster:RemoveNoDraw()
end

function OnAttackLanded(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if caster:IsIllusion() then return end
	if not target:IsMagicImmune() and not target:IsInvulnerable() then
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

	if not caster:HasModifier(keys.modifier_cooldown) then
		ParticleManager:CreateParticle("particles/generic_gameplay/generic_purge.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		caster:EmitSound("DOTA_Item.DiffusalBlade.Activate")
		if target:IsSummoned() then
			target:EmitSound("DOTA_Item.DiffusalBlade.Kill")
		else
			target:EmitSound("DOTA_Item.DiffusalBlade.Target")
		end
		if target:IsSummoned() then
			target:TrueKill(ability, caster)
		else
			target:Purge(true, false, false, false, false)
			if not target:IsMagicImmune() and not target:IsInvulnerable() then
				ability:ApplyDataDrivenModifier(caster, target, keys.modifier_root, {})
				ability:ApplyDataDrivenModifier(caster, target, keys.modifier_slow, {})
			end
		end
		ability:ApplyDataDrivenModifier(caster, caster, keys.modifier_cooldown, {})
	end
end
