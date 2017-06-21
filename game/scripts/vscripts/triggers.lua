function ArenaZoneOnStartTouch(trigger)
	if Duel.DuelStatus == DOTA_DUEL_STATUS_IN_PROGRESS then
		table.insert(Heroes_In_Arena_Zone, trigger.activator)
	end
end

function ArenaZoneOnEndTouch(trigger)
	table.removeByValue(Heroes_In_Arena_Zone, trigger.activator)
	local activator = trigger.activator
	if activator and Duel.DuelStatus == DOTA_DUEL_STATUS_IN_PROGRESS and (not activator.IsWukongsSummon or not activator:IsWukongsSummon()) then
		Timers:CreateTimer(function()
			if IsValidEntity(activator) and not table.contains(Heroes_In_Arena_Zone, activator) and Duel.DuelStatus == DOTA_DUEL_STATUS_IN_PROGRESS and activator.OnDuel then
				activator:InterruptMotionControllers(true)
				FindClearSpaceForUnit(activator, Entities:FindByName(nil, "target_mark_arena_team" .. activator:GetTeamNumber()):GetAbsOrigin(), false)
				if activator:HasModifier("modifier_spirits_spirit_aghanims") then
					return 1/30
				end
			end
		end)
	end
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
		if not OUT_OF_GAME_UNITS[unitName] then
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

-- TODO remove these team numbers
function Fountain2OnEndTouch(trigger)
	trigger.activator:RemoveModifierByName("modifier_fountain_aura_arena")
	trigger.activator:RemoveModifierByName("modifier_fountain_aura_enemy")
end
function Fountain3OnEndTouch(trigger)
	trigger.activator:RemoveModifierByName("modifier_fountain_aura_arena")
	trigger.activator:RemoveModifierByName("modifier_fountain_aura_enemy")
end
function Fountain6OnEndTouch(trigger)
	trigger.activator:RemoveModifierByName("modifier_fountain_aura_arena")
	trigger.activator:RemoveModifierByName("modifier_fountain_aura_enemy")
end
function Fountain7OnEndTouch(trigger)
	trigger.activator:RemoveModifierByName("modifier_fountain_aura_arena")
	trigger.activator:RemoveModifierByName("modifier_fountain_aura_enemy")
end
