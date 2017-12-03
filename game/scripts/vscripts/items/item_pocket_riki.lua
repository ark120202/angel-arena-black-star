--[[Author: YOLOSPAGHETTI
	Date: February 4, 2016
	Checks if Riki is behind his target
	Borrows heavily from bristleback.lua]]

function CheckBackstab(params)
	local attacker = params.attacker
	local ability = params.ability
	local stat_damage_multiplier = ability:GetSpecialValueFor("stat_damage") / 100

	local statId = attacker:GetPrimaryAttribute()
	local damage
	if statId == 0 then
		damage = attacker:GetStrength() * stat_damage_multiplier
	elseif statId == 1 then
		damage = attacker:GetAgility() * stat_damage_multiplier
	else
		damage = attacker:GetIntellect() * stat_damage_multiplier
	end

	local victim_angle = params.target:GetAnglesAsVector().y
	local origin_difference = params.target:GetAbsOrigin() - attacker:GetAbsOrigin()
	local origin_difference_radian = math.atan2(origin_difference.y, origin_difference.x)
	origin_difference_radian = origin_difference_radian * 180
	local attacker_angle = origin_difference_radian / math.pi
	attacker_angle = attacker_angle + 180.0
	local result_angle = attacker_angle - victim_angle
	result_angle = math.abs(result_angle)

	-- Check for the backstab angle.
	if result_angle >= (180 - (ability:GetSpecialValueFor("backstab_angle") / 2)) and result_angle <= (180 + (ability:GetSpecialValueFor("backstab_angle") / 2)) then
		EmitSoundOn(params.sound, params.target)
		local particle = ParticleManager:CreateParticle(params.particle, PATTACH_ABSORIGIN_FOLLOW, params.target)
		ParticleManager:SetParticleControlEnt(particle, 1, params.target, PATTACH_POINT_FOLLOW, "attach_hitloc", params.target:GetAbsOrigin(), true)
		ApplyDamage({victim = params.target, attacker = attacker, damage = damage, damage_type = ability:GetAbilityDamageType(), ability = ability})
	end
end

function ConsumeRiki(keys)
	local caster = keys.caster
	local ability = keys.ability
	local riki = ability.RikiContainer
	local buffsTime = riki:CalculateRespawnTime()
	local newItem = CreateItem("item_pocket_riki_consumed", caster, caster)

	riki:TrueKill(ability, riki)
	swap_to_item(caster, ability, newItem)
	caster:RemoveModifierByName("modifier_item_pocket_riki_invisibility_fade")
	caster:RemoveModifierByName("modifier_item_pocket_riki_permanent_invisibility")
	caster:RemoveModifierByName("modifier_invisible")

	newItem:ApplyDataDrivenModifier(caster, caster, "modifier_item_pocket_riki_consumed_str", {duration=buffsTime})
	ModifyStacks(newItem, caster, caster, "modifier_item_pocket_riki_consumed_str", riki:GetStrength(), true)
	newItem:ApplyDataDrivenModifier(caster, caster, "modifier_item_pocket_riki_consumed_agi", {duration=buffsTime})
	ModifyStacks(newItem, caster, caster, "modifier_item_pocket_riki_consumed_agi", riki:GetAgility(), true)
	newItem:ApplyDataDrivenModifier(caster, caster, "modifier_item_pocket_riki_consumed_int", {duration=buffsTime})
	ModifyStacks(newItem, caster, caster, "modifier_item_pocket_riki_consumed_int", riki:GetIntellect(), true)

	Timers:CreateTimer(buffsTime, function()
		UTIL_Remove(newItem)
		caster:RemoveModifierByName("modifier_item_pocket_riki_consumed_invisibility_fade")
		caster:RemoveModifierByName("modifier_item_pocket_riki_consumed_permanent_invisibility")
		caster:RemoveModifierByName("modifier_invisible")
	end)
end

function DropRiki(keys)
	local caster = keys.caster
	local ability = keys.ability
	ability.RikiContainer:RemoveModifierByName("modifier_pocket_riki_hide")
	UTIL_Remove(ability)
end
