item_shard_baseclass = { GetIntrinsicModifierName = function() return "modifier_item_shard_auto_use" end }
if IsServer() then
	function item_shard_baseclass:OnPurchased()
		if not IsValidEntity(self) then return end
		local caster = self:GetCaster()
		if not PanoramaShop:IsInShop(caster) then return end
		self:AutoUse()
	end
end

LinkLuaModifier("modifier_item_shard_auto_use", "items/items_shards.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_shard_auto_use = {
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
}
if IsServer() then
	function modifier_item_shard_auto_use:OnCreated()
		self:GetAbility():AutoUse()
	end
end

item_shard_str_baseclass = class(item_shard_baseclass)
if IsServer() then
	function item_shard_str_baseclass:AutoUse()
		local caster = self:GetCaster()
		if not caster:IsTrueHero() then return end

		local value = self:GetSpecialValueFor("strength")
		caster:ModifyStrength(value)
		caster.Additional_str = (caster.Additional_str or 0) + value
		self:RemoveSelf()
	end
end
item_shard_str_small = class(item_shard_str_baseclass)
item_shard_str_medium = class(item_shard_str_baseclass)
item_shard_str_large = class(item_shard_str_baseclass)
item_shard_str_extreme = class(item_shard_str_baseclass)

item_shard_agi_baseclass = class(item_shard_baseclass)
if IsServer() then
	function item_shard_agi_baseclass:AutoUse()
		local caster = self:GetCaster()
		if not caster:IsTrueHero() then return end

		local value = self:GetSpecialValueFor("agility") * self:GetCurrentCharges()
		caster:ModifyAgility(value)
		caster.Additional_agi = (caster.Additional_agi or 0) + value
		self:RemoveSelf()
	end
end
item_shard_agi_small = class(item_shard_agi_baseclass)
item_shard_agi_medium = class(item_shard_agi_baseclass)
item_shard_agi_large = class(item_shard_agi_baseclass)
item_shard_agi_extreme = class(item_shard_agi_baseclass)

item_shard_int_baseclass = class(item_shard_baseclass)
if IsServer() then
	function item_shard_int_baseclass:AutoUse()
		local caster = self:GetCaster()
		if not caster:IsTrueHero() then return end

		local value = self:GetSpecialValueFor("intelligence") * self:GetCurrentCharges()
		caster:ModifyIntellect(value)
		caster.Additional_int = (caster.Additional_int or 0) + value
		self:RemoveSelf()
	end
end
item_shard_int_small = class(item_shard_int_baseclass)
item_shard_int_medium = class(item_shard_int_baseclass)
item_shard_int_large = class(item_shard_int_baseclass)
item_shard_int_extreme = class(item_shard_int_baseclass)

item_shard_level = class(item_shard_baseclass)
if IsServer() then
	function item_shard_level:AutoUse()
		local caster = self:GetCaster()
		if not caster:IsTrueHero() then return end

		local level = caster:GetLevel()
		local value = self:GetSpecialValueFor("levels") * self:GetCurrentCharges()
		local newLevel = math.min(level + value, #XP_PER_LEVEL_TABLE)
		caster:AddExperience(XP_PER_LEVEL_TABLE[newLevel] - XP_PER_LEVEL_TABLE[level], 0, false, false)
		self:RemoveSelf()
	end
end
item_shard_level10 = class(item_shard_level)

item_shard_attackspeed = class(item_shard_baseclass)
if IsServer() then
	function item_shard_attackspeed:AutoUse()
		local caster = self:GetCaster()
		if not caster:IsTrueHero() then return end

		local modifier = (
			caster:FindModifierByName("modifier_item_shard_attackspeed_stack") or
			caster:AddNewModifier(caster, self, "modifier_item_shard_attackspeed_stack", nil)
		)
		if modifier then
			local stacks = modifier:GetStackCount() +  self:GetCurrentCharges()
			modifier:SetStackCount(stacks)
			caster.Additional_attackspeed = stacks
		end
		self:RemoveSelf()
	end
end
