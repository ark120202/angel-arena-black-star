item_boss_control = class({})

if IsClient() then
	function IsBossEntity(unit)
		return string.find(unit:GetUnitName(), "npc_arena_boss_")
	end
end

function item_boss_control:OnSpellStart() if IsServer() then
	local hTarget = self:GetCursorTarget()
	if IsBossEntity(hTarget) then
		if PLAYER_DATA[self:GetCaster():GetPlayerID()].DominatedBoss then
			PLAYER_DATA[self:GetCaster():GetPlayerID()].DominatedBoss:ForceKill(false)
		end
		local new_boss = CreateUnitByName(hTarget:GetUnitName(), hTarget:GetAbsOrigin(), true, nil, nil, self:GetCaster():GetTeamNumber())
		new_boss:SetHealth(hTarget:GetHealth())
		hTarget:ForceKill(false)
		new_boss:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
		new_boss:SetOwner(self:GetCaster())
		new_boss.IsDominatedBoss = true
		PLAYER_DATA[self:GetCaster():GetPlayerID()].DominatedBoss = new_boss
		UTIL_Remove(self)
	end
end end

function item_boss_control:CastFilterResultTarget(hTarget)
	local nResult = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, self:GetCaster():GetTeamNumber())
	if nResult ~= UF_SUCCESS then
		return nResult
	end
	if not IsBossEntity(hTarget) then
		return UF_FAIL_CUSTOM
	end
 
	return UF_SUCCESS
end
 
function item_boss_control:GetCustomCastErrorTarget(hTarget)
	if not IsBossEntity(hTarget) then
		return "#dota_hud_error_cant_cast_on_other"
	end
	return ""
end