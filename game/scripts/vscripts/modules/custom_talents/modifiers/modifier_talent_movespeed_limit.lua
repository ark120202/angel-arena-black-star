if IsClient() then require("utils/shared") end

modifier_talent_movespeed_limit = class({
	IsHidden        = function() return true end,
	IsPermanent     = function() return true end,
	IsPurgable      = function() return false end,
	DestroyOnExpire = function() return false end,
	GetAttributes   = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_talent_movespeed_limit:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
	}
end

function modifier_talent_movespeed_limit:GetModifierMoveSpeed_Max()
	return self.max_speed or self:GetSharedKey("max_speed") or 0
end
function modifier_talent_movespeed_limit:GetModifierMoveSpeed_Limit()
	return self.max_speed or self:GetSharedKey("max_speed") or 0
end

if IsServer() then
	function modifier_talent_movespeed_limit:OnCreated()
		self:StartIntervalThink(0.2)
		self:OnIntervalThink()
	end

	function modifier_talent_movespeed_limit:OnIntervalThink()
		self.max_speed = self:GetParent():GetMaxMovementSpeed()
		self:SetSharedKey("max_speed", self.max_speed)
	end
end
