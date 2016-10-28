LinkLuaModifier("modifier_item_soul_gem", "items/soul_gems/modifier_item_soul_gem", LUA_MODIFIER_MOTION_NONE)
item_soul_gem = class({})

function item_soul_gem:GetIntrinsicModifierName()
	return "modifier_item_soul_gem"
end

function item_soul_gem:GetSoulLimit()
	return 25
end

function item_soul_gem:OnSoulLimitReached()
	print("[Warning] Soul limit reached, but it's unhandled for " .. self:GetAbilityName())
end

function item_soul_gem:OnUnitSoulKilled(soul) if IsServer() then
	self:SetCurrentCharges(self:GetCurrentCharges() + 1)
	if self:GetCurrentCharges() >= self:GetSoulLimit() then
		self:OnSoulLimitReached()
	end
end end