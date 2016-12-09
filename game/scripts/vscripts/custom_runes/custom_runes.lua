if not CustomRunes then
	CustomRunes = class({})
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
		model = "models/props_gameplay/rune_doubledamage01.vmdl",
		particle = "particles/arena/generic_gameplay/rune_tripledamage.vpcf",
		sound = "Rune.DD",
		color = {255,125,0},
		duration = 45,
		damage_pct = 200,
	},
	[ARENA_RUNE_HASTE] = {
		model = "models/props_gameplay/rune_haste01.vmdl",
		particle = "particles/generic_gameplay/rune_haste.vpcf",
		sound = "Rune.Haste",
		duration = 25,
		movespeed = 750,
	},
	[ARENA_RUNE_ILLUSION] = {
		model = "models/props_gameplay/rune_illusion01.vmdl",
		particle = "particles/generic_gameplay/rune_illusion.vpcf",
		sound = "Rune.Illusion",
		duration = 75,
		illusion_count = 2,
		illusion_outgoing_damage = 35,
		illusion_incoming_damage = 200,
	},
	[ARENA_RUNE_INVISIBILITY] = {
		model = "models/props_gameplay/rune_invisibility01.vmdl",
		particle = "particles/generic_gameplay/rune_invisibility.vpcf",
		sound = "Rune.Invis",
		duration = 60
	},
	[ARENA_RUNE_REGENERATION] = {
		model = "models/props_gameplay/rune_regeneration01.vmdl",
		particle = "particles/generic_gameplay/rune_regeneration.vpcf",
		sound = "Rune.Regen"
	},
	[ARENA_RUNE_BOUNTY] = {
		model = "models/props_gameplay/rune_goldxp.vmdl",
		particle = "particles/generic_gameplay/rune_bounty.vpcf",
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
		model = "models/props_gameplay/rune_arcane.vmdl",
		particle = "particles/generic_gameplay/rune_arcane.vpcf",
		sound = "Rune.Arcane",
		duration = 50,
		cooldown_reduction = 30, --Tooltip
		spell_amplify = 50, --Tooltip
	},
	[ARENA_RUNE_FLAME] = {
		model = "models/props_gameplay/rune_illusion01.vmdl",
		particle = "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf",
		sound = "General.RunePickUp",
		color = {255, 30, 0},
		duration = 30,
		damage_per_second = 80, --Tooltip
		radius = 350, --Tooltip
	},
	[ARENA_RUNE_ACCELERATION] = {
		model = "models/props_gameplay/rune_goldxp.vmdl",
		particle = "particles/arena/generic_gameplay/rune_acceleration.vpcf",
		sound = "General.RunePickUp",
		color = {20, 20, 255},
		duration = 35,
		attackspeed = 90, --Tooltip
		creep_xp_multiplier = 2,
	},
	[ARENA_RUNE_VIBRATION] = {
		model = "models/props_gameplay/rune_invisibility01.vmdl",
		particle = "particles/arena/generic_gameplay/rune_vibration.vpcf",
		sound = "General.RunePickUp",
		color = {0, 0, 255},
		duration = 25,
		interval = 0.8,
		minRadius = 150,
		fullRdius = 350,
		minForce = 375,
		fullForce = 700,
	}
}

function CustomRunes:ActivateRune(unit, runeType, rune_multiplier)
	local settings = {}
	table.merge(settings, RUNE_SETTINGS[runeType])
	if unit.GetPlayerID then
		GameRules:SendCustomMessageToTeam("custom_runes_rune_" .. runeType .. "_activated", unit:GetTeam(), unit:GetPlayerID(), -1)
		HeroVoice:OnRuneActivated(unit:GetPlayerID(), runeType)
	end
	if rune_multiplier then
		for k, v in pairs(settings) do
			if type(v) == "number" and k ~= "interval" and k ~= "illusion_incoming_damage" and k ~= "movespeed" then
				settings[k] = v * rune_multiplier
			end
		end
	end
	if runeType == ARENA_RUNE_BOUNTY then
		local gold, xp = settings.GetValues(unit)
		Gold:AddGoldWithMessage(unit, gold * settings.special_value_multiplier)
		unit:AddExperience(xp * settings.special_value_multiplier, DOTA_ModifyXP_Unspecified, false, true)
	elseif runeType == ARENA_RUNE_TRIPLEDAMAGE then
		unit:AddNewModifier(unit, nil, "modifier_arena_rune_tripledamage", {duration = settings.duration}):SetStackCount(settings.damage_pct)
	elseif runeType == ARENA_RUNE_HASTE then
		unit:AddNewModifier(unit, nil, "modifier_arena_rune_haste", {duration = settings.duration}):SetStackCount(settings.movespeed)
	elseif runeType == ARENA_RUNE_ILLUSION then
		for i = 1, settings.illusion_count do
			CreateIllusion(unit, nil, unit:GetAbsOrigin() + RandomVector(100), settings.illusion_incoming_damage - 100, settings.illusion_outgoing_damage - 100, settings.duration):SetForwardVector(unit:GetForwardVector())
		end
	elseif runeType == ARENA_RUNE_INVISIBILITY then
		unit:AddNewModifier(unit, nil, "modifier_arena_rune_invisibility", {duration = settings.duration})
	elseif runeType == ARENA_RUNE_REGENERATION then
		unit:SetHealth(unit:GetMaxHealth())
		unit:SetMana(unit:GetMaxMana())
	elseif runeType == ARENA_RUNE_ARCANE then
		unit:AddNewModifier(unit, nil, "modifier_arena_rune_arcane", {duration = settings.duration})
	elseif runeType == ARENA_RUNE_FLAME then
		unit:AddNewModifier(unit, nil, "modifier_arena_rune_flame", {duration = settings.duration})
	elseif runeType == ARENA_RUNE_ACCELERATION then
		unit:AddNewModifier(unit, nil, "modifier_arena_rune_acceleration", {duration = settings.duration, creep_xp_multiplier = settings.creep_xp_multiplier})
	elseif runeType == ARENA_RUNE_VIBRATION then
		unit:AddNewModifier(unit, nil, "modifier_arena_rune_vibration", {
			duration = settings.duration,
			minRadius = settings.minRadius,
			fullRdius = settings.fullRdius,
			minForce = settings.minForce,
			fullForce = settings.fullForce,
			interval = settings.interval,
		})
	end
	unit:EmitSound(settings.sound)
end

function CustomRunes:CreateRune(position, runeType)
	local settings = RUNE_SETTINGS[runeType]

	local entity = CreateUnitByName("npc_arena_rune", position, false, nil, nil, DOTA_TEAM_NEUTRALS)
	entity.RuneType = runeType
	entity:SetModel(settings.model)
	entity:SetOriginalModel(settings.model)
	StartAnimation(entity, {duration=-1, activity=ACT_DOTA_IDLE})
	local pfx = ParticleManager:CreateParticle(settings.particle, PATTACH_ABSORIGIN_FOLLOW, entity)
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
		if IsValidEntity(v.RuneEntity) and v.RuneEntity:IsAlive() then
			v.RuneEntity:ClearNetworkableEntityInfo()
			UTIL_Remove(v.RuneEntity)
		end
		v.RuneEntity = CustomRunes:CreateRune(v:GetAbsOrigin(), k == bountySpawner and ARENA_RUNE_BOUNTY or RandomInt(ARENA_RUNE_FIRST, ARENA_RUNE_LAST))
	end
end

function CustomRunes:ExecuteOrderFilter(order)
	if order.units["0"] and (order.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET or order.order_type == DOTA_UNIT_ORDER_ATTACK_TARGET) then
		local unit = EntIndexToHScript(order.units["0"])
		local rune = EntIndexToHScript(order.entindex_target)
		if rune and unit and rune:IsCustomRune() then
			local pos = rune:GetAbsOrigin()
			order.order_type = DOTA_UNIT_ORDER_MOVE_TO_POSITION
			order.position_x = pos.x
			order.position_y = pos.y
			order.position_z = pos.z
			if unit:IsRealHero() then
				local issuerID = order.issuer_player_id_const
				Containers.rangeActions[order.units["0"]] = {
					unit = unit,
					position = rune:GetAbsOrigin(),
					range = 100,
					playerID = issuerID,
					action = function()
						if IsValidEntity(unit) and IsValidEntity(rune) then
							local runeType = rune.RuneType
							rune:ClearNetworkableEntityInfo()
							UTIL_Remove(rune)
							unit:Stop()

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
								Notifications:Bottom(issuerID, {text="#item_rune_keeper_rune_picked_up", duration = 8})
								Notifications:Bottom(issuerID, {text="#custom_runes_rune_" .. runeType .. "_title", continue=true})
								Notifications:Bottom(issuerID, {text="#item_rune_keeper_rune_picked_up_cont", continue=true})
								for i,v in ipairs(runeKeeper.RuneContainer) do
									Notifications:Bottom(issuerID, {text="#custom_runes_rune_" .. v.rune .. "_title", continue=true})
									Notifications:Bottom(issuerID, {text=" ,", continue=true})
								end
							elseif bottle then
								bottle:SetStorageRune(runeType)
							else
								CustomRunes:ActivateRune(unit, runeType)
							end
						end
					end,
				}
			end
		end
	end
end

function CEntityInstance:IsCustomRune()
	return self.GetUnitName and self:GetUnitName() == "npc_arena_rune"
end
if not PlayerResource or true then return end
local entity = CreateUnitByName("npc_arena_rune", PlayerResource:GetSelectedHeroEntity(0):GetAbsOrigin() + RandomVector(200), true, nil, nil, DOTA_TEAM_NEUTRALS)
entity:SetModel("models/props_gameplay/rune_goldxp.vmdl")
entity:SetOriginalModel("models/props_gameplay/rune_goldxp.vmdl")
StartAnimation(entity, {duration=-1, activity=ACT_DOTA_IDLE})
entity:SetRenderColor(unpack({20,20,255}))