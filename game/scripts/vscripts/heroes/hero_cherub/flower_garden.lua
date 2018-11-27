LinkLuaModifier("modifier_cherub_flower_garden_barrier", "heroes/hero_cherub/modifiers/modifier_cherub_flower_garden_barrier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_cherub_flower_garden_tracker", "heroes/hero_cherub/modifiers/modifier_cherub_flower_garden_tracker", LUA_MODIFIER_MOTION_NONE)

function CreatePlot(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = caster:GetCursorPosition()
	local level = ability:GetLevel() - 1
	if not PLAYER_DATA[caster:GetPlayerID()].Cherub_Flower_Garden then PLAYER_DATA[caster:GetPlayerID()].Cherub_Flower_Garden = {} end
	if PLAYER_DATA[caster:GetPlayerID()].Cherub_Flower_Garden.LatestPlotEntity and not PLAYER_DATA[caster:GetPlayerID()].Cherub_Flower_Garden.LatestPlotEntity:IsNull() and PLAYER_DATA[caster:GetPlayerID()].Cherub_Flower_Garden.LatestPlotEntity:entindex() and PLAYER_DATA[caster:GetPlayerID()].Cherub_Flower_Garden.LatestPlotEntity:IsAlive() then
		PLAYER_DATA[caster:GetPlayerID()].Cherub_Flower_Garden.LatestPlotEntity:ForceKill(false)
		UTIL_Remove(PLAYER_DATA[caster:GetPlayerID()].Cherub_Flower_Garden.LatestPlotEntity)
	end

	local plot = CreateUnitByName("npc_cherub_flower_garden_plot", point, true, caster, caster, caster:GetTeam())
	plot:SetControllableByPlayer(caster:GetPlayerID(), true)
	plot:SetOwner(caster)
	plot:AddNewModifier(caster, ability, "modifier_kill", {duration = ability:GetLevelSpecialValueFor("life_time", ability:GetLevel() - 1)})
	plot:AddNewModifier(caster, ability, "modifier_cherub_flower_garden_tracker", {})
	local health = ability:GetLevelSpecialValueFor("flower_health", level)
	if caster:HasScepter() then
		plot:AddNewModifier(caster, ability, "modifier_cherub_flower_garden_barrier", {})
		health = ability:GetLevelSpecialValueFor("flower_health_scepter", level)
	end

	plot:SetBaseMaxHealth(health)
	plot:SetMaxHealth(health)
	plot:SetHealth(health)
	plot.level = level

	PLAYER_DATA[caster:GetPlayerID()].Cherub_Flower_Garden.LatestPlotEntity = plot

	for i = 0, plot:GetAbilityCount() - 1 do
		local skill = plot:GetAbilityByIndex(i)
		if skill then
			skill:SetLevel(level + 1)
		end
	end
end

function ChooseFlower(keys)
	local caster = keys.caster
	local ability = keys.ability
	for i = 0, caster:GetAbilityCount() - 1 do
		local skill = caster:GetAbilityByIndex(i)
		if skill and skill ~= ability then
			caster:RemoveAbility(skill:GetAbilityName())
		end
	end
	local ability_name = ability:GetAbilityName()
	caster.ability_name = ability_name
	local max_plants = ability:GetLevelSpecialValueFor("max_plants", ability:GetLevel() - 1)
	local attack_rate = ability:GetLevelSpecialValueFor("attack_rate", ability:GetLevel() - 1)
	local hp = caster:GetMaxHealth()
	ReplaceAbilities(caster, ability_name, ability_name .. "_enabled", true, false)

	caster:SetBaseMaxHealth(hp)
	caster:SetMaxHealth(hp)
	caster:SetHealth(hp)

	if caster == PLAYER_DATA[caster:GetPlayerOwnerID()].Cherub_Flower_Garden.LatestPlotEntity then
		PLAYER_DATA[caster:GetPlayerOwnerID()].Cherub_Flower_Garden.LatestPlotEntity = nil
	end
	if not PLAYER_DATA[caster:GetPlayerOwnerID()].Cherub_Flower_Garden[ability_name] then PLAYER_DATA[caster:GetPlayerOwnerID()].Cherub_Flower_Garden[ability_name] = {} end
	table.insert(PLAYER_DATA[caster:GetPlayerOwnerID()].Cherub_Flower_Garden[ability_name], caster)
	if #PLAYER_DATA[caster:GetPlayerOwnerID()].Cherub_Flower_Garden[ability_name] > max_plants then
		local unit = table.remove(PLAYER_DATA[caster:GetPlayerOwnerID()].Cherub_Flower_Garden[ability_name], 1)
		if unit and not unit:IsNull() then
			if unit:IsAlive() then
				unit:ForceKill(false)
			end
			Timers:NextTick(function() UTIL_Remove(unit) end)
		end
	end

	caster:SetModelScale(1)
	if ability_name == "cherub_flower_white_rose" then
		caster:SetModel("models/props_debris/lotus_flower001.vmdl")
		caster:SetOriginalModel("models/props_debris/lotus_flower001.vmdl")
		caster:SetModelScale(0.5)
		--caster:SetRenderColor(255, 255, 255)
		caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
		caster:SetRangedProjectileName("particles/base_attacks/fountain_attack.vpcf")
		caster:SetBaseAttackTime(attack_rate)
	elseif ability_name == "cherub_flower_red_rose" then
		caster:SetModel("models/items/furion/treant_flower_1.vmdl")
		caster:SetOriginalModel("models/items/furion/treant_flower_1.vmdl")
		caster:SetRenderColor(255, 0, 0)
		caster:SetAttackCapability(DOTA_UNIT_CAP_RANGED_ATTACK)
		caster:SetRangedProjectileName("particles/units/heroes/hero_batrider/batrider_base_attack.vpcf")
		caster:SetBaseAttackTime(attack_rate)
	elseif ability_name == "cherub_flower_pink_blossom" then
		caster:SetModel("models/items/furion/treant_flower_1.vmdl")
		caster:SetOriginalModel("models/items/furion/treant_flower_1.vmdl")
		caster:SetRenderColor(220, 0, 255)
	elseif ability_name == "cherub_flower_blue_blossom" then
		caster:SetModel("models/items/furion/flowerstaff.vmdl")
		caster:SetOriginalModel("models/items/furion/flowerstaff.vmdl")
		caster:SetModelScale(0.7)
	elseif ability_name == "cherub_flower_yellow_daisy" then
		caster:SetModel("models/heroes/enchantress/enchantress_flower.vmdl")
		caster:SetOriginalModel("models/heroes/enchantress/enchantress_flower.vmdl")
		caster:SetModelScale(4)
	elseif ability_name == "cherub_flower_purple_lotus" then
		caster:SetModel("models/props_debris/lotus_flower003.vmdl")
		caster:SetOriginalModel("models/props_debris/lotus_flower003.vmdl")
		caster:SetModelScale(0.75)
		caster:SetRenderColor(220, 0, 255)
	end
end

function PinkBlossomThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local allies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("heal_range", ability:GetLevel() - 1), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	table.shuffle(allies)
	for i = 1, ability:GetLevelSpecialValueFor("max_targets", ability:GetLevel() - 1) do
		if allies[i] then
			local amount = ability:GetLevelSpecialValueFor("heal_amount", ability:GetLevel() - 1)
			SafeHeal(allies[i], amount, caster)
			ParticleManager:CreateParticle("particles/neutral_fx/troll_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, allies[i])
			SendOverheadEventMessage(allies[i]:GetPlayerOwner(), OVERHEAD_ALERT_HEAL, allies[i], amount, caster:GetPlayerOwner())
		end
	end
end

function BlueBlossomThink(keys)
	local caster = keys.caster
	local ability = keys.ability
	local allies = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("restore_range", ability:GetLevel() - 1), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	table.shuffle(allies)
	for _,v in ipairs(allies) do
		local amount = ability:GetLevelSpecialValueFor("restore_amount", ability:GetLevel() - 1)
		v:GiveMana(amount)
		ParticleManager:CreateParticle("particles/items_fx/arcane_boots_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
		SendOverheadEventMessage(v:GetPlayerOwner(), OVERHEAD_ALERT_MANA_ADD, v, amount, caster:GetPlayerOwner())
	end
end
