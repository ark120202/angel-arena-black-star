if not DynamicMinimap then
	_G.DynamicMinimap = class({})
	DynamicMinimap.MinimapPoints = {}
	DynamicMinimap.NextID = 0
end

function DynamicMinimap:Init()
	for team = DOTA_TEAM_FIRST, DOTA_TEAM_CUSTOM_MAX do
		PlayerTables:CreateTable("dynamic_minimap_points_" .. team, {}, GetPlayersInTeam(team))
	end
end

function DynamicMinimap:UpdateTable()
	for team = DOTA_TEAM_FIRST, DOTA_TEAM_CUSTOM_MAX do
		local a = {}
		for i,_ in pairs(DynamicMinimap.MinimapPoints) do
			a[i] = DynamicMinimap:GetClientsideInfo(i, team)
		end
		PlayerTables:SetTableValues("dynamic_minimap_points_" .. team, a)
	end
end


--CanEntityBeSeenByMyTeam(handle hEntity)

function DynamicMinimap:CreateMinimapPoint(origin, styleClasses)
	local t = {
		origin = origin,
		styleClasses = styleClasses,
		id = DynamicMinimap.NextID,
		visible = true,
	}
	DynamicMinimap.MinimapPoints[t.id] = t
	DynamicMinimap:UpdateTable()
	DynamicMinimap.NextID = DynamicMinimap.NextID + 1
	return t.id
end

function DynamicMinimap:Destroy(pointIndex)
	DynamicMinimap.MinimapPoints[pointIndex] = nil
	DynamicMinimap:UpdateTable()
end

function DynamicMinimap:SetAbsOrigin(pointIndex, origin)
	DynamicMinimap.MinimapPoints[pointIndex].origin = origin
	DynamicMinimap:UpdateTable()
end

function DynamicMinimap:GetAbsOrigin(pointIndex)
	return DynamicMinimap.MinimapPoints[pointIndex].origin
end

function DynamicMinimap:GetClientsideInfo(pointIndex, team)
	local pointData = DynamicMinimap.MinimapPoints[pointIndex]
	return {
		position = WorldPosToMinimap(pointData.origin),
		styleClasses = pointData.styleClasses,
		visible = DynamicMinimap:IsVisible(pointIndex, team)
	}
end

function DynamicMinimap:SetVisibleGlobal(pointIndex, state)
	DynamicMinimap.MinimapPoints[pointIndex].visible = state
	DynamicMinimap:UpdateTable()
end

function DynamicMinimap:IsVisible(pointIndex, team)
	return DynamicMinimap.MinimapPoints[pointIndex].visible
end
