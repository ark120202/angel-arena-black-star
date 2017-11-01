--Based on MNoya's lib
ModuleRequire(..., "data")
if not Attributes then
	Attributes = class({})
	Attributes.Applier = CreateItem("item_attributes_modifier_applier", nil, nil)
end

function Attributes:SetHealthPerStr(hero, value)
	Attributes:SetHeroXPerY(hero, "hp", value)
end

function Attributes:SetHealthRegenPercentagePerStr(hero, value)
	Attributes:SetHeroXPerY(hero, "hp_regen_pct", value)
end

function Attributes:SetArmorPerAgi(hero, value)
	Attributes:SetHeroXPerY(hero, "armor", value)
end

function Attributes:SetAttackspeedPerAgi(hero, value)
	Attributes:SetHeroXPerY(hero, "attackspeed", value)
end

function Attributes:SetManaPerInt(hero, value)
	Attributes:SetHeroXPerY(hero, "mana", value)
end

function Attributes:SetManaRegenPercentagePerInt(hero, value)
	Attributes:SetHeroXPerY(hero, "mana_regen_pct", value)
end

function Attributes:SetSpellAmplifyPerInt(hero, value)
	Attributes:SetHeroXPerY(hero, "spell_amplify", value)
end

function Attributes:SetHeroXPerY(hero, x, y)
	if not hero.attributes_adjustments then hero.attributes_adjustments = {} end
	hero.attributes_adjustments[x] = y - DOTA_DEFAULT_ATTRIBUTES[x]
end


function Attributes:GetTotalGrantedHealth(hero)
	return Attributes:GetHeroTotalGrantedX(hero, "hp", hero:GetStrength())
end

function Attributes:GetTotalGrantedHealthRegenPercentage(hero)
	return Attributes:GetHeroTotalGrantedX(hero, "hp_regen_pct", hero:GetStrength())
end

function Attributes:GetTotalGrantedArmor(hero)
	return Attributes:GetHeroTotalGrantedX(hero, "armor", hero:GetAgility())
end

function Attributes:GetTotalGrantedAttackspeed(hero)
	return Attributes:GetHeroTotalGrantedX(hero, "attackspeed", hero:GetAgility())
end

function Attributes:GetTotalGrantedMana(hero)
	return Attributes:GetHeroTotalGrantedX(hero, "mana", hero:GetIntellect())
end

function Attributes:GetTotalGrantedManaRegenPercentage(hero)
	return Attributes:GetHeroTotalGrantedX(hero, "mana_regen_pct", hero:GetIntellect())
end

function Attributes:GetTotalGrantedSpellAmplify(hero)
	return Attributes:GetHeroTotalGrantedX(hero, "spell_amplify", hero:GetIntellect())
end

function Attributes:GetHeroTotalGrantedX(hero, x, stat)
	local adjustment = GLOBAL_ATTRIBUTE_ADJUSTMENTS[x]
	if hero.attributes_adjustments and hero.attributes_adjustments[x] then
		adjustment = hero.attributes_adjustments[x]
	end
	local xPerStat = adjustment + DOTA_DEFAULT_ATTRIBUTES[x]
	return stat * xPerStat
end


function Attributes:CalculateStatBonus(hero)
	if not hero.custom_stats then
		hero.custom_stats = true
		hero.strength = 0
		hero.agility = 0
		hero.intellect = 0
	end

	local strength = hero:GetStrength()
	local agility = hero:GetAgility()
	local intellect = hero:GetIntellect()
	local adjustments = table.deepcopy(GLOBAL_ATTRIBUTE_ADJUSTMENTS)
	if hero.attributes_adjustments then
		for k,v in pairs(hero.attributes_adjustments) do
			adjustments[k] = v
		end
	end

	if strength ~= hero.strength then
		if not hero:HasModifier("modifier_attribute_health") then self.Applier:ApplyDataDrivenModifier(hero, hero, "modifier_attribute_health", {}) end
		local health_stacks = math.abs(strength * adjustments.hp)
		hero:SetModifierStackCount("modifier_attribute_health", hero, health_stacks)

		if not hero:HasModifier("modifier_attribute_health_regen_pct") then self.Applier:ApplyDataDrivenModifier(hero, hero, "modifier_attribute_health_regen_pct", {}) end
		local health_regen_stacks = math.abs(strength * adjustments.hp_regen_pct * 100)
		hero:SetModifierStackCount("modifier_attribute_health_regen_pct", hero, health_regen_stacks)
	end

	if agility ~= hero.agility then
		local armor = agility * adjustments.armor
		hero:SetPhysicalArmorBaseValue(hero:GetKeyValue("ArmorPhysical") + armor)

		if not hero:HasModifier("modifier_attribute_attackspeed") then self.Applier:ApplyDataDrivenModifier(hero, hero, "modifier_attribute_attackspeed", {}) end
		local attackspeed_stacks = math.abs(agility * adjustments.attackspeed)
		hero:SetModifierStackCount("modifier_attribute_attackspeed", hero, attackspeed_stacks)
	end

	if intellect ~= hero.intellect then
		if not hero:HasModifier("modifier_attribute_mana") then self.Applier:ApplyDataDrivenModifier(hero, hero, "modifier_attribute_mana", {}) end
		local mana_stacks = math.abs(intellect * adjustments.mana)
		hero:SetModifierStackCount("modifier_attribute_mana", hero, mana_stacks)

		if not hero:HasModifier("modifier_attribute_mana_regen_pct") then self.Applier:ApplyDataDrivenModifier(hero, hero, "modifier_attribute_mana_regen_pct", {}) end
		local mana_regen_stacks = math.abs(intellect * adjustments.mana_regen_pct * 100)
		hero:SetModifierStackCount("modifier_attribute_mana_regen_pct", hero, mana_regen_stacks)

		if not hero:HasModifier("modifier_attribute_spell_amplify") then self.Applier:ApplyDataDrivenModifier(hero, hero, "modifier_attribute_spell_amplify", {}) end
		local spell_amplify_stacks = math.abs(intellect * adjustments.spell_amplify * 100)
		hero:SetModifierStackCount("modifier_attribute_spell_amplify", hero, spell_amplify_stacks)

	end

	hero.strength = strength
	hero.agility = agility
	hero.intellect = intellect

	hero:CalculateStatBonus()
end
