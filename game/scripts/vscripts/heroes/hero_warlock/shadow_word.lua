function SpawnMinigolem(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local golem = CreateUnitByName("npc_dota_warlock_minigolem", target:GetAbsOrigin(), true, caster, nil, caster:GetTeamNumber())
	golem:AddNewModifier(caster, ability, "modifier_kill", {duration = ability:GetLevelSpecialValueFor("minigolem_duration", ability:GetLevel() - 1)})
	--golem:SetControllableByPlayer(caster:GetPlayerID(), true)
	golem:SetOwner(caster)
	golem:SetAttacking(target)
end

function OnSpellStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	caster:EmitSound("Hero_Warlock.ShadowWordCastGood")
	if target == caster then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_shadow_word_self", {})
	else
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_shadow_word_self_secondary", {})
		if target:GetTeamNumber() == caster:GetTeamNumber() then
			ability:ApplyDataDrivenModifier(caster, target, "modifier_shadow_word_buff", {})
			target:EmitSound("Hero_Warlock.ShadowWordCastGood")
		else
			ability:ApplyDataDrivenModifier(caster, target, "modifier_shadow_word_debuff", {})
			target:EmitSound("Hero_Warlock.ShadowWordCastBad")
		end
	end
end