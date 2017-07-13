function Dagon(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local Damage = keys.Damage

	local dagon_particle = ParticleManager:CreateParticle("particles/items_fx/dagon.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	local particle_effect_intensity = 300 + (100 * ability:GetLevel())
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))

	caster:EmitSound("DOTA_Item.Dagon.Activate")
	target:EmitSound("DOTA_Item.Dagon5.Target")

	ApplyDamage({victim = target, attacker = caster, damage = Damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
end

function BetterDagon(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local Damage = keys.Damage

	local dagon_particle = ParticleManager:CreateParticle("particles/econ/events/ti4/dagon_ti4.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	local particle_effect_intensity = 300 + (100 * ability:GetLevel())
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))

	caster:EmitSound("DOTA_Item.Dagon.Activate")
	target:EmitSound("DOTA_Item.Dagon5.Target")
	if keys.modifier then
		ability:ApplyDataDrivenModifier(caster, target, keys.modifier, {})
	end
	ApplyDamage({victim = target, attacker = caster, damage = Damage, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
end

function SunrayDagon(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local Damage = keys.Damage

	local dagon_particle = ParticleManager:CreateParticle("particles/econ/events/ti5/dagon_lvl2_ti5.vpcf",  PATTACH_ABSORIGIN_FOLLOW, caster)
	ParticleManager:SetParticleControlEnt(dagon_particle, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
	local particle_effect_intensity = 300 + (100 * ability:GetLevel())
	ParticleManager:SetParticleControl(dagon_particle, 2, Vector(particle_effect_intensity))

	caster:EmitSound("DOTA_Item.Dagon.Activate")
	target:EmitSound("DOTA_Item.Dagon5.Target")
	if keys.modifier then
		ability:ApplyDataDrivenModifier(caster, target, keys.modifier, {})
	end
	local PctDmg = caster:GetMaxHealth() * keys.DamagePct * 0.01
	ApplyDamage({victim = target, attacker = caster, damage = Damage + PctDmg, damage_type = DAMAGE_TYPE_MAGICAL, ability = ability})
end
