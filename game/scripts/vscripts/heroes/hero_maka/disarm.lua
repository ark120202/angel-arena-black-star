LinkLuaModifier("modifier_maka_passive", "heroes/hero_maka/disarm.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_maka_disarm", "heroes/hero_maka/disarm.lua", LUA_MODIFIER_MOTION_NONE)

maka_disarm = class({
	GetIntrinsicModifierName = function() return "modifier_maka_passive" end,
})

modifier_maka_disarm = class({
	IsHidden   = function() return true end,
	IsPurgable = function() return false end,
})

modifier_maka_passive = class({
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
})

function modifier_maka_disarm:CheckState()
	return {
		[MODIFIER_STATE_DISARMED] = true,
	}
end

if IsServer() then 
	function modifier_maka_passive:OnCreated()
		self:StartIntervalThink(0.1)
		self:OnIntervalThink()
	end

	function modifier_maka_passive:OnIntervalThink()
		local maka = self:GetParent()
		if maka:HasModifier("modifier_soul_eater_transform_to_scythe_buff") then 
			maka:RemoveModifierByName("modifier_maka_disarm")
		else 
			maka:AddNewModifier(maka, self:GetAbility(), "modifier_maka_disarm", nil)
		end
	end

	function maka_disarm:Spawn()
		self:SetLevel(1)
	end
end