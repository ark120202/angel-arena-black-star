function ConjureImage(keys)
	local caster = keys.caster
	local ability = keys.ability
	local original_hero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerID())

	if original_hero then
		local original_ability = original_hero:FindAbilityByName(ability:GetAbilityName())
		if original_ability then
			local target = keys.target
			local proc_chance = ability:GetLevelSpecialValueFor(is_illusion and "illusion_proc_chance" or "hero_proc_chance", ability:GetLevel() - 1)
			local duration = ability:GetLevelSpecialValueFor(is_illusion and "duration_from_illusion" or "illusion_duration", ability:GetLevel() - 1)
			local is_illusion = caster:IsIllusion()
			if not original_ability.illusions then original_ability.illusions = 0 end
			if not target:IsBoss() and RollPercentage(proc_chance) and original_ability.illusions < ability:GetLevelSpecialValueFor("max_illusions", ability:GetLevel() - 1) and original_ability:PreformPrecastActions() then
				original_ability.illusions = original_ability.illusions + 1
				local illusion = Illusions:create({
					unit = caster,
					ability = original_ability,
					origin = target:GetAbsOrigin() + RandomVector(100),
					damageIncoming = ability:GetSpecialValueFor("illusion_incoming_damage"),
					damageOutgoing = ability:GetSpecialValueFor("illusion_outgoing_damage"),
					duration = duration
				})
				ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_phantom_lancer_juxtapose_arena_illusion_count", nil)
				ExecuteOrderFromTable({
					UnitIndex = illusion:GetEntityIndex(),
					OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
					Position = illusion:GetAbsOrigin(),
				})
			end
		end
	end
end

function DecreaseCount(keys)
	local caster = keys.caster
	local ability = keys.ability
	local original_hero = PlayerResource:GetSelectedHeroEntity(caster:GetPlayerID())
	if original_hero then
		local original_ability = original_hero:FindAbilityByName("phantom_lancer_juxtapose_arena")
		if original_ability then
			original_ability.illusions = original_ability.illusions - 1
		end
	end
end

function ScepterEffectCreated(keys)
	local target = keys.target
	local ability = keys.ability

	if target:IsIllusion() and keys.caster:GetPlayerOwner() == target:GetPlayerOwner() then
		for _,v in ipairs(target:FindAllModifiersByName("modifier_illusion")) do
			v.OldDuration = v:GetRemainingTime()
			v:SetDuration(-1, true)
		end
	end
end

function ScepterEffectDestroy(keys)
	local target = keys.target
	local ability = keys.ability

	if target:IsIllusion() and keys.caster:GetPlayerOwner() == target:GetPlayerOwner() then
		for _,v in ipairs(target:FindAllModifiersByName("modifier_illusion")) do
			v:SetDuration(v.OldDuration or 0, true)
		end
	end
end
