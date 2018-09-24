			--Entity
function CEntityInstance:SetNetworkableEntityInfo(key, value)
	local t = CustomNetTables:GetTableValue("custom_entity_values", tostring(self:GetEntityIndex())) or {}
	t[key] = value
	CustomNetTables:SetTableValue("custom_entity_values", tostring(self:GetEntityIndex()), t)
end

function CEntityInstance:ClearNetworkableEntityInfo()
	CustomNetTables:SetTableValue("custom_entity_values", tostring(self:GetEntityIndex()), nil)
end

function CEntityInstance:CutTreeOrWard(caster, ability)
	if self:GetClassname() == "ent_dota_tree" then
		self:CutDown(caster:GetTeamNumber())
	elseif self:IsCustomWard() then
		self:TrueKill(ability, caster)
	end
end

			--NPC
function CDOTA_BaseNPC:IsRealCreep()
	return self.SSpawner ~= nil and self.SpawnerType ~= nil
end

function CDOTA_BaseNPC:GetFullName()
	return self.UnitName or (self.GetUnitName and self:GetUnitName()) or self:GetName()
end

function CDOTA_BaseNPC:DestroyAllModifiers()
	for _,v in ipairs(self:FindAllModifiers()) do
		if not UNDESTROYABLE_MODIFIERS[v:GetName()] then
			v:Destroy()
		end
	end
end

function CDOTA_BaseNPC:HasModelChanged()
	if self:HasModifier("modifier_terrorblade_metamorphosis") or self:HasModifier("modifier_monkey_king_transform") or self:HasModifier("modifier_lone_druid_true_form") then
		return true
	end
	for _, modifier in ipairs(self:FindAllModifiers()) do
		if modifier.DeclareFunctions and table.includes(modifier:DeclareFunctions(), MODIFIER_PROPERTY_MODEL_CHANGE) then
			if modifier.GetModifierModelChange and modifier:GetModifierModelChange() then
				return true
			end
		end
	end
	return false
end

local TELEPORT_MAX_COLLISION_RANGE = 256
function CDOTA_BaseNPC:Teleport(position)
	self.TeleportPosition = position
	self:Stop()

	local playerId = self:GetPlayerOwnerID()
	PlayerResource:SetCameraTarget(playerId, self)

	FindClearSpaceForUnit(self, position, true)

	Timers:CreateTimer(0.1, function()
		if not IsValidEntity(self) then return end
		if self.TeleportPosition ~= position then return end
		if (self:GetAbsOrigin() - position):Length2D() > TELEPORT_MAX_COLLISION_RANGE then
			FindClearSpaceForUnit(self, position, true)
			return 0.1
		end

		self.TeleportPosition = nil
		PlayerResource:SetCameraTarget(playerId, nil)
		self:Stop()
	end)
end

function CDOTA_BaseNPC:IsRangedUnit()
	return self:IsRangedAttacker() or self:HasModifier("modifier_terrorblade_metamorphosis_transform_aura_applier")
end

function CDOTA_BaseNPC:TrueKill(ability, killer)
	self.IsMarkedForTrueKill = true
	if self:HasAbility("skeleton_king_reincarnation") then
		self:FindAbilityByName("skeleton_king_reincarnation"):StartCooldown(1/30)
	end
	self:Kill(ability, killer)
	if IsValidEntity(self) and self:IsAlive() then
		self:RemoveDeathPreventingModifiers()
		self:Kill(ability, killer)
	end
	self.IsMarkedForTrueKill = false
end

function CDOTA_BaseNPC:GetLinkedHeroNames()
	return HeroSelection:GetLinkedHeroNames(self:GetFullName())
end

function CDOTA_BaseNPC:UpdateAttackProjectile()
	local projectile
	for i = #ATTACK_MODIFIERS, 1, -1 do
		local attack_modifier = ATTACK_MODIFIERS[i]
		local apply = true
		if attack_modifier.modifiers then
			for _,v in ipairs(attack_modifier.modifiers) do
				if not self:HasModifier(v) then
					apply = false
					break
				end
			end
		end
		if apply and attack_modifier.modifier then
			apply = self:HasModifier(attack_modifier.modifier)
		end
		if apply then
			projectile = attack_modifier.projectile
			break
		end
	end
	projectile = projectile or self:GetKeyValue("ProjectileModel")
	self:SetRangedProjectileName(projectile)
	return projectile
end

function CDOTA_BaseNPC:ModifyPlayerStat(key, value)
	if self.GetPlayerOwnerID and self:GetPlayerOwnerID() > -1 then
		return PlayerResource:ModifyPlayerStat(self:GetPlayerOwnerID(), key, value)
	end
end

function CDOTA_BaseNPC:IsTrueHero()
	return self:IsRealHero() and not self:IsTempestDouble() and not self:IsWukongsSummon()
end

function CDOTA_BaseNPC:IsMainHero()
	return self:IsRealHero() and self == PlayerResource:GetSelectedHeroEntity(self:GetPlayerID())
end

function CDOTA_BaseNPC:AddNewAbility(ability_name, skipLinked)
	local hAbility = self:AddAbility(ability_name)
	hAbility:ClearFalseInnateModifiers()
	local linked
	local link = LINKED_ABILITIES[ability_name]
	if link and not skipLinked then
		linked = {}
		for _,v in ipairs(link) do
			local h = self:AddNewAbility(v)
			table.insert(linked, h)
		end
	end
	if hAbility.Spawn then
		hAbility:Spawn()
	end
	return hAbility, linked
end

function CDOTA_BaseNPC:IsWukongsSummon()
	return self:IsHero() and (
		self:HasModifier("modifier_monkey_king_fur_army_soldier") or
		self:HasModifier("modifier_monkey_king_fur_army_soldier_inactive") or
		self:HasModifier("modifier_monkey_king_fur_army_soldier_hidden")
	)
end

			--Hero
function CDOTA_BaseNPC_Hero:CalculateRespawnTime()
	if self.OnDuel then return 1 end
	local time = (5 + self:GetLevel() * 0.2) + (self.RespawnTimeModifierSaiReleaseOfForge or 0)
	if self.talent_keys and self.talent_keys.respawn_time_reduction then
		time = time + self.talent_keys.respawn_time_reduction
	end

	local bloodstone = self:FindItemInInventory("item_bloodstone")
	if bloodstone then
		time = time - bloodstone:GetCurrentCharges() * bloodstone:GetSpecialValueFor("respawn_time_reduction")
	end

	return math.max(time, 3)
end

function CDOTA_BaseNPC_Hero:GetTotalHealthReduction()
	local pct = self:GetModifierStackCount("modifier_kadash_immortality_health_penalty", self)
	local mod = self:FindModifierByName("modifier_stegius_brightness_of_desolate_effect")
	if mod then
		pct = pct + mod:GetAbility():GetAbilitySpecial("health_decrease_pct")
	end

	local sara_evolution = self:FindAbilityByName("sara_evolution")
	if sara_evolution then
		local dec = sara_evolution:GetSpecialValueFor("health_reduction_pct")
		return dec + ((100-dec) * pct * 0.01)
	end
	return pct
end

function CDOTA_BaseNPC_Hero:CalculateHealthReduction()
	self:CalculateStatBonus()
	local pct = self:GetTotalHealthReduction()
	self:SetMaxHealth(pct >= 100 and 1 or self:GetMaxHealth() - pct * (self:GetMaxHealth()/100))
end

function CDOTA_BaseNPC_Hero:ResetAbilityPoints()
	self:SetAbilityPoints(self:GetLevel() - self:GetAbilityPointsWastedAllOnTalents())
end

function CDOTA_BaseNPC_Hero:GetAttribute(attribute)
	if attribute == DOTA_ATTRIBUTE_STRENGTH then
		return self:GetStrength()
	elseif attribute == DOTA_ATTRIBUTE_AGILITY then
		return self:GetAgility()
	elseif attribute == DOTA_ATTRIBUTE_INTELLECT then
		return self:GetIntellect()
	end
end

function CDOTA_BaseNPC_Hero:GetMaxMovementSpeed()
	local max = MAX_MOVEMENT_SPEED

	for k,v in pairs(MOVEMENT_SPEED_MODIFIERS) do
		if self:HasModifier(k) then
			max = math.max(max, v(self))
		end
	end

	--[[ TODO Works only for custom lua modifiers
	for _,v in ipairs(self:FindAllModifiers()) do
		if v.GetModifierMoveSpeed_Max or v.GetModifierMoveSpeed_Limit then
			max = math.max(max,
				(v:GetName() == "modifier_talent_movespeed_limit" and v:GetStackCount()) or
				v:GetModifierMoveSpeed_Limit() or
				v:GetModifierMoveSpeed_Max() or 0)
		end
	end]]
	return max
end
