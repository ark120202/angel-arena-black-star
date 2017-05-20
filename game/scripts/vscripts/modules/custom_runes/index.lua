if not CustomRunes then
	CustomRunes = class({})
	CustomRunes.ModifierApplier = CreateItem("item_dummy", nil, nil)
end

local modifiers = {
	"tripledamage",
	"haste",
	"invisibility",
	"arcane",
	"flame",
	"acceleration",
	"vibration",
	"spikes",
	"soul_steal",
	soul_steal_effect = "soul_steal"
}
for k,v in pairs(modifiers) do
	if type(k) == "string" then
		k, v = v, k
	else
		k = nil
	end
	LinkLuaModifier("modifier_arena_rune_" .. v, "modules/custom_runes/modifiers/modifier_arena_rune_" .. (k or v), LUA_MODIFIER_MOTION_NONE)
end

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
ARENA_RUNE_SOUL_STEAL = 10
ARENA_RUNE_SPIKES = 11

ARENA_RUNE_FIRST = 1
ARENA_RUNE_LAST = ARENA_RUNE_SPIKES
--[[
Growing Rates:
	models/props_gameplay/gold_bag.vmdl
	Multiplies all incoming and reduced gold by 1.5 for 25 seconds
Curse:
	models/props_gameplay/gem01.vmdl
	139, 0, 139
	Each attack applies a debuff that will suffer enemy until it purges it or kills any hero (damage will grow with each second: X^1.5)
Mystic Candy:
	models/props_gameplay/halloween_candy.vmdl
	color random
	Applies 3 random buffs/debuffs
Ghost From:
	models/props_gameplay/pig_blue.vmdl
	Gives unobstructed movement, disarm, silence, invisibility, 550 movement speed
Imitator:
	particles/generic_gameplay/generic_electrified_beam_b.vpcf
	Copies all features from another rune, but additionaly has.
	When picked up spawns
]]
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
			local m = GetDOTATimeInMinutesFull()
			local gold = 100 + (m * 2)^2
			local xp = 50 + m^2.2
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
			if unit:HasModifier("modifier_item_blood_of_midas") then
				gold_multiplier = gold_multiplier + GetAbilitySpecial("item_blood_of_midas", "gold_multiplier") - 1
				xp_multiplier = xp_multiplier + GetAbilitySpecial("item_blood_of_midas", "xp_multiplier") - 1
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
		color = {255, 30, 0},
		duration = 30,
		damage_per_second_max_hp_pct = 4,
		radius = 350, --Tooltip
	},
	[ARENA_RUNE_ACCELERATION] = {
		model = "models/props_gameplay/rune_goldxp.vmdl",
		particle = "particles/arena/generic_gameplay/rune_acceleration.vpcf",
		color = {20, 20, 255},
		duration = 35,
		attackspeed = 90, --Tooltip
		xp_multiplier = 3,
	},
	[ARENA_RUNE_VIBRATION] = {
		model = "models/props_gameplay/rune_invisibility01.vmdl",
		particle = "particles/arena/generic_gameplay/rune_vibration.vpcf",
		color = {0, 0, 255},
		duration = 25,
		interval = 0.8,
		minRadius = 150,
		fullRadius = 350,
		minForce = 375,
		fullForce = 700,
	},
	[ARENA_RUNE_SOUL_STEAL] = {
		model = "models/props_gameplay/heart001.vmdl",
		particle = "particles/neutral_fx/prowler_shaman_stomp_debuff_glow.vpcf",
		z_modify = 64,
		color = {0, 0, 0},
		duration = 45,
		aura_radius = 1200,
		damage_heal_pct = 15,
		angles = {0, 270, 0},
	},
	[ARENA_RUNE_SPIKES] = {
		model = "models/props_gameplay/heart001.vmdl",
		particle = "particles/items_fx/blademail.vpcf",
		particle_attach = PATTACH_ABSORIGIN,
		z_modify = 64,
		duration = 25,
		damage_reflection_pct = 75,
		angles = {0, 270, 0},
	}
}

function CustomRunes:ActivateRune(unit, runeType, rune_multiplier)
	local settings = {}
	table.merge(settings, RUNE_SETTINGS[runeType])
	if unit.GetPlayerID then
		CustomGameEventManager:Send_ServerToTeam(unit:GetTeam(), "create_custom_toast", {
			type = "generic",
			text = "#custom_toast_ActivatedRune",
			player = unit:GetPlayerID(),
			runeType = runeType
		})
		HeroVoice:OnRuneActivated(unit:GetPlayerID(), runeType)
	end
	if rune_multiplier then
		for k, v in pairs(settings) do
			if type(v) == "number" and k ~= "interval" and k ~= "illusion_incoming_damage" and k ~= "movespeed" and k ~= "z_modify" then
				settings[k] = v * rune_multiplier
			end
		end
	end
	if runeType == ARENA_RUNE_BOUNTY then
		local gold, xp = settings.GetValues(unit)
		Gold:AddGoldWithMessage(unit, gold * settings.special_value_multiplier)
		unit:AddExperience(xp * settings.special_value_multiplier, DOTA_ModifyXP_Unspecified, false, true)
	elseif runeType == ARENA_RUNE_TRIPLEDAMAGE then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_tripledamage", {duration = settings.duration}):SetStackCount(settings.damage_pct)
	elseif runeType == ARENA_RUNE_HASTE then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_haste", {duration = settings.duration}):SetStackCount(settings.movespeed)
	elseif runeType == ARENA_RUNE_ILLUSION then
		for i = 1, settings.illusion_count do
			CreateIllusion(unit, CustomRunes.ModifierApplier, unit:GetAbsOrigin() + RandomVector(100), settings.illusion_incoming_damage - 100, settings.illusion_outgoing_damage - 100, settings.duration):SetForwardVector(unit:GetForwardVector())
		end
	elseif runeType == ARENA_RUNE_INVISIBILITY then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_invisibility", {duration = settings.duration})
	elseif runeType == ARENA_RUNE_REGENERATION then
		unit:SetHealth(unit:GetMaxHealth())
		unit:SetMana(unit:GetMaxMana())
	elseif runeType == ARENA_RUNE_ARCANE then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_arcane", {duration = settings.duration})
	elseif runeType == ARENA_RUNE_FLAME then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_flame", {duration = settings.duration, damage_per_second_max_hp_pct = settings.damage_per_second_max_hp_pct})
	elseif runeType == ARENA_RUNE_ACCELERATION then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_acceleration", {duration = settings.duration, xp_multiplier = settings.xp_multiplier})
	elseif runeType == ARENA_RUNE_VIBRATION then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_vibration", {
			duration = settings.duration,
			minRadius = settings.minRadius,
			fullRadius = settings.fullRadius,
			minForce = settings.minForce,
			fullForce = settings.fullForce,
			interval = settings.interval,
		})
	elseif runeType == ARENA_RUNE_SOUL_STEAL then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_soul_steal", {duration = settings.duration, radius = settings.aura_radius}):SetStackCount(settings.damage_heal_pct)
	elseif runeType == ARENA_RUNE_SPIKES then
		unit:AddNewModifier(unit, CustomRunes.ModifierApplier, "modifier_arena_rune_spikes", {duration = settings.duration}):SetStackCount(settings.damage_reflection_pct)
	end
	
	unit:EmitSound(settings.sound or "General.RunePickUp")
end

function CustomRunes:CreateRune(position, runeType)
	local settings = RUNE_SETTINGS[runeType]
	if settings.z_modify then
		position.z = position.z + settings.z_modify
	end
	local entity = CreateUnitByName("npc_arena_rune", position, false, nil, nil, DOTA_TEAM_NEUTRALS)
	entity.RuneType = runeType
	entity:SetModel(settings.model)
	entity:SetOriginalModel(settings.model)
	StartAnimation(entity, {duration=-1, activity=ACT_DOTA_IDLE})
	entity:SetAbsOrigin(position)
	if settings.angles then
		entity:SetAngles(unpack(settings.angles))
	end
	local pfx = ParticleManager:CreateParticle(settings.particle, settings.particle_attach or PATTACH_ABSORIGIN_FOLLOW, entity)
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

		if IsValidEntity(unit) and IsValidEntity(rune) and rune:IsCustomRune() then
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