require("utils/string")

function CEntityInstance:GetNetworkableEntityInfo(key)
	local t = CustomNetTables:GetTableValue("custom_entity_values", tostring(self:GetEntityIndex())) or {}
	return t[key]
end

function CDOTA_Buff:GetSharedKey(key)
	local t = CustomNetTables:GetTableValue("shared_modifiers", self:GetParent():GetEntityIndex() .. "_" .. self:GetName()) or {}
	return t[key]
end

function CEntityInstance:IsCustomWard()
	if not self.GetUnitName then return false end
	local n = self:GetUnitName()
	return n == "npc_dota_sentry_wards" or n == "npc_dota_observer_wards" or string.starts(n, "npc_arena_ward_")
end