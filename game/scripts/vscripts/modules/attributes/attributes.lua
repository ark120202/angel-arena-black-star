ModuleRequire(..., "data")

for propName, propValue in pairs(ATTRIBUTE_LIST) do
	if propValue.recalculate == nil then
		ModuleLinkLuaModifier(..., "modifier_attribute_" .. propName, "modifiers")
	end
end

if not Attributes then
	Attributes = class({})
	Attributes.Applier = CreateItem("item_dummy", nil, nil)
end


Events:Register("activate", function ()
	local gameModeEntity = GameRules:GetGameModeEntity()
	for _, v in pairs(ATTRIBUTE_LIST) do
		if v.attributeDerivedStat ~= nil then
			gameModeEntity:SetCustomAttributeDerivedStatValue(v.attributeDerivedStat, v.default)
		end
	end
end)

function Attributes:SetPropValue(hero, prop, value)
	if not hero.attributes_adjustments then hero.attributes_adjustments = {} end
	local propValue = ATTRIBUTE_LIST[prop]
	if not propValue then error('Not found property named "' .. prop .. '"') end
	hero.attributes_adjustments[prop] = value - propValue.default
end

function Attributes:GetTotalPropValue(arg1, prop)
	local hero = type(arg1) == "table" and arg1
	local attributeValue = type(arg1) == "number" and arg1
	local propValue = ATTRIBUTE_LIST[prop]
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
	return 0
end

function Attributes:CheckAttributeModifier(hero, modifier)
	if not hero:HasModifier(modifier) then
		hero:AddNewModifier(hero, self.Applier, modifier, nil)
	end
end
