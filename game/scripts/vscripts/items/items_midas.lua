function MidasCreep(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	Gold:AddGoldWithMessage(caster, keys.BonusGold)
	if caster.AddExperience then
		caster:AddExperience(target:GetDeathXP() * keys.XPMultiplier, false, false)
	end
	target:EmitSound("DOTA_Item.Hand_Of_Midas")
	local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControlEnt(midas_particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)

	target:SetDeathXP(0)
	target:SetMinimumGoldBounty(0)
	target:SetMaximumGoldBounty(0)
	target:Kill(ability, caster)
end

function GiveOnAttackedGold(keys)
	local attacker = keys.attacker
	local caster = keys.caster

	if (
		attacker:IsConsideredHero() and
		not attacker:IsIllusion() and
		not caster:IsIllusion() and
		caster:GetTeamNumber() ~= attacker:GetTeamNumber()
	) then
		local gold = keys.Gold
		local xp = keys.Xp

		local presymbol = POPUP_SYMBOL_PRE_PLUS
		local particle = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf", PATTACH_ABSORIGIN, caster, caster:GetPlayerOwner())

		if attacker:IsBoss() then
			gold = -gold
			presymbol = POPUP_SYMBOL_PRE_MINUS
			xp = 0
		end

		ParticleManager:SetParticleControl(particle, 1, Vector(presymbol, math.abs(gold), 0))
		ParticleManager:SetParticleControl(particle, 2, Vector(2, string.len(math.abs(gold)) + 1, 0))
		ParticleManager:SetParticleControl(particle, 3, Vector(255, 200, 33))

		if caster.AddExperience then
			caster:AddExperience(xp, false, false)
		end
		Gold:ModifyGold(caster, gold)
	end
end
