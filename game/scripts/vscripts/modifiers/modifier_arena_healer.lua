modifier_arena_healer = class({})
function modifier_arena_healer:IsHidden() return true end
function modifier_arena_healer:IsPurgable() return false end

if IsServer() then
	function modifier_arena_healer:OnCreated()
		local healer = self:GetParent()

		self:StartIntervalThink(60)
		self.hitsRemaining = HEALER_HEALTH_BASE
		healer:SetBaseMaxHealth(HEALER_HEALTH_BASE)
		healer:SetMaxHealth(HEALER_HEALTH_BASE)
	end

	function modifier_arena_healer:OnIntervalThink()
		local healer = self:GetParent()

		healer:SetBaseMaxHealth(courier:GetBaseMaxHealth() + HEALER_HEALTH_GROWTH)
		healer:SetMaxHealth(courier:GetMaxHealth() + HEALER_HEALTH_GROWTH)

		self.hitsRemaining = self.hitsRemaining + HEALER_HEALTH_GROWTH
		healer:SetHealth(self.hitsRemaining)
	end

	function modifier_arena_healer:DeclareFunctions()
		return {MODIFIER_EVENT_ON_TAKEDAMAGE}
	end

	function modifier_arena_healer:OnTakeDamage(keys)
		local unit = self:GetParent()
		if unit == keys.unit then
			self.hitsRemaining = self.hitsRemaining - 1
			unit:SetHealth(self.hitsRemaining)
			--[[if self.hitsRemaining == 0 then
				unit:ForceKill(false)
			end]]
		end
	end
end