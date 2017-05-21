modifier_arena_healer = class({})
function modifier_arena_healer:IsHidden() return true end
function modifier_arena_healer:IsPurgable() return false end
function modifier_arena_healer:DestroyOnExpire() return false end

if IsServer() then
	function modifier_arena_healer:OnCreated()
		local healer = self:GetParent()
		self:StartIntervalThink(0.1)
		self:SetDuration(60, true)
		self.filler_ability = healer:FindAbilityByName("filler_ability")
		self.teamNumber = healer:GetTeamNumber()

		healer:SetBaseMaxHealth(HEALER_HEALTH_BASE)
		healer:SetMaxHealth(HEALER_HEALTH_BASE)
	end

	function modifier_arena_healer:OnIntervalThink()
		local healer = self:GetParent()

		--Looks like filler_ability creates particles for shrines, based on constant unit names
		if not self.ambientPfx and self.filler_ability:IsCooldownReady() then
			self.ambientPfx = ParticleManager:CreateParticle(TEAM_HEALER_MODELS[self.teamNumber].ambient, PATTACH_ABSORIGIN_FOLLOW, healer)
		elseif self.ambientPfx and not self.filler_ability:IsCooldownReady() then
			ParticleManager:DestroyParticle(self.ambientPfx, false)
			self.ambientPfx = nil
		end
		if not self.activePfx and healer:HasModifier("modifier_filler_heal_aura") then
			self.activePfx = ParticleManager:CreateParticle(TEAM_HEALER_MODELS[self.teamNumber].active, PATTACH_ABSORIGIN_FOLLOW, healer)
		elseif self.activePfx and not healer:HasModifier("modifier_filler_heal_aura") then
			ParticleManager:DestroyParticle(self.activePfx, false)
			self.activePfx = nil
		end

		if self:GetRemainingTime() <= 0 then
			healer:SetBaseMaxHealth(healer:GetBaseMaxHealth() + HEALER_HEALTH_GROWTH)
			healer:SetMaxHealth(healer:GetMaxHealth() + HEALER_HEALTH_GROWTH)
			healer:SetHealth(healer:GetHealth() + HEALER_HEALTH_GROWTH)
			self:SetDuration(60, true)
		end
	end
end