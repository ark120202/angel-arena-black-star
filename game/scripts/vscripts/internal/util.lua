function CPrint( ... )
	if SendDebugInfoToClient then
		local player
		for i = 0, DOTA_MAX_TEAM_PLAYERS-1 do
			if PlayerResource:IsValidPlayerID(i) and not IsPlayerAbandoned(i) and CustomWearables:HasWearable(i, "wearable_developer") then
				player = PlayerResource:GetPlayer(i)
			end
		end
		if player then
			local printResult = ""
			for _,v in ipairs({...}) do
				printResult = printResult .. tostring(v) .. "\t"
			end
			CustomGameEventManager:Send_ServerToPlayer(player, "debug_cprint", {text = printResult})
		end
	end
end

function DebugPrint(...)
	local spew = Convars:GetInt('barebones_spew') or -1
	if spew == -1 and BAREBONES_DEBUG_SPEW then
		spew = 1
	end

	if spew == 1 then
		print(...)
	end
end

function DebugPrintTable(...)
	local spew = Convars:GetInt('barebones_spew') or -1
	if spew == -1 and BAREBONES_DEBUG_SPEW then
		spew = 1
	end

	if spew == 1 then
		PrintTable(...)
	end
end


function CPrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
	if type(t) ~= "table" then return end

	done = done or {}
	done[t] = true
	if not indent then
		CPrint("Printing table")
	end
	indent = indent or 1

	local l = {}
	for k, v in pairs(t) do
		table.insert(l, k)
	end

	table.sort(l)
	for k, v in ipairs(l) do
		-- Ignore FDesc
		if v ~= 'FDesc' then
			local value = t[v]
			if type(value) == "table" and not done[value] then
				done [value] = true
				CPrint(string.rep ("\t", indent)..tostring(v)..":")
				CPrintTable(value, indent + 2, done)
			elseif type(value) == "userdata" and not done[value] then
				done [value] = true
				CPrint(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
				CPrintTable((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
			else
				if t.FDesc and t.FDesc[v] then
					CPrint(string.rep ("\t", indent)..tostring(t.FDesc[v]))
				else
					CPrint(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
				end
			end
		end
	end
end

function PrintTable(t, indent, done)
	--print ( string.format ('PrintTable type %s', type(keys)) )
	if type(t) ~= "table" then return end

	done = done or {}
	done[t] = true
	if not indent then
		print("Printing table")
	end
	indent = indent or 1

	local l = {}
	for k, v in pairs(t) do
		table.insert(l, k)
	end

	table.sort(l)
	for k, v in ipairs(l) do
		-- Ignore FDesc
		if v ~= 'FDesc' then
			local value = t[v]
			if type(value) == "table" and not done[value] then
				done [value] = true
				print(string.rep ("\t", indent)..tostring(v)..":")
				PrintTable (value, indent + 2, done)
			elseif type(value) == "userdata" and not done[value] then
				done [value] = true
				print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
				PrintTable ((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
			else
				if t.FDesc and t.FDesc[v] then
					print(string.rep ("\t", indent)..tostring(t.FDesc[v]))
				else
					print(string.rep ("\t", indent)..tostring(v)..": "..tostring(value))
				end
			end
		end
	end
end

-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


function DebugAllCalls()
	if not GameRules.DebugCalls then
		print("Starting DebugCalls")
		GameRules.DebugCalls = true

		debug.sethook(function(...)
			local info = debug.getinfo(2)
			local src = tostring(info.short_src)
			local name = tostring(info.name)
			if name ~= "__index" then
				print("Call: ".. src .. " -- " .. name .. " -- " .. info.currentline)
			end
		end, "c")
	else
		print("Stopped DebugCalls")
		GameRules.DebugCalls = false
		debug.sethook(nil, "c")
	end
end

-----------------------------------------------------------------------------------------------

function string.starts(s, start)
	return string.sub(s, 1, string.len(start)) == start
end

function string.ends(s, e)
	return e == "" or string.sub(s, -string.len(e)) == e
end

function GetAllPlayers(bOnlyWithHeroes)
	local Players = {}
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1  do
		if PlayerResource:IsValidPlayerID(playerID) then
			local player = PlayerResource:GetPlayer(playerID)
			if player and ((bOnlyWithHeroes and player:GetAssignedHero()) or not bOnlyWithHeroes) then
				table.insert(Players, player)
			end
		end
	end
	return Players
end

function CreateHeroNameNotificationSettings(hHero, flDuration)
	if hHero.GetPlayerID then
		local textColor = ColorTableToCss(PLAYER_DATA[hHero:GetPlayerID()].Color or {0, 0, 0})
		local output = {text=PlayerResource:GetPlayerName(hHero:GetPlayerID()), duration=flDuration, continue=true, style={color=textColor}}
		return output
	end
end

function CreateTeamNotificationSettings(iTeam, bSecVar)
	local textColor = ColorTableToCss(TEAM_COLORS[iTeam])
	local text = TEAM_NAMES[iTeam]
	if bSecVar then
		text = TEAM_NAMES2[iTeam]
	end
	local output = {text=text, continue=true, style={color=textColor}}
	return output
end

function CreateItemNotificationSettings(sItemName)
	return {text= "#DOTA_Tooltip_ability_" .. sItemName, duration=7.0, continue=true, style={color="orange"}}
end

function GetDOTATimeInMinutes()
	return GameRules:GetDOTATime(false, false)/60
end

function GetDOTATimeInMinutesFull()
	return math.floor(GetDOTATimeInMinutes())
end

function table.removeByValue(t, value)
	for i,v in pairs(t) do
		if v == value then
			table.remove(t, i)
		end
	end
end

function CreatePortal(vLocation, vTarget, iRadius, sParticle, sDisabledParticle, bEnabled, fOptionalActOnTeleport, sOptionalName)
	local unit = CreateUnitByName("npc_dummy_unit", vLocation, false, nil, nil, DOTA_TEAM_NEUTRALS)
	unit.Teleport_Radius = iRadius
	unit.Teleport_Target = vTarget
	unit.Teleport_ParticleName = sParticle
	unit.Teleport_DisabledParticleName = sDisabledParticle
	unit.Teleport_ActionOnTeleport = fOptionalActOnTeleport
	unit.Teleport_Name = sOptionalName
	unit.Teleport_Enabled = not bEnabled
	unit:AddAbility("teleport_passive")
	if bEnabled then
		unit:EnablePortal()
	else
		unit:DisablePortal()
	end
	return unit
end

function CreateLoopedPortal(point1, point2, iRadius, sParticle, sDisabledParticle, bEnabled, fOptionalActOnTeleport, sOptionalName)
	for i = 1, 2 do
		local point
		local target
		if i == 1 then
			point = point1
			target = point2
		else
			point = point2
			target = point1
		end
		local unit = CreateUnitByName("npc_dummy_unit", point, false, nil, nil, DOTA_TEAM_NEUTRALS)
		unit.Teleport_Radius = iRadius
		unit.Teleport_Target = target
		unit.Teleport_ParticleName = sParticle
		unit.Teleport_DisabledParticleName = sDisabledParticle
		unit.Teleport_ActionOnTeleport = fOptionalActOnTeleport
		unit.Teleport_Name = sOptionalName
		unit.Teleport_Enabled = not bEnabled
		unit.Teleport_Looped = true
		unit:AddAbility("teleport_passive")
		if bEnabled then
			unit:EnablePortal()
		else
			unit:DisablePortal()
		end
	end
	return unit
end

function table.swap(array, index1, index2)
	array[index1], array[index2] = array[index2], array[index1]
end

function table.shuffle(array)
	local counter = #array
	while counter > 1 do
		local index = RandomInt(1, counter)
		table.swap(array, index, counter)
		counter = counter - 1
	end
end

function table.contains(table, element)
	if table then
		for _, value in pairs(table) do
			if value == element then
				return true
			end
		end
	end
	return false
end

function GetFilteredGold(amount)
	return amount
end

function CreateGoldNotificationSettings(amount)
	return {text=amount, duration=flDuration, continue=true, style={color="gold"}}, {text="#notifications_gold", continue=true, style={color="gold"}}
end

function table.firstNotNil(table)
	for _,v in pairs(table) do
		if v ~= nil then
			return v
		end
	end
end

function table.allEqual(table, value)
	for _,v in pairs(table) do
		if v ~= value then
			return false
		end
	end
	return true
end

function table.areAllEqual(table)
	for _,v in pairs(table) do
		if value == nil then
			value = v
		end
		if v ~= value then
			return false
		end
	end
	return true
end

function table.allEqualExpectOne(table, value)
	local miss = false
	for _,v in pairs(table) do
		if v ~= value then
			if miss then
				return false
			else
				miss = true
			end
		end
	end
	return true
end

function table.iterate(inputTable)
	local toutput = {}
	for _,v in pairs(inputTable) do
		table.insert(toutput, v)
	end
	return toutput
end

function table.iterateKeys(inputTable)
	local toutput = {}
	for k,_ in pairs(inputTable) do
		table.insert(toutput, k)
	end
	return toutput
end

function ModifyStacks(ability, caster, unit, modifier, stack_amount, refresh)
	if stack_amount > 0 then
		return AddStacks(ability, caster, unit, modifier, stack_amount, refresh)
	elseif stack_amount < 0 then
		return RemoveStacks(ability, unit, modifier, -stack_amount)
	end
end

function AddStacks(ability, caster, unit, modifier, stack_amount, refresh)
	if unit:HasModifier(modifier) then
		if refresh then
			ability:ApplyDataDrivenModifier(caster, unit, modifier, {})
		end
		unit:SetModifierStackCount(modifier, ability, unit:GetModifierStackCount(modifier, ability) + stack_amount)
	else
		ability:ApplyDataDrivenModifier(caster, unit, modifier, {})
		unit:SetModifierStackCount(modifier, ability, stack_amount)
	end
	return unit:FindModifierByNameAndCaster(modifier, caster)
end

function RemoveStacks(ability, unit, modifier, stack_amount)
	if unit:HasModifier(modifier) then
		if unit:GetModifierStackCount(modifier, ability) > stack_amount then
			unit:SetModifierStackCount(modifier, ability, unit:GetModifierStackCount(modifier, ability) - stack_amount)
		else
			unit:RemoveModifierByName(modifier)
		end
	end
end

function ModifyStacksLua(ability, caster, unit, modifier, stack_amount, refresh, modifierTable)
	if stack_amount > 0 then
		AddStacksLua(ability, caster, unit, modifier, stack_amount, refresh, modifierTable)
	elseif stack_amount < 0 then
		RemoveStacks(ability, unit, modifier, stack_amount)
	end
end

function AddStacksLua(ability, caster, unit, modifier, stack_amount, refresh, data)
	local modifierTable = data or {}
	if unit:HasModifier(modifier) then
		if refresh then
			unit:AddNewModifier(caster, ability, modifier, modifierTable)
		end
		unit:SetModifierStackCount(modifier, ability, unit:GetModifierStackCount(modifier, ability) + stack_amount)
	else
		unit:AddNewModifier(caster, ability, modifier, modifierTable)
		unit:SetModifierStackCount(modifier, ability, stack_amount)
	end
end

function HasFreeSlot(unit)
	for i = 0, 5 do
		if not unit:GetItemInSlot(i) then
			return true
		end
	end
	return false
end

function GetEnemiesIds(heroteam)
	local enemies = {}
	for _,playerID in ipairs(GetAllPlayers(false)) do
		if PlayerResource:GetTeam(playerID:GetPlayerID()) ~= heroteam then
			table.insert(enemies, playerID)
		end
	end
	return enemies
end

function BShowBubble(unit)
	if not unit.HasSpeechBubble and not unit.Inactive then
		local text = "#bitch_lina_bubble_text"
		unit:AddSpeechBubble(1, text, 9999999, 10, -35)
		unit.HasSpeechBubble = true
	end
end

function GenerateAttackProjectile(unit, optAbility)
	local projectile_info = {}
	projectile_info = {
		EffectName = unit:GetKeyValue("ProjectileModel"),
		Ability = optAbility,
		vSpawnOrigin = unit:GetAbsOrigin(),
		Source = unit,
		bHasFrontalCone = false,
		iMoveSpeed = unit:GetKeyValue("ProjectileSpeed") or 99999,
		bReplaceExisting = false,
		bProvidesVision = false
	}
	return projectile_info
end

function IsRangedUnit(unit)
	return unit:IsRangedAttacker() or unit:HasModifier("modifier_terrorblade_metamorphosis_transform_aura_applier")
end

function swap_to_item(unit, srcItem, newItem)
	FillSlotsWithDummy(unit)
	if unit:HasItemInInventory(srcItem:GetName()) then
		unit:RemoveItem(srcItem)
		unit:AddItem(newItem)
	end
	
	ClearSlotsFromDummy(unit)
end

function FindItemInInventoryByName(unit, itemname, searchStash, onlyStash, ignoreBackpack)
	local lastSlot = ignoreBackpack and DOTA_ITEM_SLOT_6 or DOTA_ITEM_SLOT_9
	local startSlot = 0
	if searchStash then lastSlot = DOTA_STASH_SLOT_6 end
	if onlyStash then startSlot = DOTA_STASH_SLOT_1 end
	for slot = startSlot, lastSlot do
		local item = unit:GetItemInSlot(slot)
		if item and item:GetAbilityName() == itemname then
			return item
		end
	end
end

function RemoveDeathPreventingModifiers(unit)
	for _,v in ipairs(MODIFIERS_DEATH_PREVENTING) do
		unit:RemoveModifierByName(v)
	end
end

function TrueKill(killer, ability, target)
	target.IsMarkedForTrueKill = true
	target:Kill(ability, killer)
	if not target:IsNull() and target:IsAlive() then
		RemoveDeathPreventingModifiers(target)
		target:Kill(ability, killer)
	end
	target.IsMarkedForTrueKill = false
end

function CDOTA_BaseNPC:TrueKill(ability, killer)
	TrueKill(killer, ability, self)
end

function table.count(inputTable)
	local counter = 0
	for _,_ in pairs(inputTable) do
		counter = counter + 1
	end
	return counter
end

function FindFountain(team)
	return Entities:FindByName(nil, "npc_arena_fountain_" .. team)
end

function pairsByKeys(t, f)
	local a = {}
	for n in pairs(t) do table.insert(a, n) end
	table.sort(a, f)
	local i = 0
	local iter = function()
		i = i + 1
		if a[i] == nil then
			return nil
		else
			return a[i], t[a[i]]
		end
	end
	return iter
end

function AbilityHasBehaviorByName(ability_name, behaviorString)
	local AbilityBehavior = GetKeyValue(ability_name, "AbilityBehavior")
	if AbilityBehavior then
		local AbilityBehaviors = string.split(AbilityBehavior, " | ")
		return table.contains(AbilityBehaviors, behaviorString)
	end
	return false
end

function AbilityHasBehavior(ability, behavior)
	return bit.band( ability:GetBehavior(), behavior) == behavior
end

function table.merge(input1, input2)
	for i,v in pairs(input2) do
		input1[i] = v
	end
end

function DrugEffectStrangeMove(target, amplitude)
	if not target:IsStunned() then
		FindClearSpaceForUnit(target, target:GetAbsOrigin() + Vector(RandomInt(-amplitude, amplitude), RandomInt(-amplitude, amplitude), 0), false)
	end
end

function DrugEffectRandomParticles(target, duration)
	--TODO Different particles
	for _,v in ipairs(FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)) do
		local particle = ParticleManager:CreateParticleForPlayer("particles/dark_smoke_test.vpcf", PATTACH_ABSORIGIN, v, target:GetPlayerOwner())
		Timers:CreateTimer(duration, function()
			ParticleManager:DestroyParticle(particle, false)
		end)
	end
end

function GetDrugDummyAbility(itemName)
	local abilityName = string.gsub(itemName, "item_", "dummy_drug_")
	local ability = DRUG_DUMMY:AddAbility(abilityName)
	return ability
end

function GetLevelValue(value, level)
	local split = {}
	for i in string.gmatch(value, "%S+") do
		table.insert(split, i)
	end
	if i[level+1] then
		return split[level+1]
	end
end

function SpendCharge(item, amount)
	local charges = item:GetCurrentCharges()
	local newCharges = charges - amount
	if newCharges < 1 then
		UTIL_Remove(item)
	else
		item:SetCurrentCharges(newCharges)
	end
end

function GetAbilityCooldown(unit, ability)
	local level = ability:GetLevel() - 1
	if level < 0 then level = 0 end
	local cd = ability:GetCooldown(level)
	local vs = {}
	for k,v in pairs(COOLDOWN_REDUCTION_ABILITIES) do
		if unit:HasItemInInventory(k) and not vs[v.reductionGroup] then
			vs[v.reductionGroup] = true
			if v.reductionType == "percent" then
				cd = cd * (100 - v.reduction) * 0.01
			elseif v.reductionType == "constant" then
				cd = cd - v.reduction
			end
		end
	end
	return cd
end

function PreformAbilityPrecastActions(unit, ability)
	if ability:IsCooldownReady() and ability:IsOwnersManaEnough() then
		ability:PayManaCost()
		ability:StartCooldown(GetAbilityCooldown(unit, ability))
		--ability:UseResources(true, true, true) -- not works with items?
		return true
	end
	return false
end

function ReplaceAbilities(unit, oldAbility, newAbility, keepLevel, keepCooldown)
	local ability = unit:FindAbilityByName(oldAbility)
	local level = ability:GetLevel()
	local cooldown = ability:GetCooldownTimeRemaining()
	unit:RemoveAbility(oldAbility)
	local new_ability = unit:AddAbility(newAbility)
	if keepLevel then
		new_ability:SetLevel(level)
	end
	if keepCooldown then
		new_ability:StartCooldown(cooldown)
	end
	return new_ability
end

function PreformMulticast(caster, ability_cast, multicast, multicast_delay, target)
	if IsAbilityMulticastable(ability_cast) then
		local prt = ParticleManager:CreateParticle('particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf', PATTACH_OVERHEAD_FOLLOW, caster)
		ParticleManager:SetParticleControl(prt, 1, Vector(multicast, 0, 0))
		prt = ParticleManager:CreateParticle('particles/units/heroes/hero_ogre_magi/ogre_magi_multicast_b.vpcf', PATTACH_OVERHEAD_FOLLOW, caster:GetCursorCastTarget() or caster)
		prt = ParticleManager:CreateParticle('particles/units/heroes/hero_ogre_magi/ogre_magi_multicast_b.vpcf', PATTACH_OVERHEAD_FOLLOW, caster)
		prt = ParticleManager:CreateParticle('particles/units/heroes/hero_ogre_magi/ogre_magi_multicast_c.vpcf', PATTACH_OVERHEAD_FOLLOW, caster:GetCursorCastTarget() or caster)
		ParticleManager:SetParticleControl(prt, 1, Vector(multicast, 0, 0))
		CastMulticastedSpell(caster, ability_cast, target, multicast-1, multicast_delay)
	end
end

function CastMulticastedSpell(caster, ability, target, multicasts, delay)
	if multicasts >= 1 then
		Timers:CreateTimer(delay, function()
			CastAdditionalAbility(caster, ability, target)
			caster:EmitSound('Hero_OgreMagi.Fireblast.x'.. multicasts)
			if multicasts >= 2 then
				CastMulticastedSpell(caster, ability, target, multicasts - 1, delay)
			end
		end)
	end
end

function CastAdditionalAbility(caster, ability, target)
	local skill = ability
	local unit = caster
	local channelled = false
	if AbilityHasBehavior(ability, DOTA_ABILITY_BEHAVIOR_CHANNELLED) then
		local dummy = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
		--TODO сделать чтобы дамаг от скилла умножался от инты.
		for i = 0, DOTA_ITEM_SLOT_9 do
			local citem = caster:GetItemInSlot(i)
			if citem then
				dummy:AddItem(CopyItem(citem))
			end
		end
		if caster:HasScepter() then dummy:AddNewModifier(caster, nil, "modifier_item_ultimate_scepter", {}) end
		dummy:SetControllableByPlayer(caster:GetPlayerID(), true)
		dummy:SetOwner(caster)
		dummy:SetAbsOrigin(caster:GetAbsOrigin())
		dummy.GetStrength = function()
			return caster:GetStrength()
		end
		dummy.GetAgility = function()
			return caster:GetAgility()
		end
		dummy.GetIntellect = function()
			return caster:GetIntellect()
		end
		skill = dummy:AddAbility(ability:GetName())
		unit = dummy
		skill:SetLevel(ability:GetLevel())
		channelled = true
	end
	if AbilityHasBehavior(skill, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
		if target and type(target) == "table" then
			unit:SetCursorCastTarget(target)
		end
	elseif AbilityHasBehavior(skill, DOTA_ABILITY_BEHAVIOR_POINT) then
		if target and target.x and target.y and target.z then
			unit:SetCursorPosition(target)
		end
	end
	skill:OnSpellStart()
	if channelled then
		Timers:CreateTimer(0.03, function()
			if not caster:IsChanneling() then
				skill:EndChannel(true)
				skill:OnChannelFinish(true)
				Timers:CreateTimer(0.03, function()
					if skill then UTIL_Remove(skill) end
					if unit then UTIL_Remove(unit) end
				end)
			else
				return 0.03
			end
		end)
	end
end

function IsAbilityMulticastable(ability)
	if AbilityHasBehavior(ability, DOTA_ABILITY_BEHAVIOR_PASSIVE) or table.contains(NOT_MULTICASTABLE_ABILITIES, ability:GetName()) then
		return false
	end
	return true
end

function HasScepter(unit)
	return unit:HasScepter()
end

function IsHeroInAbilityPhase(unit)
	for i = 0, unit:GetAbilityCount()-1 do
		local ability = unit:GetAbilityByIndex(i)
		if ability and ability.IsInAbilityPhase and ability:IsInAbilityPhase() then
			return true
		end
	end
	for i = 0, 5 do
		local item = unit:GetItemInSlot(i)
		if item and item.IsInAbilityPhase and item:IsInAbilityPhase() then
			return true
		end
	end
	return false
end

function table.highest(t)
	if #t < 1 then
		return
	end
	table.sort(t)
	return(t[#t])
end

function GetAllAbilitiesCooldowns(unit)
	local cooldowns = {}
	for i = 0, unit:GetAbilityCount()-1 do
		local ability = unit:GetAbilityByIndex(i)
		if ability then
			table.insert(cooldowns, GetAbilityCooldown(unit, ability))
		end
	end
	return cooldowns
end

function RefreshAbilities(unit, tExceptions)
	for i = 0, unit:GetAbilityCount()-1 do
		local ability = unit:GetAbilityByIndex(i)
		if ability and (not tExceptions or not table.contains(tExceptions, ability:GetName())) then
			ability:EndCooldown()
		end
	end
end

function RefreshItems(unit, tExceptions)
	for i = 0, 5 do
		local item = unit:GetItemInSlot(i)
		if item and (not tExceptions or not table.contains(tExceptions, item:GetName())) then
			item:EndCooldown()
		end
	end
end

--illusion_incoming_damage = tooltip - 100
--illusion_outgoing_damage = tooltip - 100
function CreateIllusion(unit, ability, illusion_origin, illusion_incoming_damage, illusion_outgoing_damage, illusion_duration)
	local unitname = GetFullHeroName(unit)
	local illusion = CreateUnitByName(unit:GetUnitName(), illusion_origin, true, unit, unit:GetPlayerOwner(), unit:GetTeamNumber())
	FindClearSpaceForUnit(illusion, illusion_origin, true)
	illusion:SetModelScale(unit:GetModelScale())
	illusion:SetControllableByPlayer(unit:GetPlayerID(), true)

	local caster_level = unit:GetLevel()
	for i = 1, caster_level - 1 do
		illusion:HeroLevelUp(false)
	end

	illusion:SetAbilityPoints(0)
	for ability_slot = 0, unit:GetAbilityCount()-1 do
		local i_ability = illusion:GetAbilityByIndex(ability_slot)
		if i_ability then
			illusion:RemoveAbility(i_ability:GetAbilityName())
		end

		local individual_ability = unit:GetAbilityByIndex(ability_slot)
		if individual_ability then 
			local illusion_ability = illusion:AddAbility(individual_ability:GetName())
			illusion_ability:SetLevel(individual_ability:GetLevel())
		end
	end
	for item_slot = 0, 5 do
		local item = unit:GetItemInSlot(item_slot)
		if item then
			local illusion_item = illusion:AddItem(CreateItem(item:GetName(), illusion, illusion))
			illusion_item:SetCurrentCharges(item:GetCurrentCharges())
		end
	end
	illusion:SetHealth(unit:GetHealth())
	illusion:SetMana(unit:GetMana())
	illusion:AddNewModifier(unit, ability, "modifier_illusion", {duration = illusion_duration, outgoing_damage = illusion_outgoing_damage, incoming_damage = illusion_incoming_damage})
	illusion:MakeIllusion()
	if unit.Additional_str then
		illusion:ModifyStrength(unit.Additional_str)
	end
	if unit.Additional_agi then
		illusion:ModifyAgility(unit.Additional_agi)
	end
	if unit.Additional_int then
		illusion:ModifyIntellect(unit.Additional_int)
	end
	if unit.Additional_attackspeed then
		if not illusion:HasModifier("modifier_item_shard_attackspeed_stack") then
			illusion:AddNewModifier(caster, nil, "modifier_item_shard_attackspeed_stack", {})
		end
		local mod = illusion:FindModifierByName("modifier_item_shard_attackspeed_stack")
		if mod then
			mod:SetStackCount(unit.Additional_attackspeed)
		end
	end
	illusion.UnitName = unit.UnitName
	illusion:SetNetworkableEntityInfo("unit_name", GetFullHeroName(illusion))
	if NPC_HEROES_CUSTOM[unitname] then
		TransformUnitClass(illusion, NPC_HEROES_CUSTOM[unitname], true)
	end
	--[[illusion.CustomGain_Strength = unit.CustomGain_Strength
	illusion.CustomGain_Intelligence = unit.CustomGain_Intelligence
	illusion.CustomGain_Agility = unit.CustomGain_Agility
	illusion:SetNetworkableEntityInfo("AttributeStrengthGain", unit.CustomGain_Strength)
	illusion:SetNetworkableEntityInfo("AttributeIntelligenceGain", unit.CustomGain_Intelligence)
	illusion:SetNetworkableEntityInfo("AttributeAgilityGain", unit.CustomGain_Agility)]]
	if unit:GetModelName() ~= illusion:GetModelName() then
		illusion.ModelOverride = unit:GetModelName()
		illusion:SetModel(illusion.ModelOverride)
		illusion:SetOriginalModel(illusion.ModelOverride)
	end
	
	return illusion
end

function table.findIndex(t, value)
	local values = {}
	for i,v in ipairs(t) do
		if v == value then
			table.insert(values, i)
		end
	end
	return values
end

function PerformGlobalAttack(unit, hTarget, bUseCastAttackOrb, bProcessProcs, bSkipCooldown, bIgnoreInvis, bUseProjectile, bFakeAttack, bNeverMiss, AttackFuncs)
	local abs = unit:GetAbsOrigin()
	unit:SetAbsOrigin(hTarget:GetAbsOrigin())
	SafePerformAttack(unit, hTarget, bUseCastAttackOrb, bProcessProcs, bSkipCooldown, bIgnoreInvis, bUseProjectile, bFakeAttack, bNeverMiss, AttackFuncs)
	unit:SetAbsOrigin(abs)
end

function SafePerformAttack(unit, hTarget, bUseCastAttackOrb, bProcessProcs, bSkipCooldown, bIgnoreInvis, bUseProjectile, bFakeAttack, bNeverMiss, AttackFuncs)
	--bNoSplashesMelee, bNoSplashesRanged, bNoDoubleAttackMelee, bNoDoubleAttackRanged
	if AttackFuncs then
		if not unit.AttackFuncs then unit.AttackFuncs = {} end
		table.merge(unit.AttackFuncs, AttackFuncs)
	end
	unit:PerformAttack(hTarget,bUseCastAttackOrb,bProcessProcs,bSkipCooldown,bIgnoreInvis,bUseProjectile,bFakeAttack,bNeverMiss)
	unit.AttackFuncs = nil
end

function UniqueRandomInts(min, max, count)
	local output = {}
	while #output < count do
		local r = RandomInt(min, max)
		if not table.contains(output, r) then
			table.insert(output, r)
		end
	end
	return output
end

function ColorTableToCss(color)
	return "rgb(" .. color[1] .. ',' .. color[2] .. ',' .. color[3] .. ')'
end

function IsPlayerAbandoned( playerID )
	return PLAYER_DATA[playerID].IsAbandoned
end

function FindAllOwnedUnits(player)
	local summons = {}
	local units = FindUnitsInRadius(PlayerResource:GetTeam(player:GetPlayerID()), Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)
	for _,v in ipairs(units) do
		if v:GetPlayerOwner() == player and not (v:HasModifier("modifier_dummy_unit") or v:HasModifier("modifier_containers_shopkeeper_unit") or v:HasModifier("modifier_teleport_passive")) and v ~= hero then
			table.insert(summons, v)
		end
	end
	return summons
end

function table.icontains(table, element)
	for _, value in ipairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

function GetTeamPlayerCount(iTeam)
	local counter = 0
	for i = 0, 23 do
		if PlayerResource:IsValidPlayerID(i) and not IsPlayerAbandoned(i) then
			if PlayerResource:GetTeam(i) == iTeam then
				counter = counter + 1
			end
		end
	end
	return counter
end

function GetAllPlayerCount(iTeam)
	local counter = 0
	for i = DOTA_TEAM_FIRST, DOTA_TEAM_CUSTOM_MAX do
		counter = counter + GetTeamPlayerCount(i)
	end
	return counter
end

function MakePlayerAbandoned(iPlayerID)
	if not PLAYER_DATA[iPlayerID].IsAbandoned then
		local hero = PlayerResource:GetSelectedHeroEntity(iPlayerID)
		if hero then
			hero:ClearNetworkableEntityInfo()
			Notifications:TopToAll({hero=hero:GetName(), duration=10.0})
			Notifications:TopToAll(CreateHeroNameNotificationSettings(hero))
			Notifications:TopToAll({text="#game_player_abandoned_game", continue=true})
			hero:Stop()
			for i = 0, DOTA_STASH_SLOT_6 do
				local citem = hero:GetItemInSlot(i)
				if citem then
					hero:SellItem(citem)
					Gold:UpdatePlayerGold(iPlayerID)
				end
			end
			hero:DestroyAllModifiers()
			Timers:CreateTimer(function()
				UTIL_Remove(hero)
			end)
		end
		local ptd = PlayerTables:GetTableValue("arena", "players_abandoned")
		table.insert(ptd, iPlayerID)
		PlayerTables:SetTableValue("arena", "players_abandoned", ptd)
		PLAYER_DATA[iPlayerID].IsAbandoned = true
		if not GameRules:IsCheatMode() then
			local teamLeft
			for i = DOTA_TEAM_FIRST, DOTA_TEAM_CUSTOM_MAX do
				local count = GetTeamPlayerCount(i)
				if count > 0 then
					if teamLeft then
						return
					else
						teamLeft = i
					end
				end
			end
			if teamLeft then
				GameRules:SetSafeToLeave(true)
				GameRules:SetGameWinner(teamLeft)
			end
		end
	end
end

function ClearFalseInnateModifiers(unit, ability)
	if ability:GetKeyValue("HasInnateModifiers") ~= 1 then
		for _,v in ipairs(unit:FindAllModifiers()) do
			if v:GetAbility() and v:GetAbility() == ability then
				v:Destroy()
			end
		end
	end
end

function AddNewAbility(unit, ability_name, skipLinked)
	local hAbility = unit:AddAbility(ability_name)
	ClearFalseInnateModifiers(unit, hAbility)
	local linked
	local link = LINKED_ABILITIES[ability_name]
	if link and not skipLinked then
		linked = {}
		for _,v in ipairs(link) do
			local h, _ = AddNewAbility(unit, v)
			table.insert(linked, h)
		end
	end
	return hAbility, linked
end

function CopyItem(item)
	local newItem = CreateItem(item:GetAbilityName(), caster, caster)
	newItem:SetPurchaseTime(item:GetPurchaseTime())
	newItem:SetPurchaser(item:GetPurchaser())
	newItem:SetOwner(item:GetOwner())
	newItem:SetCurrentCharges(item:GetCurrentCharges())
	return newItem
end

function math.round(x)
	if x%2 ~= 0.5 then
		return math.floor(x+0.5)
	end
	return x-0.5
end

function SafeHeal(unit, flAmount, hInflictor)
	if unit:IsAlive() then
		unit:Heal(flAmount, hInflictor)
	end
end

function InvokeCheatCommand(s)
	Convars:SetInt("sv_cheats", 1)
	SendToServerConsole(s)
end

function UnitVarToPlayerID(unitvar)
	if unitvar then
		if type(unitvar) == "number" then
			return unitvar
		elseif type(unitvar) == "table" and not unitvar:IsNull() and unitvar.entindex and unitvar:entindex() then
			if unitvar.GetPlayerID and unitvar:GetPlayerID() > -1 then
				return unitvar:GetPlayerID()
			elseif unitvar.GetPlayerOwnerID then
				return unitvar:GetPlayerOwnerID()
			end
		end
	end
	return -1
end

function CreateSimpleBox(point1, point2)
	local hlen = point2.y-point1.y
	local cen = point1.y+hlen/2
	point1.y = cen
	point2.y = cen
	point1.z = 0
	return Physics:CreateBox(point2, point1, hlen, true)
end

function CDOTA_BaseNPC:IsRealCreep()
	return self.SSpawner ~= nil and self.SpawnerType ~= nil
end

function FindUnitsInBox(teamNumber, vStartPos, vEndPos, cacheUnit, teamFilter, typeFilter, flagFilter)
	local hlen = (vEndPos.y-vStartPos.y) / 2
	local cen = vStartPos.y+hlen
	vStartPos.y = cen
	vEndPos.y = cen
	vStartPos.z = 0
	vEndPos.z = 0
	return FindUnitsInLine(teamNumber, vStartPos, vEndPos, cacheUnit, hlen, teamFilter, typeFilter, flagFilter)
end

function string.split(inputstr, sep)
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. (sep or "%s") .. "]+)") do
		table.insert(t, str)
	end
	return t
end

function GetTrueItemCost(name)
	local cost = GetItemCost(name)
	if cost <= 0 then
		local tempItem = CreateItem(name, nil, nil)
		if not tempItem then
			print("[GetTrueItemCost] Warning: " .. name)
		else
			cost = tempItem:GetCost()
		end
	end
	return cost
end

function FindNearestEntity(vec3, units)
	local unit
	local range
	for _,v in ipairs(units) do
		if not range or (v:GetAbsOrigin()-vec3):Length2D() < range then
			unit = v
			range = (v:GetAbsOrigin()-vec3):Length2D()
		end
	end
	return unit
end

function FindCourier(team) 
	return TEAMS_COURIERS[team]
end

function GetNotScaledDamage(damage, unit)
	return math.floor(damage/(1 + (unit:GetIntellect() / 16) / 100) + 0.5)
end

function GetSpellDamageAmplify(unit)
	return unit:GetIntellect() * 0.0625
end

function CDOTA_BaseNPC:GetSpellDamageAmplify()
	return GetSpellDamageAmplify(self)
end

function IsUltimateAbility(ability)
	return bit.band(ability:GetAbilityType(), 1) == 1
end

function IsUltimateAbilityKV(abilityname)
	return GetKeyValue(abilityname, "AbilityType") == "DOTA_ABILITY_TYPE_ULTIMATE"
end

function CastConfiguratedPsiSpell(caster, ability, configuration)
	-- body
end

function PurgeTruesightModifiers(unit)
	for _,v in ipairs(MODIFIERS_TRUESIGHT) do
		unit:RemoveModifierByName(v)
	end
end

function RandomPositionAroundPoint(pos, radius)
	return RotatePosition(pos, QAngle(0, RandomInt(0,359), 0), pos + Vector(1, 1, 0) * RandomInt(0, radius))
end

function EvalString(str)
	local status, nextCall = xpcall(loadstring(str), function(msg) return msg..'\n'..debug.traceback()..'\n' end)
	if not status then
		print(nextCall)
	end
end

function GetPlayersInTeam(team)
	local players = {}
	for playerID = 0, DOTA_MAX_TEAM_PLAYERS-1  do
		if PlayerResource:IsValidPlayerID(playerID) and (not team or PlayerResource:GetTeam(playerID) == team) and not PLAYER_DATA[playerID].IsAbandoned then
			table.insert(players, playerID)
		end
	end
	return players
end

function CDOTA_BaseNPC:IsHoldoutUnit()
	return self.HoldoutSpawner and self.HoldoutWave
end

function RemoveAbilityWithModifiers(unit, ability)
	for _,v in ipairs(unit:FindAllModifiers()) do
		if v:GetAbility() == ability then
			v:Destroy()
		end
	end
	if ability:GetAbilityName() == "pudge_meat_hook_lua" then
		ability:DestroyHookParticles()
	end
	unit:RemoveAbility(ability:GetAbilityName())
end

function CreateGlobalParticle(name, callback, pattach)
	local ps = {}
	for team = DOTA_TEAM_FIRST, DOTA_TEAM_CUSTOM_MAX do
		local f = FindFountain(team)
		if f then
			local p = ParticleManager:CreateParticleForTeam(name, pattach or PATTACH_WORLDORIGIN, f, team)
			callback(p)
			table.insert(ps, p)
		end
	end
	return ps
end

function table.add(input1, input2)
	for _,v in ipairs(input2) do
		table.insert(input1, v)
	end
end

function table.addExclusive(input1, input2)
	for _,v in ipairs(input2) do
		if not table.contains(input1, v) then
			table.insert(input1, v)
		end
	end
end

function WorldPosToMinimap(vec)
	local pct1 = ((vec.x + MAP_LENGTH) / (MAP_LENGTH * 2))
	local pct2 = ((MAP_LENGTH - vec.y) / (MAP_LENGTH * 2))
	return pct1*100 .. "% " .. pct2*100 .. "%"
end

function GetHeroTableByName(name)
	local output = {}
	local default = NPC_HEROES[name]
	local custom = NPC_HEROES_CUSTOM[name]
	if not custom then
		print("[GetHeroTableByName] Missing hero: " .. name)
		return
	end
	if custom.base_hero then
		table.merge(output, NPC_HEROES[custom.base_hero])
		table.merge(output, NPC_HEROES_CUSTOM[custom.base_hero])
		for i = 1, 24 do
			output["Ability" .. i] = nil
		end
		table.merge(output, custom)
	else
		table.merge(output, default)
		table.merge(output, custom)
	end
	return output
end

function SetAllItemSlotsLocked(unit, locked, bNoStash)
	for i = 0, bNoStash and DOTA_ITEM_SLOT_9 or DOTA_STASH_SLOT_6 do
		local current_item = unit:GetItemInSlot(i)
		if current_item then
			ExecuteOrderFromTable({
				UnitIndex = unit:GetEntityIndex(), 
				OrderType = DOTA_UNIT_ORDER_SET_ITEM_COMBINE_LOCK,
				AbilityIndex = current_item:GetEntityIndex(),
				TargetIndex = locked and 1 or 0,
				Queue = false
			})
		end
	end
end

function FillSlotsWithDummy(unit, bNoStash)
	for i = 0, bNoStash and DOTA_ITEM_SLOT_9 or DOTA_STASH_SLOT_6 do
		local current_item = unit:GetItemInSlot(i)
		if not current_item then
			unit:AddItem(CreateItem("item_dummy", unit, unit))
		end
	end
end

function ClearSlotsFromDummy(unit, bNoStash)
	for i = 0, bNoStash and DOTA_ITEM_SLOT_9 or DOTA_STASH_SLOT_6 do
		local current_item = unit:GetItemInSlot(i)
		if current_item and current_item:GetAbilityName() == "item_dummy" then
			unit:RemoveItem(current_item)
			UTIL_Remove(current_item)
		end
	end
end

function GetAllItemsByNameInInventory(unit, itemname, bStash)
	local items = {}
	for slot = 0, bStash and DOTA_STASH_SLOT_6 or DOTA_ITEM_SLOT_9 do
		local item = unit:GetItemInSlot(slot)
		if item and item:GetAbilityName() == itemname then
			table.insert(items, item)
		end
	end
	return items
end

function CDOTA_BaseNPC:UnitHasSlotForItem(itemname, bStash)
	if self.HasRoomForItem then
		return self:HasRoomForItem(itemname, bStash, true) ~= 4
	else
		for i = 0, bStash and DOTA_STASH_SLOT_6 or DOTA_ITEM_SLOT_9 do
			local item = self:GetItemInSlot(i)
			if not item or (not item:IsNull() and item:GetAbilityName() == itemname and item:IsStackable()) then
				return true
			end
		end
		return false
	end
end

function table.nearest(table, number)
	local smallestSoFar, smallestIndex
	for i, y in ipairs(table) do
		if not smallestSoFar or (math.abs(number-y) < smallestSoFar) then
			smallestSoFar = math.abs(number-y)
			smallestIndex = i
		end
	end
	return table[smallestIndex], smallestIndex
end

function CreateExplosion(position, minRadius, fullRdius, minForce, fullForce, teamNumber, teamFilter, typeFilter, flagFilter)
	for _,v in ipairs(FindUnitsInRadius(teamNumber, position, nil, fullRdius, teamFilter, typeFilter, flagFilter, FIND_CLOSEST, false)) do
		if IsPhysicsUnit(v) then
			local force = 0
			local len = (position - v:GetAbsOrigin()):Length2D()
			if len < minRadius then
				force = fullForce
			elseif len <= fullRdius then
				local forceNotFullLen = fullRdius - minRadius
				local forceMid = fullForce - minForce
				local forceLevel = (fullRdius - len)/forceNotFullLen
				force = minForce + (forceMid*forceLevel)
			end
			local velocity = (v:GetAbsOrigin() - position):Normalized() * force
			v:AddPhysicsVelocity(velocity)
		end
	end
end

function CEntityInstance:SetNetworkableEntityInfo(key, value)
	local t = CustomNetTables:GetTableValue("custom_entity_values", tostring(self:GetEntityIndex())) or {}
	t[key] = value
	CustomNetTables:SetTableValue("custom_entity_values", tostring(self:GetEntityIndex()), t)
end

function CEntityInstance:ClearNetworkableEntityInfo()
	CustomNetTables:SetTableValue("custom_entity_values", tostring(self:GetEntityIndex()), nil)
end

function IsInBox(point, point1, point2)
	return point.x > point1.x and point.y > point1.y and point.x < point2.x and point.y < point2.y
end

function CDOTA_BaseNPC_Hero:CalculateRespawnTime()
	local time = (5 + self:GetLevel() * 0.1) + (self.RespawnTimeModifier or 0)
	if self.talent_keys and self.talent_keys.respawn_time_reduction then
		time = time + self.talent_keys.respawn_time_reduction
	end
	return math.max(time, 0.1)
end

function CDOTA_BaseNPC_Hero:IsWukongsSummon()
	return self:HasModifier("modifier_monkey_king_fur_army_soldier") or self:HasModifier("modifier_monkey_king_fur_army_soldier_inactive") or self:HasModifier("modifier_monkey_king_fur_army_soldier_hidden")
end

function CDOTA_BaseNPC_Hero:GetTotalHealthReduction()
	local pct = self:GetModifierStackCount("modifier_kadash_immortality_health_penalty", self)
	local mod = self:FindModifierByName("modifier_stegius_brightness_of_desolate_effect")
	if mod then
		pct = pct + mod:GetAbility():GetAbilitySpecial("health_decrease_pct")
	end
	return pct
end

function CDOTA_BaseNPC_Hero:ResetAbilityPoints()
	self:SetAbilityPoints(self:GetLevel() - self:GetAbilityPointsWastedAllOnTalents())
end

function GetFullHeroName(unit)
	return unit.UnitName or unit:GetUnitName()
end

function CDOTA_BaseNPC_Hero:GetFullName()
	return self.UnitName or (self.GetUnitName and self:GetUnitName()) or self:GetName()
end

function table.nearestKey(t, key)
	if not t then return end
	local selectedKey
	for k,v in pairs(t) do
		if not selectedKey or math.abs(k - key) < math.abs(selectedKey - key) then
			selectedKey = k
		end
	end
	return t[selectedKey]
end

function table.nearestOrLowerKey(t, key)
	if not t then return end
	local selectedKey
	for k,v in pairs(t) do
		if k <= key and (not selectedKey or math.abs(k - key) < math.abs(selectedKey - key)) then
			selectedKey = k
		end
	end
	return t[selectedKey]
end

function CDOTA_BaseNPC:DestroyAllModifiers()
	for _,v in ipairs(self:FindAllModifiers()) do
		v:Destroy()
	end
end

function CDOTA_BaseNPC:HasModelChanged()
	if self:HasModifier("modifier_terrorblade_metamorphosis") or self:HasModifier("modifier_monkey_king_transform") or self:HasModifier("modifier_lone_druid_true_form") then
		return true
	end
	for _, modifier in ipairs(self:FindAllModifiers()) do
		if modifier.DeclareFunctions and table.contains(modifier:DeclareFunctions(), MODIFIER_PROPERTY_MODEL_CHANGE) then
			if modifier.GetModifierModelChange and modifier:GetModifierModelChange() then
				return true
			end
		end
	end
	return false
end

function GetConnectionState(pid)
	if DebugConnectionStates then
		local map = {
			[3] = "DOTA_CONNECTION_STATE_DISCONNECTED",
			[6] = "DOTA_CONNECTION_STATE_FAILED",
			[0] = "DOTA_CONNECTION_STATE_UNKNOWN",
			[1] = "DOTA_CONNECTION_STATE_NOT_YET_CONNECTED",
			[4] = "DOTA_CONNECTION_STATE_ABANDONED",
			[2] = "DOTA_CONNECTION_STATE_CONNECTED",
			[5] = "DOTA_CONNECTION_STATE_LOADING",
		}
		CPrint(pid, map[PlayerResource:GetConnectionState(pid)])
	end
	return PlayerResource:IsFakeClient(pid) and DOTA_CONNECTION_STATE_CONNECTED or PlayerResource:GetConnectionState(pid)
end

function DebugCallFunction(fun)
	local status, nextCall = xpcall(function() return fun() end, function (msg)
		return msg..'\n'..debug.traceback()..'\n'
	end)
	if not status then
		Timers:HandleEventError(nil, nil, nextCall)
	end
end
function CDOTA_BaseNPC:FindClearSpaceForUnitAndSetCamera(position)
	self:Stop()
	PlayerResource:SetCameraTarget(self:GetPlayerOwnerID(), self)
	FindClearSpaceForUnit(self, position, true)
	Timers:CreateTimer(0.1, function()
		if IsValidEntity(self) then
			PlayerResource:SetCameraTarget(self:GetPlayerOwnerID(), nil)
			self:Stop()
		end
	end)
end

function CDOTA_BaseNPC:IsTrueHero()
	return self:IsRealHero() and not self:IsTempestDouble() and not self:IsWukongsSummon()
end

--TODO
--[[function CDOTA_BaseNPC:AddNewModifierShared(hCaster, hAbility, pszScriptName, hModifierTable)
	CustomNetTables:SetTableValue("shared_modifiers", self:GetEntityIndex() .. "_" .. pszScriptName, hModifierTable)
	return self:AddNewModifier(hCaster, hAbility, pszScriptName, hModifierTable)
end]]