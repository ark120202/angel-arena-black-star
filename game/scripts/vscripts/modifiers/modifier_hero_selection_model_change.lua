modifier_hero_selection_model_change = class({})

function modifier_hero_selection_model_change:IsPurgable() return false end
function modifier_hero_selection_model_change:IsHidden() return true end
function modifier_hero_selection_model_change:RemoveOnDeath() return false end
function modifier_hero_selection_model_change:GetAttributes() return MODIFIER_ATTRIBUTE_PERMANENT end

function modifier_hero_selection_model_change:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MODEL_CHANGE
	}
end

if IsServer() then
	function modifier_hero_selection_model_change:GetModifierModelChange()
		return self:GetParent().ModelOverride or ""
	end
end