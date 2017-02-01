function CEntityInstance:GetNetworkableEntityInfo(key)
	local t = CustomNetTables:GetTableValue("custom_entity_values", tostring(self:GetEntityIndex())) or {}
	return t[key]
end

function CDOTA_Buff:GetSharedKey(key)
	return CustomNetTables:GetTableValue("shared_modifiers", self:GetParent():GetEntityIndex() .. "_" .. self:GetName())
end