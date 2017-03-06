function ChangeTeam(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:IsTrueHero() or Duel:IsDuelOngoing() then
		return
	end
	--TODO Меню для смены в 4v4v4v4
	local oldTeam = caster:GetTeamNumber()
	local newTeam = oldTeam == DOTA_TEAM_BADGUYS and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS
	if GetTeamPlayerCount(targetTeam) >= GetTeamPlayerCount(oldTeam) and not IsInToolsMode() then
		return
	end
	PlayerResource:SetPlayerTeam(caster:GetPlayerID(), newTeam)
	FindClearSpaceForUnit(caster, FindFountain(newTeam):GetAbsOrigin(), true)
	
	SpendCharge(ability, 1)
end

function OnAttacked(keys)
	local ability = keys.ability
	local attacker = keys.attacker
	if attacker then
		local attacker_name = attacker:GetUnitName()
		if keys.Damage > 0 and ((attacker.IsControllableByAnyPlayer and attacker:IsControllableByAnyPlayer()) or attacker:IsBoss()) then
			ability:StartCooldown(ability:GetLevelSpecialValueFor("attacked_cooldown", ability:GetLevel() - 1))
		end
	end
end