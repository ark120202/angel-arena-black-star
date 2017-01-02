if not CustomTalents then
	CustomTalents = class({})
end

local modifiers = {
	"damage",
	"evasion",
	"movespeed_pct",
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
		if not talentList[v.group] then talentList[v.group] = {} end
		local t = {}
		table.merge(t, v)
		t.name = k
		t.effect = nil
		table.insert(talentList[v.group], t)
	end
	PlayerTables:CreateTable("custom_talents_data", {
		talentList = talentList,
		groupLevelMap = TALENT_GROUP_TO_LEVEL,
	}, {0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23})
	PlayerTables:CreateTable("custom_talents_selected", {
		[0] = {actualGroup = 0},
		[1] = {actualGroup = 0},
		[2] = {actualGroup = 0},
		[3] = {actualGroup = 0},
		[4] = {actualGroup = 0},
		[5] = {actualGroup = 0},
		[6] = {actualGroup = 0},
		[7] = {actualGroup = 0},
		[8] = {actualGroup = 0},
		[9] = {actualGroup = 0},
		[10] = {actualGroup = 0},
		[11] = {actualGroup = 0},
		[12] = {actualGroup = 0},
		[13] = {actualGroup = 0},
		[14] = {actualGroup = 0},
		[15] = {actualGroup = 0},
		[16] = {actualGroup = 0},
		[17] = {actualGroup = 0},
		[18] = {actualGroup = 0},
		[19] = {actualGroup = 0},
		[20] = {actualGroup = 0},
		[21] = {actualGroup = 0},
		[22] = {actualGroup = 0},
		[23] = {actualGroup = 0},
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
		if not self.talents[name] then self.talents[name] = {level = 0, modifiers = {}, abilities = {}} end
		self.talents[name].level = self.talents[name].level + 1
		local effect = CUSTOM_TALENTS_DATA[name].effect
		local t = PlayerTables:GetTableValue("custom_talents_selected", self:GetPlayerID())
		if not t then t = {talents = {}} end
		if not t.talents then t.talents = {} end
		if not t.talents[name] then t.talents[name] = {} end
		t.talents[name].level = self.talents[name].level
		t.actualGroup = self:GetLastUpgradedTalentGroup()
		PlayerTables:SetTableValue("custom_talents_selected", self:GetPlayerID(), t)
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
						modifier = self:AddNewModifier(self, nil, k, nil)
						modifier:SetStackCount(v)
					else
						modifier = self:AddNewModifier(self, nil, v, nil)
					end
					table.insert(self.talents[name].modifiers, modifier)
				end
			end
		end
		--[[if self.OnTalentUpgrade then

		end]]
	end
end