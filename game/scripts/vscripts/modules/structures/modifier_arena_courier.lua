modifier_arena_courier = class({})
function modifier_arena_courier:IsHidden() return true end
function modifier_arena_courier:IsPurgable() return false end
function modifier_arena_courier:RemoveOnDeath() return false end

function modifier_arena_courier:DeclareFunctions() return { MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE } end
function modifier_arena_courier:GetModifierMoveSpeed_Absolute() return 800 end

if IsServer() then
	function modifier_arena_courier:OnCreated()
		local courier = self:GetParent()
		courier:SetBaseMaxHealth(COURIER_HEALTH)
		courier:SetMaxHealth(COURIER_HEALTH)
		courier:SetHealth(COURIER_HEALTH)
	end
end
