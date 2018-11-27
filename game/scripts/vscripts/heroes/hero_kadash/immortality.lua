function CheckDeath(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability.health_per_reincarnation_pct = ability:GetAbilitySpecial("health_per_reincarnation_pct")
	if caster:HasScepter() then
		ability.health_per_reincarnation_pct = ability:GetAbilitySpecial("health_per_reincarnation_pct_scepter")
	end
	local pct = caster:GetTotalHealthReduction()
	if (
		caster.IsMarkedForTrueKill or
		caster:GetHealth() > 1 or
		caster.is_reincarnating or
		caster:IsIllusion() or
		caster:IsTempestDouble() or
		pct + ability.health_per_reincarnation_pct >= 100
	) then
		caster:RemoveModifierByName("modifier_kadash_immortality_life_saver")
	else
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_kadash_immortality_life_saver", {})
		caster:SetHealth(1)
		caster:SetMana(0)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_kadash_immortality_reincarnation", {})
	end
end

function OnModCreated(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:AddNoDraw()
	caster.is_reincarnating = true
	if not ability.pfx_reincarnation_respawn_timer then ability.pfx_reincarnation_respawn_timer = {} end
	ability.pfx_reincarnation_respawn_timer[caster:GetEntityIndex()] = ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/wraith_king_reincarnate.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(ability.pfx_reincarnation_respawn_timer[caster:GetEntityIndex()], 0, caster:GetAbsOrigin())
	ability:CreateVisibilityNode(caster:GetAbsOrigin(), keys.vision_radius, keys.Duration)
	caster:EmitSound("Hero_SkeletonKing.Reincarnate")
	caster:EmitSound("Hero_SkeletonKing.Death")
	local model = "models/props_gameplay/tombstoneb01.vmdl"
	local grave = Entities:CreateByClassname("prop_dynamic")
	grave:SetModel(model)
	grave:SetAbsOrigin(caster:GetAbsOrigin())
	ability.npc_reincarnation_tombstone = grave
	local particle1 = ParticleManager:CreateParticle( "particles/units/heroes/hero_skeletonking/skeleton_king_death_bits.vpcf", PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControl(particle1, 0, caster:GetAbsOrigin())
	local particle2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_skeletonking/skeleton_king_death_dust.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl(particle2, 0, caster:GetAbsOrigin())
	local particle3 = ParticleManager:CreateParticle( "particles/units/heroes/hero_skeletonking/skeleton_king_death_dust_reincarnate.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControl(particle3, 0, caster:GetAbsOrigin())
	caster:Purge(false, true, false, true, false)
end

function OnModDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability

	caster:EmitSound("Hero_SkeletonKing.Reincarnate.Stinger")
	caster.is_reincarnating = false
	caster:RemoveNoDraw()
	caster:SetHealth(caster:GetMaxHealth())
	caster:SetMana(0)
	caster:Purge(false, true, false, true, false)
	ParticleManager:DestroyParticle(ability.pfx_reincarnation_respawn_timer[caster:GetEntityIndex()], false)
	ability.npc_reincarnation_tombstone:RemoveSelf()
	ModifyStacks(ability, caster, caster, "modifier_kadash_immortality_health_penalty", ability.health_per_reincarnation_pct, false)
	if caster:HasScepter() then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_kadash_immortality_ghostform", nil)
		caster:EmitSound("DOTA_Item.GhostScepter.Activate")
	end
end

function ThinkPenalty(keys)
	keys.caster:CalculateHealthReduction()
end
