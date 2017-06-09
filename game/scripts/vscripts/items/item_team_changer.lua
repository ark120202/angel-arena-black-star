function ChangeTeam(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:IsTrueHero() or Duel:IsDuelOngoing() or Options:IsEquals("EnableRatingAffection") then
		return
	end
	local oldTeam = caster:GetTeamNumber()
	local newTeam = oldTeam == DOTA_TEAM_BADGUYS and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS
	if GetTeamPlayerCount(newTeam) >= GetTeamPlayerCount(oldTeam) and not IsInToolsMode() then
		Containers:DisplayError(caster:GetPlayerID(), "#arena_hud_error_team_changer_players")
		return
	end

	GameRules:SetCustomGameTeamMaxPlayers(newTeam, GameRules:GetCustomGameTeamMaxPlayers(newTeam) + 1)
	PlayerResource:SetPlayerTeam(caster:GetPlayerID(), newTeam)
	GameRules:SetCustomGameTeamMaxPlayers(oldTeam, GameRules:GetCustomGameTeamMaxPlayers(oldTeam) - 1)

	FindClearSpaceForUnit(caster, FindFountain(newTeam):GetAbsOrigin(), true)

	ability:SpendCharge()
end

function OnAttacked(keys)
	local ability = keys.ability
	local attacker = keys.attacker
	if attacker then
		if keys.Damage > 0 and ((attacker.IsControllableByAnyPlayer and attacker:IsControllableByAnyPlayer()) or attacker:IsBoss()) then
			ability:StartCooldown(ability:GetLevelSpecialValueFor("attacked_cooldown", ability:GetLevel() - 1))
		end
	end
end
