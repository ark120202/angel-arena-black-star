function Transform( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster:HasModifier("modifier_shredder_chakram_disarm") then
		return
	end
	CustomGameEventManager:Send_ServerToPlayer(caster:GetPlayerOwner(), "hell_hero_change_show_menu", {})
end