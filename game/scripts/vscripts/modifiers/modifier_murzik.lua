modifier_murzik = class({})

function modifier_murzik:OnCreated()
	if IsServer() then
		local unit = self:GetParent()
		
	end
end

function modifier_murzik:DeclareFunctions()
	return { MODIFIER_PROPERTY_MODEL_CHANGE }
end

function modifier_murzik:GetModifierModelChange()
	return "models/items/courier/el_gato_beyond_the_summit/el_gato_beyond_the_summit.vmdl"
end

function modifier_murzik:IsHidden()
	return true
end

function modifier_murzik:IsPurgable()
	return false
end