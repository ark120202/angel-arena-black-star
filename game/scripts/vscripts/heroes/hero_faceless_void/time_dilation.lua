--[[Author: YOLOSPAGHETTI
	Date: February 7, 2016
	Adds time dilation duration to cooldown of all target's abilities currently on cooldown and applies debuff]]
function CooldownFreeze(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	ability.time_cast = GameRules:GetGameTime()
	
	local cooldown_time = ability:GetLevelSpecialValueFor("duration", ability_level)
	local frozen_abilities = 0
	for i=0, target:GetAbilityCount() - 1 do
		local skill = target:GetAbilityByIndex(i)
		if skill then
			local cd = skill:GetCooldownTimeRemaining()
			if cd > 0 then
				frozen_abilities = frozen_abilities + 1
				skill:StartCooldown(cd + cooldown_time)
			else
				skill:StartCooldown(ability:GetLevelSpecialValueFor("duration", ability_level))
			end
		end
	end
	if frozen_abilities > 0 then
		for i = 0, frozen_abilities do
			ability:ApplyDataDrivenModifier( caster, target, "modifier_faceless_void_time_dilation_arena_slow", { duration = cooldown_time } )
		end
	
		target:SetModifierStackCount("modifier_faceless_void_time_dilation_arena_freeze", caster, frozen_abilities)
	end
end

--[[Author: YOLOSPAGHETTI
	Date: February 7, 2016
	Adds remaining time dilation duration to cooldown of the ability the target cast and applies debuff]]
function SlowCooldown(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local cooldown_time = ability:GetLevelSpecialValueFor("duration", ability_level)
	local time_left = cooldown_time - (GameRules:GetGameTime() - ability.time_cast)
	local stacks = 0
	local is_ability
	
	if target:HasModifier("modifier_faceless_void_time_dilation_arena_slow") then
		stacks = target:GetModifierStackCount("modifier_faceless_void_time_dilation_arena_freeze", caster)
	end
	
	for i = 0, 15 do
		local cability = target:GetAbilityByIndex(i)
		if cability then
			local cd = cability:GetCooldownTimeRemaining()
			local full_cd = cability:GetReducedCooldown()
			if cd > 0 and  full_cd - cd > 0 and full_cd - cd < 0.04 then
				is_ability = true
				cability:StartCooldown(cd + time_left)
			end
		end
	end
	
	if is_ability then
		ability:ApplyDataDrivenModifier( caster, target, "modifier_faceless_void_time_dilation_arena_slow", { duration = time_left } )
		target:SetModifierStackCount("modifier_faceless_void_time_dilation_arena_freeze", caster, stacks + 1)
	end
end