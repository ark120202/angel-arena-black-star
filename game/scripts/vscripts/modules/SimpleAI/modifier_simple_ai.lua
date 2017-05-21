modifier_simple_ai = class({})

function modifier_simple_ai:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_simple_ai:IsHidden()
	return true
end

function modifier_simple_ai:IsPurgable()
	return false
end

function modifier_simple_ai:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE}
end

function modifier_simple_ai:OnTakeDamage(keys)
	if IsServer() and self:GetParent() == keys.unit then
		local target = self:GetParent()
		keys.unit.ai:OnTakeDamage(keys.attacker)
	end
end