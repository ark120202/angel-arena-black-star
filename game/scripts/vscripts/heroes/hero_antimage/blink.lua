--[[Author: Amused/D3luxe
	Used by: Pizzalol
	Date: 11.07.2015.
	Blinks the target to the target point, if the point is beyond max blink range then blink the maximum range]]
function Blink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local casterPos = caster:GetAbsOrigin()
	local blink_range = ability:GetLevelSpecialValueFor("blink_range", ability:GetLevel() - 1)

	if (point - casterPos):Length2D() > blink_range then
		point = casterPos + (point - casterPos):Normalized() * blink_range
	end
	
	ParticleManager:CreateParticle("particles/units/heroes/hero_antimage/antimage_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
	FindClearSpaceForUnit(caster, point, false)
	ProjectileManager:ProjectileDodge(caster)
	
	local silence = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_antimage/blink_silence.vpcf", PATTACH_ABSORIGIN, caster)
	ParticleManager:SetParticleControl(silence, 1, Vector(ability:GetLevelSpecialValueFor("silence_radius", ability:GetLevel() - 1)))
end