--[[Author: YOLOSPAGHETTI
	Date: March 28, 2016
	Gives the caster's team vision in the radius]]
function GiveVision(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = ability:GetCursorPosition()
	
	AddFOWViewer(caster:GetTeam(), point, ability:GetLevelSpecialValueFor("vision_radius", (ability:GetLevel() -1)), ability:GetLevelSpecialValueFor("vision_duration", (ability:GetLevel() -1)), false)
end

function SendMissiles(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local homing_missile_arena = caster:FindAbilityByName("homing_missile_arena")
	if target:IsHero() and homing_missile_arena and homing_missile_arena:GetLevel() > 0 then
		caster:SetCursorCastTarget(target)
		homing_missile_arena:OnSpellStart()
	end
	if keys.DamageScepter and caster:HasScepter() then
		ApplyDamage({victim = target, attacker = caster, damage = keys.DamageScepter, damage_type = ability:GetAbilityDamageType(), ability = ability})
	elseif keys.Damage then
		ApplyDamage({victim = target, attacker = caster, damage = keys.Damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
	end
end