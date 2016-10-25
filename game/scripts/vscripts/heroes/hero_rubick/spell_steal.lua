--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Ensures the target has cast a spell]]
function SpellCheck(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ability.new_steal_target = target
	ProjectileManager:CreateTrackingProjectile( {
		Target = caster,
		Source = target,
		Ability = ability,
		EffectName = keys.particle,
		bDodgeable = false,
		bProvidesVision = false,
		iMoveSpeed = ability:GetAbilitySpecial("projectile_speed"),
		iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
	} )
end

--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Swaps rubick's spells]]
function SpellSteal(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = ability.new_steal_target
	if caster:HasModifier("modifier_spell_steal_datadriven") then
		caster:RemoveModifierByName("modifier_spell_steal_datadriven")
	end
	ability.stolen_abilities = {}
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_spell_steal_datadriven", {})
	for i = 0, target:GetAbilityCount() - 1 do
		local a = target:GetAbilityByIndex(i)
		caster:AddAbility(a:GetAbilityName()):SetLevel(a:GetLevel() - 1)
		ability.stolen_abilities:insert(a)
	end
end

--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Swaps the stolen spell with the empty spell]]
function RemoveSpell(keys)
	local caster = keys.caster
	local ability = keys.ability
	local new_ability_name = ability.current_steal:GetAbilityName()
	
	caster:SwapAbilities(new_ability_name, "empty1_datadriven", false, true)
	--caster:RemoveAbility(new_ability_name)
end

--[[Author: YOLOSPAGHETTI
	Date: July 11, 2016
	Since you can still level up stolen spells, they automatically readjust to the level when stolen]]
function FixLevels(keys)
	local caster = keys.caster
	local ability = keys.ability
	
	local current_ability = caster:FindAbilityByName(ability.current_steal:GetAbilityName())
	local correct_ability_level = ability.current_steal:GetLevel() - 1
	local current_ability_points = caster:GetAbilityPoints()
	
	-- Checks if the current stolen ability's level is higher than it should be
	if current_ability:GetLevel() > correct_ability_level then
		-- Counts how many levels have been added
		local levels_higher = current_ability:GetLevel() - correct_ability_level
		-- Sets the ability to the correct level
		current_ability:SetLevel(correct_ability_level)
		-- Gives the caster back the unused ability points
		caster:SetAbilityPoints(levels_higher + current_ability_points)
	end
end