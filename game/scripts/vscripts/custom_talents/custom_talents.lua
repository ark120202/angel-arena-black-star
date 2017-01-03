if not CustomTalents then
	CustomTalents = class({})
	CustomTalents.ModifierApplier = CreateItem("item_talent_modifier_applier", nil, nil)
end

local modifiers = {
	"damage",
	"evasion",
	"movespeed_pct",
	"lifesteal",
	"creep_gold",
	"movespeed_limit",
	
	"health",
	"health_regen",
	"armor",
	"magic_resistance_pct",
	"vision_day",
	"vision_night",
	"cooldown_reduction_pct",
	--rune multiplier
}
for _,v in pairs(modifiers) do
	LinkLuaModifier("modifier_talent_" .. v, "custom_talents/modifier_talent_" .. v, LUA_MODIFIER_MOTION_NONE)
end

function CustomTalents:Init()
	CustomGameEventManager:RegisterListener("custom_talents_upgrade", function(_, keys)
		local hero = PlayerResource:GetSelectedHeroEntity(keys.PlayerID)
		hero:UpgradeTalent(keys.talent)
	end)
	local talentList = {}
	for k,v in pairs(CUSTOM_TALENTS_DATA) do
		local t = PlayerTables:copy(v)
		if not talentList[t.group] then talentList[t.group] = {} end
		t.name = k
		t.effect = nil
		if t.special_values then
			for key,value in pairs(t.special_values) do
				if type(value) == "table" then
					t.special_values[key] = {}
					for _,value2 in ipairs(value) do
						table.insert(t.special_values[key], tostring(value2))
					end
				else
					t.special_values[key] = tostring(value)
				end
			end
		end
		table.insert(talentList[t.group], t)
	end
	PlayerTables:CreateTable("custom_talents_data", {
		talentList = talentList,
		groupLevelMap = TALENT_GROUP_TO_LEVEL,
	}, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
end

function CustomTalents:Talent_Verify(name)
	return CUSTOM_TALENTS_DATA[name] ~= nil
end

function CustomTalents:Talent_GetGroup(name)
	return CUSTOM_TALENTS_DATA[name].group
end

function CustomTalents:Talent_GetCost(name)
	return CUSTOM_TALENTS_DATA[name].cost
end

function CustomTalents:Talent_GetSpecialValue(name, property)
	return CUSTOM_TALENTS_DATA[name].special_values[property]
end

function CDOTA_BaseNPC:GetTalentLevel(name)
	if self.talents and self.talents[name] then
		return self.talents[name].level
	end
	return 0
end

function CDOTA_BaseNPC:GetLastUpgradedTalentGroup()
	local highest = 0
	if self.talents then
		for k,_ in pairs(self.talents) do
			local g = CustomTalents:Talent_GetGroup(k)
			if g > highest then
				highest = g
			end
		end
	end
	return highest
end

function CDOTA_BaseNPC:CanUpgradeTalent(name)
	local group = CustomTalents:Talent_GetGroup(name)
	local requirement = CUSTOM_TALENTS_DATA[name].requirement
	--print(self:GetAbilityPoints() >= CustomTalents:Talent_GetCost(name), self:GetLevel() >= TALENT_GROUP_TO_LEVEL[group], self:GetLastUpgradedTalentGroup() + 1 >= group, (not requirement or (NPC_HEROES_CUSTOM[requirement] ~= nil and GetFullHeroName(self) == requirement) or self:HasAbility(requirement)), self:GetTalentLevel(name) < (CUSTOM_TALENTS_DATA[name].max_level or 1))
	return self:GetAbilityPoints() >= CustomTalents:Talent_GetCost(name) and self:GetLevel() >= TALENT_GROUP_TO_LEVEL[group] and self:GetLastUpgradedTalentGroup() + 1 >= group and (not requirement or (NPC_HEROES_CUSTOM[requirement] ~= nil and GetFullHeroName(self) == requirement) or self:HasAbility(requirement)) and self:GetTalentLevel(name) < (CUSTOM_TALENTS_DATA[name].max_level or 1)
end

function CDOTA_BaseNPC:HasTalent(name)
	return self.talents ~= nil and self.talents[name] ~= nil
end

function CDOTA_BaseNPC:GetTalentSpecial(name, property)
	if CustomTalents:Talent_Verify(name) and self:HasTalent(name) then
		local t = CustomTalents:Talent_GetSpecialValue(name, property)
		if type(t) == "table" then
			t = t[self.talents[name].level] or t[#t]
		end
		return t
	end
end

function CDOTA_BaseNPC:ClearTalents()
	for _,v in ipairs(self.talents) do
		for _,v2 in ipairs(v.modifiers) do
			v2:Destroy()
		end
		for _,v2 in ipairs(v.abilities) do
			RemoveAbilityWithModifiers(self, v2)
		end
	end
	self.talents = {}
end

function CDOTA_BaseNPC:UpgradeTalent(name)
	if CustomTalents:Talent_Verify(name) and self:CanUpgradeTalent(name) then
		self:SetAbilityPoints(self:GetAbilityPoints() - CustomTalents:Talent_GetCost(name))
		if not self.talents then self.talents = {} end
		if not self.talents[name] then self.talents[name] = {level = 0, modifiers = {}, abilities = {}, ability_multicast = {}, unit_keys = {}} end
		self.talents[name].level = self.talents[name].level + 1
		local effect = CUSTOM_TALENTS_DATA[name].effect

		local t = self:GetNetworkableEntityInfo("LearntTalents") or {}
		if not t[name] then t[name] = {} end
		t[name].level = self.talents[name].level
		self:SetNetworkableEntityInfo("LearntTalents", t)
		if effect then
			if effect.abilities then
				if type(effect.abilities) == "string" then
					effect.abilities = {effect.abilities}
				end
				for _,v in ipairs(effect.abilities) do
					local ability = self:FindAbilityByName(v) or AddNewAbility(self, v)
					ability:SetLevel(self.talents[name].level)
					if not table.contains(self.talents[name].abilities, ability) then
						table.insert(self.talents[name].abilities, ability)
					end
				end
			end
			if effect.modifiers then
				for _,v in ipairs(self.talents[name].modifiers) do
					v:Destroy()
				end
				self.talents[name].modifiers = {}
				if type(effect.modifiers) == "string" then
					effect.modifiers = {effect.modifiers}
				end
				for k,v in pairs(effect.modifiers) do
					local modifier
					if type(k) == "string" then
						if type(v) == "string" then
							v = self:GetTalentSpecial(name, v)
						end
						if effect.use_modifier_applier then
							CustomTalents.ModifierApplier:ApplyDataDrivenModifier(self, self, k, nil)
							modifier = self:FindModifierByNameAndCaster(k, self) --TODO: Find newest modifier
						else
							modifier = self:AddNewModifier(self, nil, k, nil)
						end
						if modifier then
							modifier:SetStackCount(v)
						else
							print("[CustomTalents] Attempt to create unknown modifier named " .. k .. "!")
						end
					else
						modifier = effect.use_modifier_applier and CustomTalents.ModifierApplier:ApplyDataDrivenModifier(self, self, v, nil) or self:AddNewModifier(self, nil, v, nil)
					end
					table.insert(self.talents[name].modifiers, modifier)
				end
			end
			if effect.unit_keys then
				for k,v in pairs(self.talents[name].unit_keys) do
					if self.talent_keys and self.talent_keys[k] then
						self.talent_keys[k] = self.talent_keys[k] - v
					end
				end
				self.talents[name].unit_keys = {}
				for k,v in pairs(effect.unit_keys) do
					if type(v) == "string" then
						v = self:GetTalentSpecial(name, v)
					end
					if not self.talent_keys then self.talent_keys = {} end
					if not self.talent_keys[k] then self.talent_keys[k] = 0 end
					self.talent_keys[k] = self.talent_keys[k] + v
					self.talents[name].unit_keys[k] = v
				end
			end
			if effect.multicast_abilities then
				for k,v in pairs(self.talents[name].ability_multicast) do
					if self.talents_ability_multicast and self.talents_ability_multicast[k] then
						self.talents_ability_multicast[k] = self.talents_ability_multicast[k] - v + 1
					end
				end
				self.talents[name].multicast_abilities = {}
				for k,v in pairs(effect.multicast_abilities) do
					if not self.talents_ability_multicast then self.talents_ability_multicast = {} end
					if not self.talents_ability_multicast[k] then self.talents_ability_multicast[k] = 1 end
					self.talents_ability_multicast[k] = self.talents_ability_multicast[k] + v - 1
					self.talents[name].ability_multicast[k] = v
				end
			end
			if effect.calculate_stat_bonus and self.CalculateStatBonus then
				self:CalculateStatBonus()
			end
		end
		--[[if self.OnTalentUpgrade then

		end]]
	end
end