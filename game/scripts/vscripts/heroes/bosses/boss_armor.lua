function Init(keys)
	local caster = keys.caster
	local ability = keys.ability

	for i = 0, caster:GetAbilityCount() - 1 do
		local skill = caster:GetAbilityByIndex(i)
		if skill then
			skill:SetLevel(skill:GetMaxLevel())
		end
	end
end

function ClearDebuffs(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:Purge(false, true, false, false, false)
	caster:RemoveModifierByName("modifier_item_skadi_slow")
	caster:RemoveModifierByName("modifier_item_skadi_arena_cold_attack")
	caster:RemoveModifierByName("modifier_item_rapier_of_pain_debuff")
	caster:RemoveModifierByName("modifier_ursa_fury_swipes_damage_increase")
	caster:RemoveModifierByName("modifier_maledict")
	caster:RemoveModifierByName("modifier_ice_blast")

	local modifier_razor_eye_of_the_storm_armor = caster:FindModifierByName("modifier_razor_eye_of_the_storm_armor")
	if modifier_razor_eye_of_the_storm_armor and modifier_razor_eye_of_the_storm_armor:GetStackCount() > 50 then
		modifier_razor_eye_of_the_storm_armor:SetStackCount(50)
	end
end

function OnTakeDamage(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local ability = keys.ability
	attacker:RemoveModifierByName("modifier_smoke_of_deceit")
	if attacker:IsIllusion() then
		attacker:TrueKill(ability, caster)
	end

	attacker:AddNewModifier(caster, ability, "modifier_max_attack_range", {AttackRange = ability:GetAbilitySpecial("attack_range_limit"), duration = 3})
end
