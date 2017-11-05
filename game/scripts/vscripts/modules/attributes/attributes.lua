ModuleRequire(..., "data")

for propName, propValue in pairs(DOTA_DEFAULT_ATTRIBUTES) do
	if propValue.recalculate == nil then
		ModuleLinkLuaModifier(..., "modifier_attribute_" .. propName, "modifiers")
	end
end

if not Attributes then
	Attributes = class({})
	Attributes.Applier = CreateItem("item_dummy", nil, nil)
end

function Attributes:SetPropValue(hero, prop, value)
	if not hero.attributes_adjustments then hero.attributes_adjustments = {} end
	local propValue = DOTA_DEFAULT_ATTRIBUTES[prop]
	if not propValue then error('Not found property named "' .. prop .. '"') end
	hero.attributes_adjustments[prop] = value - propValue.default
end

function Attributes:GetTotalPropValue(arg1, prop)
	local hero = type(arg1) == "table" and arg1
	local attributeValue = type(arg1) == "number" and arg1
	local propValue = DOTA_DEFAULT_ATTRIBUTES[prop]
	if not propValue then error('Not found property named "' .. prop .. '"') end

	if not attributeValue then
		attributeValue = hero:GetAttribute(propValue.attribute)
	end

	local adjustment = Attributes:GetAdjustmentForProp(hero, prop)
	local perPoint = adjustment + propValue.default
	return attributeValue * perPoint
end

function Attributes:GetAdjustmentForProp(hero, prop)
	if hero and hero.attributes_adjustments and hero.attributes_adjustments[prop] then
		return hero.attributes_adjustments[prop]
	end
	return GLOBAL_ATTRIBUTE_ADJUSTMENTS[prop] or 0
end

function Attributes:CheckAttributeModifier(hero, modifier)
	if not hero:HasModifier(modifier) then
		hero:AddNewModifier(hero, self.Applier, modifier, nil)
	end
end

function Attributes:CalculateStatBonus(hero)
	if not hero.attributeCache then hero.attributeCache = {} end
	local primaryAttribute = hero:GetPrimaryAttribute()
	local attributeValues = {
		[DOTA_ATTRIBUTE_STRENGTH] = hero:GetStrength(),
		[DOTA_ATTRIBUTE_AGILITY] = hero:GetAgility(),
		[DOTA_ATTRIBUTE_INTELLECT] = hero:GetIntellect(),
	}
	local recalculated = false

	for propName, propValue in pairs(DOTA_DEFAULT_ATTRIBUTES) do
		local attribute = propValue.attribute
		local attributeValue = attributeValues[attribute]
		-- Don't recalculate props, which attributes aren't changed since last check
		if hero.attributeCache[attribute] ~= attributeValue then
			recalculated = true
			if propValue.recalculate ~= nil then
				if propValue.recalculate then propValue.recalculate(hero, attributeValue) end
			elseif propValue.property then
				local modifierName = propValue.modifier or ("modifier_attribute_" .. propName)
				local adjustment = Attributes:GetAdjustmentForProp(hero, propName)
				self:CheckAttributeModifier(hero, modifierName)
				local wrongPerkAttribute = propValue.primary and propValue.attribute ~= primaryAttribute
				local stacks = wrongPerkAttribute and 0 or
					math.round((attributeValue * adjustment) / (propValue.stack or 1))
				hero:SetModifierStackCount(modifierName, hero, stacks)
			end
		end
	end

	hero.attributeCache = attributeValues
	if recalculated then
		hero:CalculateStatBonus()
	end
end
