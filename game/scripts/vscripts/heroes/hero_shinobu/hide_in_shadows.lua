function CheckInvis(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetAbilitySpecial("ally_radius")
	local allies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
	if not caster:HasModifier("modifier_shinobu_hide_in_shadows_invisibility") and not caster:HasModifier("modifier_shinobu_hide_in_shadows_fade") then
		if #allies > 1 then
			ability:ApplyDataDrivenModifier(caster, caster, "modifier_shinobu_hide_in_shadows_fade", nil)
		end
	elseif #allies == 1 then
		caster:RemoveModifierByName("modifier_shinobu_hide_in_shadows_fade")
		caster:RemoveModifierByName("modifier_shinobu_hide_in_shadows_invisibility")
	end
	if not caster:IsIllusion() then
		if not ability.CreatedParticles then ability.CreatedParticles = {} end
		for _,v in ipairs(HeroList:GetAllHeroes()) do
			if v:GetTeam() == caster:GetTeam() and v ~= caster and v:IsAlive() and not ability.CreatedParticles[v] and not v:IsIllusion() then
				local pfx = ParticleManager:CreateParticleForPlayer("particles/arena/range_display.vpcf", PATTACH_ABSORIGIN_FOLLOW, v, caster:GetPlayerOwner())
				ParticleManager:SetParticleControl(pfx, 1, Vector(radius))
				ParticleManager:SetParticleControl(pfx, 15, Vector(0, 255, 255))
				ability.CreatedParticles[v] = pfx
			elseif not v:IsAlive() and ability.CreatedParticles[v] then
				ParticleManager:DestroyParticle(ability.CreatedParticles[v], true)
				ability.CreatedParticles[v] = nil
			end
		end
	end
end

function PurgeAllTruesightModifiers(keys)
	PurgeTruesightModifiers(keys.caster)
end

function UpgradeCleanup(keys)
	local ability = keys.ability
	if ability.CreatedParticles then
		for _, v in pairs(ability.CreatedParticles) do
			ParticleManager:DestroyParticle(v, true)
		end
		ability.CreatedParticles = nil
	end
end