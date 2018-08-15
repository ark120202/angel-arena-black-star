function ArenaZoneOnStartTouch(trigger)
	local activator = trigger.activator
	if not IsValidEntity(activator) then return end

	if Duel:IsDuelOngoing() then
		HEROES_ON_DUEL[activator] = true
		return
	end

	local caller = trigger.caller
	local origin = caller:GetAbsOrigin()
	local min = origin + ExpandVector(caller:GetBoundingMins(), 96)
	local max = origin + ExpandVector(caller:GetBoundingMaxs(), 96)
	local clamped = VectorOnBoxPerimeter(activator:GetAbsOrigin(), min, max)
	FindClearSpaceForUnit(activator, clamped, true)
end

function ArenaZoneOnEndTouch(trigger)
	local activator = trigger.activator
	if not IsValidEntity(activator) then return end
	HEROES_ON_DUEL[activator] = nil

	if not activator.OnDuel then return end
	if activator:IsWukongsSummon() then return end

	Timers:CreateTimer(function()
		if not IsValidEntity(activator) then return end
		if not Duel:IsDuelOngoing() then return end

		-- Teleports are also triggering OnEndTouch event
		if HEROES_ON_DUEL[activator] then return end

		local caller = trigger.caller
		local origin = caller:GetAbsOrigin()
		local min = origin + ExpandVector(caller:GetBoundingMins(), -96)
		local max = origin + ExpandVector(caller:GetBoundingMaxs(), -96)
		local clamped = VectorOnBoxPerimeter(activator:GetAbsOrigin(), min, max)
		activator:Teleport(clamped)
	end)
end

local OUT_OF_GAME_UNITS = {
	[""] = true,
	npc_dota_thinker = true,
	npc_dummy_unit = true,
	npc_dota_looping_sound = true,
	npc_dota_invisible_vision_source = true,
}
function FountainOnStartTouch(trigger, team)
	local unit = trigger.activator
	if unit and unit:GetTeam() == team then
		unit:AddNewModifier(unit, nil, "modifier_fountain_aura_arena", nil)
	elseif not unit:IsBoss() then
		local unitName = unit:GetUnitName()
		if not OUT_OF_GAME_UNITS[unitName] and not unit:IsWukongsSummon() then
			unit:AddNewModifier(unit, nil, "modifier_fountain_aura_enemy", {team = team})
		end
	end
end
function Fountain2OnStartTouch(trigger)
	FountainOnStartTouch(trigger, DOTA_TEAM_GOODGUYS)
end
function Fountain3OnStartTouch(trigger)
	FountainOnStartTouch(trigger, DOTA_TEAM_BADGUYS)
end
function Fountain6OnStartTouch(trigger)
	FountainOnStartTouch(trigger, DOTA_TEAM_CUSTOM_1)
end
function Fountain7OnStartTouch(trigger)
	FountainOnStartTouch(trigger, DOTA_TEAM_CUSTOM_2)
end

function FountainOnEndTouch(trigger)
	local activator = trigger.activator
	if activator then
		activator:RemoveModifierByName("modifier_fountain_aura_arena")
		activator:RemoveModifierByName("modifier_fountain_aura_enemy")
	end
end

-- TODO remove these team numbers
function Fountain2OnEndTouch(trigger)
	FountainOnEndTouch(trigger)
end
function Fountain3OnEndTouch(trigger)
	FountainOnEndTouch(trigger)
end
function Fountain6OnEndTouch(trigger)
	FountainOnEndTouch(trigger)
end
function Fountain7OnEndTouch(trigger)
	FountainOnEndTouch(trigger)
end
