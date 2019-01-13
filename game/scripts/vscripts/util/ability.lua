function CDOTABaseAbility:HasBehavior(behavior)
	local abilityBehavior = tonumber(tostring(self:GetBehavior()))
	return bit.band(abilityBehavior, behavior) == behavior
end

function AbilityHasBehaviorByName(ability_name, behaviorString)
	local AbilityBehavior = GetKeyValue(ability_name, "AbilityBehavior")
	if AbilityBehavior then
		local AbilityBehaviors = string.split(AbilityBehavior, " | ")
		return table.includes(AbilityBehaviors, behaviorString)
	end
	return false
end

function CDOTABaseAbility:PerformPrecastActions()
	if self:IsCooldownReady() and self:IsOwnersManaEnough() then
		self:PayManaCost()
		self:AutoStartCooldown()
		--self:UseResources(true, true, true) -- not works with items?
		return true
	end
	return false
end

function CDOTABaseAbility:GetMulticastType()
	local name = self:GetAbilityName()
	if MULTICAST_ABILITIES[name] then return MULTICAST_ABILITIES[name] end
	if self:IsToggle() then return MULTICAST_TYPE_NONE end
	if self:HasBehavior(DOTA_ABILITY_BEHAVIOR_PASSIVE) then return MULTICAST_TYPE_NONE end
	return self:HasBehavior(DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) and MULTICAST_TYPE_DIFFERENT or MULTICAST_TYPE_SAME
end

function CDOTABaseAbility:ClearFalseInnateModifiers()
	if self:GetKeyValue("HasInnateModifiers") ~= 1 then
		for _,v in ipairs(self:GetCaster():FindAllModifiers()) do
			if v:GetAbility() and v:GetAbility() == self then
				v:Destroy()
			end
		end
	end
end

function CDOTABaseAbility:GetReducedCooldown()
	local biggestReduction = 0
	local unit = self:GetCaster()
	for k,v in pairs(COOLDOWN_REDUCTION_MODIFIERS) do
		if unit:HasModifier(k) then
			biggestReduction = math.max(biggestReduction, type(v) == "function" and v(unit) or v)
		end
	end
	return self:GetCooldown(math.max(self:GetLevel() - 1, 1)) * (100 - biggestReduction) * 0.01
end

function CDOTABaseAbility:AutoStartCooldown()
	self:StartCooldown(self:GetReducedCooldown())
end
