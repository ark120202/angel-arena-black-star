function ChangeTeam(keys)
	local caster = keys.caster
	local ability = keys.ability
	local playerId = caster:GetPlayerID()
	if not caster:IsTrueHero() or Duel:IsDuelOngoing() or Options:IsEquals("EnableRatingAffection") then
		return
	end
	local oldTeam = caster:GetTeamNumber()
	local newTeam = oldTeam == DOTA_TEAM_BADGUYS and DOTA_TEAM_GOODGUYS or DOTA_TEAM_BADGUYS
	if GetTeamPlayerCount(newTeam) >= GetTeamPlayerCount(oldTeam) and not IsInToolsMode() then
		Containers:DisplayError(playerId, "#arena_hud_error_team_changer_players")
		return
	end

	GameRules:SetCustomGameTeamMaxPlayers(newTeam, GameRules:GetCustomGameTeamMaxPlayers(newTeam) + 1)
	PlayerResource:SetPlayerTeam(playerId, newTeam)
	GameRules:SetCustomGameTeamMaxPlayers(oldTeam, GameRules:GetCustomGameTeamMaxPlayers(oldTeam) - 1)

	FindClearSpaceForUnit(caster, FindFountain(newTeam):GetAbsOrigin(), true)
	local courier = Structures:GetCourier(playerId)
	FindClearSpaceForUnit(courier, caster:GetAbsOrigin() + RandomVector(150), true)

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
