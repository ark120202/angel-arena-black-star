function BurnedRiverZoneOnStartTouch(trigger)
	table.insert(Heroes_In_BurnedRiver_Zone, trigger.activator)
	if IS_RIVER_BURNED then
		trigger.activator:Kill(nil, nil)
	end
end

function BurnedRiverZoneOnEndTouch(trigger)
	table.removeByValue(Heroes_In_BurnedRiver_Zone, trigger.activator)
	if IS_RIVER_BURNED then
		trigger.activator:Kill(nil, nil)
	end
end

function ArenaZoneOnStartTouch(trigger)
	if Duel.DuelStatus == DOTA_DUEL_STATUS_IN_PROGRESS then
		table.insert(Heroes_In_Arena_Zone, trigger.activator)
	end
end

function ArenaZoneOnEndTouch(trigger)
	table.removeByValue(Heroes_In_Arena_Zone, trigger.activator)
	if trigger.activator and Duel.DuelStatus == DOTA_DUEL_STATUS_IN_PROGRESS then
		Timers:CreateTimer(function()
			if not table.contains(Heroes_In_Arena_Zone, trigger.activator) and Duel.DuelStatus == DOTA_DUEL_STATUS_IN_PROGRESS then
				trigger.activator:InterruptMotionControllers(true)
				FindClearSpaceForUnit(trigger.activator, Entities:FindByName(nil, "target_mark_arena_team" .. trigger.activator:GetTeamNumber()):GetAbsOrigin(), false)
			end
		end)
	end
end

function ShopZoneOnStartTouch(trigger)
	table.insert(Heroes_In_Shop_Zone, trigger.activator)
end

function ShopZoneOnEndTouch(trigger)
	table.removeByValue(Heroes_In_Shop_Zone, trigger.activator)
end