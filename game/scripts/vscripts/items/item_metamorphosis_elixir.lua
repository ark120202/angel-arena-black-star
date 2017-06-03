function Transform( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_shredder_chakram_disarm") then return end
	local playerID = caster:GetPlayerID()
	if Options:IsEquals("EnableRatingAffection", false) or PlayerResource:GetPlayerStat(playerID, "ChangedHeroAmount") == 0 then
		CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "metamorphosis_elixir_show_menu", {})
	else
		Containers:DisplayError(playerID, "arena_hud_error_metamorphosis_elixir_ranked")
	end
end
