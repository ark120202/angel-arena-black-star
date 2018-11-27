modifier_cherub_flower_garden_tracker = class({})

function modifier_cherub_flower_garden_tracker:GetTexture()
	return "arena/cherub_flower_garden"
end

function modifier_cherub_flower_garden_tracker:IsHidden()
	return true
end

function modifier_cherub_flower_garden_tracker:IsPurgable()
	return false
end

if IsServer() then

	function modifier_cherub_flower_garden_tracker:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_DEATH,
		}
	end

	function modifier_cherub_flower_garden_tracker:OnDeath(keys)
		if self:GetParent() == keys.unit then
			local ability_name = keys.unit.ability_name
			if ability_name then
				if not PLAYER_DATA[keys.unit:GetPlayerOwnerID()].Cherub_Flower_Garden[ability_name] then PLAYER_DATA[keys.unit:GetPlayerOwnerID()].Cherub_Flower_Garden[ability_name] = {} end
				table.removeByValue(PLAYER_DATA[keys.unit:GetPlayerOwnerID()].Cherub_Flower_Garden[ability_name], keys.unit)
			end
			Timers:NextTick(function() UTIL_Remove(keys.unit) end)
		end
	end

end
