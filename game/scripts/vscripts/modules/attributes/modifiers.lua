require("modules/attributes/data")

local function createModifier(property, getter, step)
	local t = {
		IsHidden         = function() return true end,
		IsPurgable       = function() return false end,
		IsPermanent      = function() return true end,
		DestroyOnExpire  = function() return false end,
		GetAttributes    = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
		DeclareFunctions = function() return { property } end,
		[getter]         = function(self) return self:GetStackCount() * step end,
	}

	return class(t)
end

for propName, propValue in pairs(DOTA_DEFAULT_ATTRIBUTES) do
	if propValue.recalculate == nil and propValue.property then
		local modifierName = propValue.modifier or ("modifier_attribute_" .. propName)
		_G[modifierName] = createModifier(propValue.property, propValue.getter, propValue.step or 1)
	end
end
