function ApplyParticleToIllusions(keys)
	local caster = keys.caster
	local target = keys.target
	if target:IsIllusion() and caster:IsRealHero() then
		target.GemOfClearMindIllusionParticle = ParticleManager:CreateParticleForTeam("particles/arena/items_fx/gem_of_clear_mind_illusion.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, caster:GetTeamNumber())
	end
end

function RemoveParticleFromIllusions(keys)
	local target = keys.target
	if target.GemOfClearMindIllusionParticle then
		ParticleManager:DestroyParticle(target.GemOfClearMindIllusionParticle, false)
		target.GemOfClearMindIllusionParticle = nil
	end
end