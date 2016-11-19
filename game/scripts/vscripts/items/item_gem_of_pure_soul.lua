function CreateCooldownsWorldpanel(keys)
	local caster = keys.caster
	local target = keys.target
	if caster:IsRealHero() then
		target.GemOfPureSoulCooldownsWorldpanel = WorldPanels:CreateWorldPanelForTeam(caster:GetTeamNumber(), {
			layout = "file://{resources}/layout/custom_game/worldpanels/abilitycooldowns.xml",
			entity = target,
			entityHeight = 210,
			data = {hasHealthBar = not target:NoHealthBar()}
		})
	end
end

function RemoveCooldownsWorldpanel(keys)
	local target = keys.target
	if target.GemOfPureSoulCooldownsWorldpanel then
		target.GemOfPureSoulCooldownsWorldpanel:Delete()
		target.GemOfPureSoulCooldownsWorldpanel = nil
	end
end