function CreateTeamNotificationSettings(team, bSecond)
	local textColor = ColorTableToCss(Teams:GetColor(team))
	return {text = Teams:GetName(team, bSecond), continue = true, style = {color = textColor}}
end

function GetDOTATimeInMinutesFull()
	return math.floor(GameRules:GetDOTATime(false, false) / 60)
end

function CreateGoldNotificationSettings(amount)
	return {text=amount, continue=true, style={color="gold"}}, {text="#notifications_gold", continue=true, style={color="gold"}}
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

function FindFountain(team)
	return Entities:FindByName(nil, "npc_arena_fountain_" .. team)
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

function CastAdditionalAbility(caster, ability, target, delay, channelData)
	local skill = ability
	local unit = caster
	local channelTime = ability:GetChannelTime() or 0
	if channelTime > 0 then
		if not caster.dummyCasters then
			caster.dummyCasters = {}
			caster.nextFreeDummyCaster = 1
			for i = 1, 8 do
				local dummy = CreateUnitByName("npc_dummy_caster", caster:GetAbsOrigin(), true, caster, caster, caster:GetTeamNumber())
				dummy:SetControllableByPlayer(caster:GetPlayerID(), true)
				dummy:AddNoDraw()
				dummy:MakeIllusion()
				table.insert(caster.dummyCasters, dummy)
			end
		end
		local dummy = caster.dummyCasters[caster.nextFreeDummyCaster]
		skill = nil
		caster.nextFreeDummyCaster = caster.nextFreeDummyCaster % #caster.dummyCasters + 1
		local abilityName = ability:GetName()
		for i = 0, DOTA_ITEM_SLOT_9 do
			local ditem = dummy:GetItemInSlot(i)
			if ditem then
				ditem:Destroy()
			end
			local citem = caster:GetItemInSlot(i)
			if citem then
				local newditem = dummy:AddItem(CopyItem(citem))
				if newditem:GetName() == abilityName then
					skill = newditem
				end
			end
		end
		dummy:SetOwner(caster)
		dummy:SetAbsOrigin(caster:GetAbsOrigin())
		dummy:SetBaseStrength (caster:GetStrength())
		dummy:SetBaseAgility(caster:GetAgility())
		dummy:SetBaseIntellect(caster:GetIntellect())
		for _, v in pairs(caster:FindAllModifiers()) do
			local buffName = v:GetName()
			local buffAbility = v:GetAbility()
			local dummyModifier = dummy:FindModifierByName(buffName) or dummy:AddNewModifier(dummy, buffAbility, buffName, nil)
			if dummyModifier then dummyModifier:SetStackCount(v:GetStackCount()) end
		end
		Illusions:_copyAbilities(caster, dummy)
		skill = skill or dummy:FindAbilityByName(ability:GetName())
		skill:SetLevel(ability:GetLevel())
		skill.GetCaster = function() return ability:GetCaster() end
		unit = dummy
	end
	if skill:HasBehavior(DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) then
		if target and type(target) == "table" then
			unit:SetCursorCastTarget(target)
		end
	end
	if skill:HasBehavior(DOTA_ABILITY_BEHAVIOR_POINT) then
		if target then
			if target.x and target.y and target.z then
				unit:SetCursorPosition(target)
			elseif target.GetOrigin then
				unit:SetCursorPosition(target:GetOrigin())
			end
		end
	end
	skill:OnSpellStart()
	if channelTime > 0 then
		if channelData.endTime then
			EndAdditionalAbilityChannel(caster, unit, skill, channelData.channelFailed, delay - GameRules:GetGameTime() + channelData.endTime)
		else
			caster:AddEndChannelListener(function(interrupted)
				EndAdditionalAbilityChannel(caster, unit, skill, interrupted, delay)
			end)
		end
	end
end

function EndAdditionalAbilityChannel(caster, unit, skill, interrupted, delay)
	Timers:CreateTimer(delay, function()
		FindClearSpaceForUnit(unit, caster:GetOrigin() - caster:GetForwardVector(), false)
		skill:EndChannel(interrupted)
		skill:OnChannelFinish(interrupted)
	end)
end

function GetAllAbilitiesCooldowns(unit)
	local cooldowns = {}
	for i = 0, unit:GetAbilityCount()-1 do
		local ability = unit:GetAbilityByIndex(i)
		if ability then
			table.insert(cooldowns, ability:GetReducedCooldown())
		end
	end
	return cooldowns
end

function RefreshAbilities(unit, tExceptions)
	for i = 0, unit:GetAbilityCount()-1 do
		local ability = unit:GetAbilityByIndex(i)
		if ability and (not tExceptions or not tExceptions[ability:GetAbilityName()]) then
			ability:EndCooldown()
		end
	end
end

function RefreshItems(unit, tExceptions)
	for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_9 do
		local item = unit:GetItemInSlot(i)
		if item and (not tExceptions or not tExceptions[item:GetAbilityName()]) then
			item:EndCooldown()
		end
	end
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

function ColorTableToCss(color)
	return "rgb(" .. color[1] .. ',' .. color[2] .. ',' .. color[3] .. ')'
end

function FindAllOwnedUnits(playerId)
	local summons = {}
	local units = FindUnitsInRadius(PlayerResource:GetTeam(playerId), Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)
	for _,v in ipairs(units) do
		if (v.GetPlayerID and v:GetPlayerID() or v:GetPlayerOwnerID()) == playerId then
			if not (v:HasModifier("modifier_dummy_unit") or v:HasModifier("modifier_containers_shopkeeper_unit") or v:HasModifier("modifier_teleport_passive")) and v ~= hero then
				table.insert(summons, v)
			end
		end
	end
	return summons
end

function RemoveAllOwnedUnits(playerId)
	local player = PlayerResource:GetPlayer(playerId)
	local hero = PlayerResource:GetSelectedHeroEntity(playerId)
	RemoveDummyCasters(hero)
	for _,v in ipairs(FindAllOwnedUnits(playerId)) do
		if v ~= hero and not v:IsCourier() then
			v:ClearNetworkableEntityInfo()
			v:ForceKill(false)
			RemoveDummyCasters(v)
			UTIL_Remove(v)
		end
	end
end

function RemoveDummyCasters(unit)
	for _, dummyCaster in pairs(unit.dummyCasters or {}) do UTIL_Remove(dummyCaster) end
end

function GetTeamPlayerCount(iTeam)
	local counter = 0
	for i = 0, 23 do
		if PlayerResource:IsValidPlayerID(i) and not PlayerResource:IsPlayerAbandoned(i) and PlayerResource:GetTeam(i) == iTeam then
			counter = counter + 1
		end
	end
	return counter
end

function GetOneRemainingTeam()
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
	return teamLeft
end

function CopyItem(item)
	local newItem = CreateItem(item:GetAbilityName(), nil, nil)
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

function SafeHeal(unit, flAmount, hInflictor, overhead)
	if unit:IsAlive() then
		unit:Heal(flAmount, hInflictor)
		if overhead then
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, unit, flAmount, nil)
		end
	end
end

function UnitVarToPlayerID(unitvar)
	if unitvar then
		if type(unitvar) == "number" then
			return unitvar
		elseif IsValidEntity(unitvar) then
			if unitvar.GetPlayerID and unitvar:GetPlayerID() > -1 then
				return unitvar:GetPlayerID()
			elseif unitvar.GetPlayerOwnerID then
				return unitvar:GetPlayerOwnerID()
			end
		end
	end
	return -1
end

function GetTrueItemCost(name)
	local cost = GetItemCost(name)
	if cost <= 0 then
		local tempItem = CreateItem(name, nil, nil)
		if not tempItem then
			print("[GetTrueItemCost] Warning: " .. name)
		else
			cost = tempItem:GetCost()
			UTIL_Remove(tempItem)
		end
	end
	return cost
end

function IsUltimateAbility(ability)
	return bit.band(ability:GetAbilityType(), 1) == 1
end

function IsUltimateAbilityKV(abilityname)
	return GetKeyValue(abilityname, "AbilityType") == "DOTA_ABILITY_TYPE_ULTIMATE"
end

function GetPlayersInTeam(team)
	local players = {}
	for playerId = 0, DOTA_MAX_TEAM_PLAYERS-1  do
		if PlayerResource:IsValidPlayerID(playerId) and (not team or PlayerResource:GetTeam(playerId) == team) and not PLAYER_DATA[playerId].IsAbandoned then
			table.insert(players, playerId)
		end
	end
	return players
end

function RemoveAbilityWithModifiers(unit, ability)
	for _,v in ipairs(unit:FindAllModifiers()) do
		if v:GetAbility() == ability then
			v:Destroy()
		end
	end
	if ability.DestroyHookParticles then
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

function WorldPosToMinimap(vec)
	local pct1 = (vec.x + MAP_LENGTH) / (MAP_LENGTH * 2)
	local pct2 = (MAP_LENGTH - vec.y) / (MAP_LENGTH * 2)
	return pct1*100 .. "% " .. pct2*100 .. "%"
end

function GetHeroTableByName(name)
	local output = {}
	local custom = NPC_HEROES_CUSTOM[name]
	if not custom then
		print("[GetHeroTableByName] Missing hero: " .. name)
		return
	end
	if custom.base_hero then
		table.merge(output, GetUnitKV(custom.base_hero))
		for i = 1, 24 do
			output["Ability" .. i] = nil
		end
		table.merge(output, custom)
	else
		table.merge(output, GetUnitKV(name))
	end
	return output
end

function IsInBox(point, point1, point2)
	return point.x > point1.x and point.y > point1.y and point.x < point2.x and point.y < point2.y
end

function IsInTriggerBox(trigger, extension, vector)
	local origin = trigger:GetAbsOrigin()
	return IsInBox(
		vector,
		origin + ExpandVector(trigger:GetBoundingMins(), extension),
		origin + ExpandVector(trigger:GetBoundingMaxs(), extension)
	)
end

function GetConnectionState(playerId)
	return PlayerResource:IsFakeClient(playerId) and DOTA_CONNECTION_STATE_CONNECTED or PlayerResource:GetConnectionState(playerId)
end

function GetInGamePlayerCount()
	local counter = 0
	for i = 0, 23 do
		if PlayerResource:IsValidPlayerID(i) then
			counter = counter + 1
		end
	end
	return counter
end

function GetTeamAllPlayerCount(iTeam)
	local counter = 0
	for i = 0, 23 do
		if PlayerResource:IsValidPlayerID(i) then
			if PlayerResource:GetTeam(i) == iTeam then
				counter = counter + 1
			end
		end
	end
	return counter
end

function RecreateAbility(unit, ability)
	local name = ability:GetAbilityName()
	local level = ability:GetLevel()
	RemoveAbilityWithModifiers(unit, ability)
	ability = unit:AddNewAbility(name)
	if ability then
		ability:SetLevel(level)
	end
	return ability
end

function CDOTA_Buff:SetSharedKey(key, value)
	local t = CustomNetTables:GetTableValue("shared_modifiers", self:GetParent():GetEntityIndex() .. "_" .. self:GetName()) or {}
	t[key] = value
	CustomNetTables:SetTableValue("shared_modifiers", self:GetParent():GetEntityIndex() .. "_" .. self:GetName(), t)
end

--By Noya, from DotaCraft
function GetPreMitigationDamage(value, victim, attacker, damagetype)
	if damagetype == DAMAGE_TYPE_PHYSICAL then
		local armor = victim:GetPhysicalArmorValue(false)
		local reduction = ((armor)*0.06) / (1+0.06*(armor))
		local damage = value / (1 - reduction)
		return damage,reduction
	elseif damagetype == DAMAGE_TYPE_MAGICAL then
		local reduction = victim:GetMagicalArmorValue()*0.01
		local damage = value / (1 - reduction)

		return damage,reduction
	else
		return value,0
	end
end

function SimpleDamageReflect(victim, attacker, damage, flags, ability, damage_type)
	if victim:IsAlive() and bit.band(flags, DOTA_DAMAGE_FLAG_REFLECTION) == 0 and attacker:GetTeamNumber() ~= victim:GetTeamNumber() then
		ApplyDamage({
			victim = attacker,
			attacker = victim,
			damage = damage,
			damage_type = damage_type,
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_REFLECTION,
			ability = ability
		})
		return true
	end
	return false
end

function IsModifierStrongest(unit, modifier, modifierList)
	local ind = modifierList[modifier]
	if not ind then return false end
	for v,i in pairs(modifierList) do
		if unit:HasModifier(v) and i > ind then
			return false
		end
	end
	return true
end

function GetDirectoryFromPath(path)
	return path:match("(.*[/\\])")
end

function ModuleRequire(this, fileName)
	return require(GetDirectoryFromPath(this) .. fileName)
end

function ModuleLinkLuaModifier(this, className, fileName, LuaModifierType)
	return LinkLuaModifier(className, GetDirectoryFromPath(this) .. (fileName or className), LuaModifierType or LUA_MODIFIER_MOTION_NONE)
end

function pluralize(n, one, many)
	return n == 1 and one or (many or one .. "s")
end

function RemoveAllUnitsByName(name)
	local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for _,v in ipairs(units) do
		if v:GetUnitName():match(name) then
			v:ClearNetworkableEntityInfo()
			v:ForceKill(false)
			UTIL_Remove(v)
		end
	end
end

function AnyUnitHasModifier(name, caster)
	local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	for _,v in ipairs(units) do
		if v:FindModifierByNameAndCaster(name, caster) then
			return true
		end
	end
	return false
end

function ExpandVector(vec, by)
	return Vector(
		(math.abs(vec.x) + by) * math.sign(vec.x),
		(math.abs(vec.y) + by) * math.sign(vec.y),
		(math.abs(vec.z) + by) * math.sign(vec.z)
	)
end

function VectorOnBoxPerimeter(vec, min, max)
	local l, r, b, t = min.x, max.x, min.y, max.y
	local x, y = math.clamp(vec.x, l, r), math.clamp(vec.y, b, t)

	local dl, dr, db, dt = math.abs(x-l), math.abs(x-r), math.abs(y-b), math.abs(y-t)
	local m = math.min(dl, dr, db, dt)

	if m == dl then return Vector(l, y) end
	if m == dr then return Vector(r, y) end
	if m == db then return Vector(x, b) end
	if m == dt then return Vector(x, t) end
end

function CalculateBaseArmor(intellect)
	return intellect * 0.1
end
