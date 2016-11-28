function SpellCheck(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if PERSONALITY_STEAL_BANNED_HEROES[GetFullHeroName(target)] then
		ability:EndCooldown()
		ability:RefundManaCost()
		Containers:DisplayError(caster:GetPlayerID(), "#dota_hud_error_cant_steal_spell")
	else
		caster:EmitSound("Hero_Rubick.SpellSteal.Cast")
		target:EmitSound("Hero_Rubick.SpellSteal.Target")
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
end

function SpellSteal(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = ability.new_steal_target
	if caster:HasModifier("modifier_rubick_personality_steal") then
		ability:EndCooldown()
		ability:RefundManaCost()
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
		local precacheArray = {}
		for i = 0, target:GetAbilityCount() - 1 do
			local a = target:GetAbilityByIndex(i)
			if a and a:GetAbilityName() ~= "rubick_personality_steal" then
				local name = a:GetAbilityName()
				precacheArray[name] = false
				PrecacheItemByNameAsync(name, function()
					precacheArray[name] = true
					caster:AddAbility(name)
					CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(caster:GetPlayerID()), "dota_ability_changed", {})
				end)
			end
		end
		caster:CalculateStatBonus()
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
		CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(caster:GetPlayerID()), "dota_ability_changed", {})
	end
	local newlevel = caster.rubick_spell_steal.level
	Timers:CreateTimer(0.1, function()
		PrecacheItemByNameAsync("rubick_personality_steal", function()
			local rubick_personality_steal = caster:AddAbility("rubick_personality_steal")
			rubick_personality_steal:SetLevel(newlevel)
			Timers:CreateTimer(0.2, function()
				caster:CalculateStatBonus()
				CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(caster:GetPlayerID()), "dota_ability_changed", {})
			end)
		end)
	end)
	caster:SetModel(caster.rubick_spell_steal.model)
	caster:SetOriginalModel(caster.rubick_spell_steal.model)
	caster:SetModelScale(caster.rubick_spell_steal.model_scale)
	caster.rubick_spell_steal = nil
	caster:SetAbilityPoints(caster:GetLevel())
end