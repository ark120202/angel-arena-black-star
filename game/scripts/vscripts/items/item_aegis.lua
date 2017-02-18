function StartDurationTooltip(keys)
	local ability = keys.ability
	ability:StartCooldown(ability:GetSpecialValueFor("disappear_time"))
end

function CheckDeath(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:IsIllusion() then
	--	Timers:CreateTimer(0.03, function()
			if caster.IsMarkedForTrueKill or caster:GetHealth() > 1 or caster.is_reincarnating then
				caster:RemoveModifierByName("modifier_item_aegis_arena_life_saver")
			else
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_aegis_arena_life_saver", {})
				caster:SetHealth(1)
				ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_aegis_arena_reincarnation", {})
			end
	--	end)
	end
end

function AegisExpire(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster.is_reincarnating then
		caster:EmitSound("Aegis.Expire")
		caster:SetHealth(caster:GetMaxHealth())
		caster:SetMana(caster:GetMaxMana())
		UTIL_Remove(ability)
	end
end

function OnModCreated(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:AddNoDraw()
	caster.is_reincarnating = true
	ability.pfx_aegis_respawn_timer = ParticleManager:CreateParticle(keys.particle, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(ability.pfx_aegis_respawn_timer, 0, caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(ability.pfx_aegis_respawn_timer, 1, Vector(keys.Duration, 0, 0))
	ability:CreateVisibilityNode(caster:GetAbsOrigin(), keys.vision_radius, keys.Duration)
	caster:EmitSound(keys.sound)
	local model = "models/props_gameplay/tombstoneb01.vmdl"
	local grave = Entities:CreateByClassname("prop_dynamic")
	grave:SetModel(model)
	grave:SetAbsOrigin(caster:GetAbsOrigin())
	ability.npc_aegis_tombstone = grave
end

function OnModDestroy(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster.is_reincarnating = false
	caster:RemoveNoDraw()
	caster:SetHealth(caster:GetMaxHealth())
	caster:SetMana(caster:GetMaxMana())
	caster:Purge(false, true, false, true, false)
	ParticleManager:DestroyParticle(ability.pfx_aegis_respawn_timer, false)
	local pfx = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN, caster)
	UTIL_Remove(ability)
	ability.npc_aegis_tombstone:RemoveSelf()
end