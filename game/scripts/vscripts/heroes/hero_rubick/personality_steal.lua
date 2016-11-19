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

function SpellSteal(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = ability.new_steal_target
	if caster:HasModifier("modifier_rubick_personality_steal") then
		caster:RemoveModifierByName("modifier_rubick_personality_steal")
	end
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_rubick_personality_steal", {})
	caster.rubick_spell_steal = {
		level = ability:GetLevel(),
		model = caster:GetModelName(),
		model_scale = caster:GetModelScale()
	}
	UTIL_Remove(ability)
	for i = 0, caster:GetAbilityCount() - 1 do
		local a = caster:GetAbilityByIndex(i)
		if a then
			UTIL_Remove(a)
		end
	end
	local model = target:GetModelName()
	caster:SetModel(model)
	caster:SetOriginalModel(model)
	caster:SetModelScale(target:GetModelScale())
	Timers:CreateTimer(0.03, function()
		for i = 0, target:GetAbilityCount() - 1 do
			local a = target:GetAbilityByIndex(i)
			if a and a:GetAbilityName() ~= "rubick_personality_steal" then
				caster:AddAbility(a:GetAbilityName())
			end
		end
		caster:CalculateStatBonus()
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(caster:GetPlayerID()), "dota_ability_changed", {})
	end)
	caster:SetAbilityPoints(caster:GetLevel())
end

function RemoveSpell(keys)
	local caster = keys.caster
	for i = 0, caster:GetAbilityCount() - 1 do
		local a = caster:GetAbilityByIndex(i)
		if a then
			RemoveAbilityWithModifiers(caster, a)
		end
	end
	local newlevel = caster.rubick_spell_steal.level
	Timers:CreateTimer(0.03, function()
		caster:AddAbility("rubick_personality_steal"):SetLevel(newlevel)
		caster:CalculateStatBonus()
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(caster:GetPlayerID()), "dota_ability_changed", {})
	end)
	caster:SetModel(caster.rubick_spell_steal.model)
	caster:SetOriginalModel(caster.rubick_spell_steal.model)
	caster:SetModelScale(caster.rubick_spell_steal.model_scale)
	caster.rubick_spell_steal = nil
	caster:SetAbilityPoints(caster:GetLevel())
end