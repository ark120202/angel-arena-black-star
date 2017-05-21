modifier_arena_healer = class({})
function modifier_arena_healer:IsHidden() return true end
function modifier_arena_healer:IsPurgable() return false end

if IsServer() then
	function modifier_arena_healer:OnCreated()
		local healer = self:GetParent()
		self:StartIntervalThink(60)
		healer:SetBaseMaxHealth(HEALER_HEALTH_BASE)
		healer:SetMaxHealth(HEALER_HEALTH_BASE)
	end

	function modifier_arena_healer:OnIntervalThink()
		local healer = self:GetParent()
		healer:SetBaseMaxHealth(healer:GetBaseMaxHealth() + HEALER_HEALTH_GROWTH)
		healer:SetMaxHealth(healer:GetMaxHealth() + HEALER_HEALTH_GROWTH)
		healer:SetHealth(healer:GetHealth() + HEALER_HEALTH_GROWTH)
	end
end