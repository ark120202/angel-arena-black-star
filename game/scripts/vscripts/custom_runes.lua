if not CustomRunes then
	CustomRunes = class({})
end
function CustomRunes:Init()
	for _,v in ipairs(Entities:FindAllByName("dota_item_rune_spawner")) do
		DynamicMinimap:CreateMinimapPoint(v:GetAbsOrigin(), "icon_rune")
	end
end