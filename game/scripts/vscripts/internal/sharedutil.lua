function CEntityInstance:GetNetworkableEntityInfo(key)
	local t = CustomNetTables:GetTableValue("custom_entity_values", tostring(self:GetEntityIndex())) or {}
	return t[key]
end

--[[function CDota_Buff:GetSharedKey(key)
	local parent = self:GetParent()
	return CustomNetTables:GetTableValue("shared_modifiers", parent:GetEntityIndex() .. "_" .. self:GetName())
end]]