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

function GiveKillBonusGold(keys)
	local caster = keys.caster
	local modifiers = {
		"modifier_item_skull_of_midas_unique",
		"modifier_item_golden_eagle_relic_unique",
	}
	local ind = table.findIndex(modifiers, keys.modifier)[1]
	for i,v in ipairs(modifiers) do
		if caster:HasModifier(v) and ind and i > ind then
			return
		end
	end
	Gold:ModifyGold(caster, keys.KillGold)
	caster:AddExperience(keys.KillXp, false, false)
	local particle = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf", PATTACH_ABSORIGIN, keys.unit, caster:GetPlayerOwner())
	ParticleManager:SetParticleControl(particle, 1, Vector(0, keys.KillGold, 0))
	ParticleManager:SetParticleControl(particle, 2, Vector(2, string.len(keys.KillGold) + 1, 0))
	ParticleManager:SetParticleControl(particle, 3, Vector(255, 200, 33))
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
