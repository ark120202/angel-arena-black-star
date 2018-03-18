require("util/string")

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

function CDOTA_Buff:StoreAbilitySpecials(specials)
	local ability = self:GetAbility()
	self.specials = {}
	for _,v in ipairs(specials) do
		self.specials[v] = ability:GetSpecialValueFor(v)
	end
end

function CDOTA_Buff:GetSpecialValueFor(name)
	return self.specials[name]
end

function DeclarePassiveAbility(name, modifier)
	_G[name] = { GetIntrinsicModifierName = function() return modifier end }
end
