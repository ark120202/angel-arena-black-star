function CreateSoul(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	if not target:IsHero() and
		not target:IsCourier() and
		target:GetTeamNumber() ~= caster:GetTeamNumber() and
		not target:IsBoss() and
		not target:IsChampion() and
		not target:IsBuilding() then

		local soul = CreateUnitByName("npc_shinobu_soul", target:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_NEUTRALS)
		soul:SetModel(target:GetModelName())
		soul:SetOriginalModel(target:GetModelName())
		soul:SetModelScale(target:GetModelScale())
		soul:FindAbilityByName("shinobu_soul_unit"):SetLevel(1)
		soul:SetBaseMaxHealth(target:GetMaxHealth())
		soul:SetMaxHealth(target:GetMaxHealth())
		soul:SetHealth(target:GetMaxHealth())
		soul:SetBaseDamageMin(target:GetBaseDamageMin())
		soul:SetBaseDamageMax(target:GetBaseDamageMax())
		soul:SetBaseAttackTime(target:GetBaseAttackTime())
		soul:SetAttackCapability(target:GetAttackCapability())
		if target:GetLevel() > 1 then
			soul:CreatureLevelUp(target:GetLevel() - 1)
		end
		soul.SpawnTime = GameRules:GetGameTime()
		soul.DeathTime = GameRules:GetGameTime() + ability:GetAbilitySpecial("soul_duration")
	end
end

function ChanceToKill(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if not target:IsConsideredHero() and not target:IsMagicImmune() and not target:IsInvulnerable() and RollPercentage(ability:GetAbilitySpecial("chance_to_kill")) then
		target:Kill(ability, caster)
	end
end

function UpdateHealthTimer(keys)
	local caster = keys.caster
	if caster:IsAlive() then
		if GameRules:GetGameTime() > caster.DeathTime then
			caster:ForceKill(false)
		else
			caster:SetHealth(math.max(caster:GetMaxHealth() * (caster.DeathTime - GameRules:GetGameTime())/(caster.DeathTime - caster.SpawnTime), 1))
		end
	end
end
