modifier_item_soul_gem = class({})

function modifier_item_soul_gem:DeclareFunctions()
	return {MODIFIER_EVENT_ON_DEATH}
end

function modifier_item_soul_gem:OnDeath(keys)
	if keys.attacker == self:GetParent() then
		print("+1 soul!")
		self:GetAbility():OnUnitSoulKilled(keys.attacker)
	end
end

function modifier_item_soul_gem:IsPurgable()
	return false
end

function modifier_item_soul_gem:IsHidden()
	return true
end