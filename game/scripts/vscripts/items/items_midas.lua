function MidasCreep(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	Gold:ModifyGold(caster, keys.BonusGold)
	if caster.AddExperience then
		caster:AddExperience(target:GetDeathXP() * keys.XPMultiplier, false, false)
	end
	target:EmitSound("DOTA_Item.Hand_Of_Midas")
	local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)	
	ParticleManager:SetParticleControlEnt(midas_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, keys.BonusGold, nil)

	target:SetDeathXP(0)
	target:SetMinimumGoldBounty(0)
	target:SetMaximumGoldBounty(0)
	target:Kill(ability, caster)
end

function GiveOnAttackedGold(keys)
	local caster = keys.caster
	if keys.attacker:IsConsideredHero() then
		Gold:ModifyGold(caster, keys.Gold)
		caster:AddExperience(keys.Xp, false, false)
		local particle = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf", PATTACH_ABSORIGIN, caster, caster:GetPlayerOwner())
		ParticleManager:SetParticleControl(particle, 1, Vector(0, keys.Gold, 0))
		ParticleManager:SetParticleControl(particle, 2, Vector(2, string.len(keys.Gold) + 1, 0))
		ParticleManager:SetParticleControl(particle, 3, Vector(255, 200, 33))
	end
end
