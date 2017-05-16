function EatTrees(keys)
	local caster = keys.caster
	local point = keys.target_points[1]
	local ability = keys.ability
	local trees = #GridNav:GetAllTreesAroundPoint(point, keys.aoe, true)
	for _,v in ipairs(GridNav:GetAllTreesAroundPoint(point, keys.aoe, true)) do
		v:EmitSound("DOTA_Item.Tango.Activate")
	end
	GridNav:DestroyTreesAroundPoint(point, keys.aoe, true)

	local wards = FindUnitsInRadius(caster:GetTeamNumber(), point, nil, keys.aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	for _,v in ipairs(wards) do
		if v:IsCustomWard() then
			v:TrueKill(ability, caster)
			trees = trees + keys.stacks_per_ward
		end
	end
	if trees > 0 then
		ModifyStacks(ability, caster, caster, "modifier_item_tango_arena", trees, true)
		Timers:CreateTimer(ability:GetAbilitySpecial("buff_duration"), function()
			if IsValidEntity(caster) and IsValidEntity(ability) then
				ModifyStacks(ability, caster, caster, "modifier_item_tango_arena", -trees)
			end
		end)
	end
end