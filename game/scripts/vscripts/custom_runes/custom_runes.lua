if not CustomRunes then
	CustomRunes = class({})
	CustomRunes.ModifierApplier = CreateItem("item_dummy", nil, nil)
end
LinkLuaModifier("modifier_arena_rune_tripledamage", "custom_runes/modifier_arena_rune_tripledamage.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arena_rune_haste", "custom_runes/modifier_arena_rune_haste.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arena_rune_invisibility", "custom_runes/modifier_arena_rune_invisibility.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arena_rune_arcane", "custom_runes/modifier_arena_rune_arcane.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arena_rune_flame", "custom_runes/modifier_arena_rune_flame.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arena_rune_acceleration", "custom_runes/modifier_arena_rune_acceleration.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_arena_rune_vibration", "custom_runes/modifier_arena_rune_vibration.lua", LUA_MODIFIER_MOTION_NONE)

ARENA_RUNE_BOUNTY = 0
ARENA_RUNE_TRIPLEDAMAGE = 1
ARENA_RUNE_HASTE = 2
ARENA_RUNE_ILLUSION = 3
ARENA_RUNE_INVISIBILITY = 4
ARENA_RUNE_REGENERATION = 5
ARENA_RUNE_ARCANE = 6
ARENA_RUNE_FLAME = 7
ARENA_RUNE_ACCELERATION = 8
ARENA_RUNE_VIBRATION = 9

ARENA_RUNE_FIRST = 1
ARENA_RUNE_LAST = ARENA_RUNE_VIBRATION

RUNE_SETTINGS = {
	[ARENA_RUNE_TRIPLEDAMAGE] = {
		item = "item_rune_tripledamage",
		sound = "Rune.DD",
		color = {255,125,0},
	},
	[ARENA_RUNE_HASTE] = {
		item = "item_rune_haste",
		sound = "Rune.Haste",
	},
	[ARENA_RUNE_ILLUSION] = {
		item = "item_rune_illusion",
		sound = "Rune.Illusion",
	},
	[ARENA_RUNE_INVISIBILITY] = {
		item = "item_rune_invisibility",
		sound = "Rune.Invis",
		duration = 60
	},
	[ARENA_RUNE_REGENERATION] = {
		item = "item_rune_regeneration",
		sound = "Rune.Regen"
	},
	[ARENA_RUNE_BOUNTY] = {
		item = "item_rune_bounty",
		sound = "Rune.Bounty",
		GetValues = function(unit)
			local gold = 300 + (20 * GetDOTATimeInMinutesFull())
			local xp = 150 + (10 * GetDOTATimeInMinutesFull())
			local gold_multiplier = 1
			local xp_multiplier = 1

			local ability_plus_morality = unit:FindAbilityByName("arthas_plus_morality")
			if ability_plus_morality and ability_plus_morality:GetLevel() > 0 then
				gold_multiplier = gold_multiplier + ability_plus_morality:GetAbilitySpecial("bounty_multiplier") - 1
				ModifyStacks(ability_plus_morality, unit, unit, "modifier_arthas_plus_morality_buff", 1, false)
			end
			local ability_goblins_greed = unit:FindAbilityByName("alchemist_goblins_greed")
			if ability_goblins_greed and ability_goblins_greed:GetLevel() > 0 then
				gold_multiplier = gold_multiplier + ability_goblins_greed:GetAbilitySpecial("bounty_multiplier_tooltip") - 1
			end
			local item_blood_of_midas = FindItemInInventoryByName(unit, "item_blood_of_midas", false)
			if item_blood_of_midas then
				gold_multiplier = gold_multiplier + item_blood_of_midas:GetLevelSpecialValueFor("gold_multiplier", item_blood_of_midas:GetLevel() - 1) - 1
				xp_multiplier = xp_multiplier + item_blood_of_midas:GetLevelSpecialValueFor("xp_multiplier", item_blood_of_midas:GetLevel() - 1) - 1
			end
			return gold * gold_multiplier, xp * xp_multiplier
		end,
		special_value_multiplier = 1,
	},
	[ARENA_RUNE_ARCANE] = {
		item = "item_rune_arcane",
		sound = "Rune.Arcane",
	},
	[ARENA_RUNE_FLAME] = {
		item = "item_rune_flame",
		sound = "General.RunePickUp",
		color = {255, 30, 0},
	},
	[ARENA_RUNE_ACCELERATION] = {
		item = "item_rune_acceleration",
		sound = "General.RunePickUp",
		color = {20, 20, 255},
	},
	[ARENA_RUNE_VIBRATION] = {
		item = "item_rune_vibration",
		sound = "General.RunePickUp",
		color = {0, 0, 255},
	}
}

function CustomRunes:GetRuneSettings(runeType)
	local values = {}
	local kv = GetKeyValue(RUNE_SETTINGS[runeType].item, "AbilitySpecial")
	if kv then
		for _,v in pairs(kv) do
			for key, value in pairs(v) do
				if key ~= var_type and key ~= CalculateSpellDamageTooltip then
					values[key] = value
				end
			end
		end
	end
	return values
end

function CustomRunes:ActivateRune(unit, runeType, rune_multiplier)
	local rune_settings = RUNE_SETTINGS[runeType]
	if unit.GetPlayerID then
		CustomGameEventManager:Send_ServerToTeam(unit:GetTeam(), "create_custom_toast", {
			type = "generic",
			text = "#custom_toast_ActivatedRune",
			player = unit:GetPlayerID(),
			runeType = runeType
		})
		HeroVoice:OnRuneActivated(unit:GetPlayerID(), runeType)
	end
	local rune_values = CustomRunes:GetRuneSettings(runeType)
	if rune_multiplier then
		for k, v in pairs(rune_values) do
			if type(v) == "number" and k ~= "interval" and k ~= "illusion_incoming_damage" and k ~= "movespeed" then
				rune_values[k] = v * rune_multiplier
			end
		end
	end
	if runeType == ARENA_RUNE_BOUNTY then
		local gold, xp = rune_settings.GetValues(unit)
		Gold:AddGoldWithMessage(unit, gold * rune_values.special_value_multiplier)
		unit:AddExperience(xp * rune_values.special_value_multiplier, DOTA_ModifyXP_Unspecified, false, true)
	elseif runeType == ARENA_RUNE_TRIPLEDAMAGE then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_tripledamage", {duration = rune_values.duration}):SetStackCount(rune_values.damage_pct)
	elseif runeType == ARENA_RUNE_HASTE then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_haste", {duration = rune_values.duration}):SetStackCount(rune_values.movespeed)
	elseif runeType == ARENA_RUNE_ILLUSION then
		for i = 1, rune_values.illusion_count do
			CreateIllusion(unit, CustomRunes.ModifierApplier, unit:GetAbsOrigin() + RandomVector(100), rune_values.illusion_incoming_damage - 100, rune_values.illusion_outgoing_damage - 100, rune_values.duration):SetForwardVector(unit:GetForwardVector())
		end
	elseif runeType == ARENA_RUNE_INVISIBILITY then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_invisibility", {duration = rune_values.duration})
	elseif runeType == ARENA_RUNE_REGENERATION then
		unit:SetHealth(unit:GetMaxHealth())
		unit:SetMana(unit:GetMaxMana())
	elseif runeType == ARENA_RUNE_ARCANE then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_arcane", {duration = rune_values.duration})
	elseif runeType == ARENA_RUNE_FLAME then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_flame", {duration = rune_values.duration, damage_per_second_max_hp_pct = rune_values.damage_per_second_max_hp_pct})
	elseif runeType == ARENA_RUNE_ACCELERATION then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_acceleration", {duration = rune_values.duration, xp_multiplier = rune_values.xp_multiplier})
	elseif runeType == ARENA_RUNE_VIBRATION then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_vibration", {
			duration = rune_values.duration,
			minRadius = rune_values.minRadius,
			fullRadius = rune_values.fullRadius,
			minForce = rune_values.minForce,
			fullForce = rune_values.fullForce,
			interval = rune_values.interval,
		})
	end
	unit:EmitSound(rune_settings.sound)
end

function CustomRunes:CreateRune(position, runeType)
	local settings = RUNE_SETTINGS[runeType]

	local item = CreateItem(settings.item, nil, nil)
	item.RuneType = runeType
	local entity = CreateItemOnPositionSync(position, item) --CreateUnitByName("npc_arena_rune", position, false, nil, nil, DOTA_TEAM_NEUTRALS)
	if settings.color then
		entity:SetRenderColor(unpack(settings.color))
	end
	if settings.oncreated then
		settings.oncreated(entity)
	end
	entity:SetNetworkableEntityInfo("custom_tooltip", {
		title = "#custom_runes_rune_" .. runeType .. "_title",
		text = "#custom_runes_rune_" .. runeType .. "_text"
	})
	return entity
end

function CustomRunes:Init()
	for _,v in ipairs(Entities:FindAllByName("target_mark_rune_spawner")) do
		DynamicMinimap:CreateMinimapPoint(v:GetAbsOrigin(), "icon_rune")
	end
end

function CustomRunes:SpawnRunes()
	local spawners = Entities:FindAllByName("target_mark_rune_spawner")
	local bountySpawner = RandomInt(1, #spawners)
	for k,v in ipairs(spawners) do
		if IsValidEntity(v.RuneEntity) then
			UTIL_Remove(v.RuneEntity)
		end
		v.RuneEntity = CustomRunes:CreateRune(v:GetAbsOrigin(), k == bountySpawner and ARENA_RUNE_BOUNTY or RandomInt(ARENA_RUNE_FIRST, ARENA_RUNE_LAST))
	end
end

function CustomRunes:ItemNameToRuneType(item)
	for id, set in pairs(RUNE_SETTINGS) do
		if set.item == item then
			return id
		end
	end
end

function CustomRunes:ItemAddedToInventoryFilter(unit, item)
	if IsValidEntity(unit) and IsValidEntity(item) and item.RuneType then
		local runeType = item.RuneType
		UTIL_Remove(item)
		local PlayerID = unit:GetPlayerOwnerID()
		local bottle
		local runeKeeper
		for i = 0, 5 do
			local item = unit:GetItemInSlot(i)
			if item then
				if not runeKeeper and item:GetAbilityName() == "item_rune_keeper" then
					runeKeeper = item
				elseif not bottle and item:GetAbilityName() == "item_bottle_arena" and not item.RuneStorage then
					bottle = item
				end
			end
		end
		
		if runeKeeper and runeKeeper.RuneContainer then
			table.insert(runeKeeper.RuneContainer, {rune=runeType, expireGameTime = GameRules:GetGameTime() + runeKeeper:GetAbilitySpecial("store_duration")})
			if PlayerID > -1 then
				Notifications:Bottom(PlayerID, {text="#item_rune_keeper_rune_picked_up", duration = 8})
				Notifications:Bottom(PlayerID, {text="#custom_runes_rune_" .. runeType .. "_title", continue=true})
				Notifications:Bottom(PlayerID, {text="#item_rune_keeper_rune_picked_up_cont", continue=true})
				for i,v in ipairs(runeKeeper.RuneContainer) do
					Notifications:Bottom(PlayerID, {text="#custom_runes_rune_" .. v.rune .. "_title", continue=true})
					Notifications:Bottom(PlayerID, {text=" ,", continue=true})
				end
			end
		elseif bottle then
			bottle:SetStorageRune(runeType)
		else
			CustomRunes:ActivateRune(unit, runeType)
		end
		return false
	end
	return true
end

--[[function CEntityInstance:IsCustomRune()
	return self.GetUnitName and self:GetUnitName() == "npc_arena_rune"
end
if not PlayerResource or true then return end
local entity = CreateUnitByName("npc_arena_rune", PlayerResource:GetSelectedHeroEntity(0):GetAbsOrigin() + RandomVector(200), true, nil, nil, DOTA_TEAM_NEUTRALS)
entity:SetModel("models/props_gameplay/rune_goldxp.vmdl")
entity:SetOriginalModel("models/props_gameplay/rune_goldxp.vmdl")
StartAnimation(entity, {duration=-1, activity=ACT_DOTA_IDLE})
entity:SetRenderColor(unpack({20,20,255}))]]