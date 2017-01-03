modifier_talent_creep_gold = class({})
function modifier_talent_creep_gold:IsHidden() return true end
function modifier_talent_creep_gold:IsPermanent() return true end
function modifier_talent_creep_gold:IsPurgable() return false end
function modifier_talent_creep_gold:DestroyOnExpire() return false end
function modifier_talent_creep_gold:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

if IsServer() then
	function modifier_talent_creep_gold:DeclareFunctions()
		return {MODIFIER_EVENT_ON_DEATH}
	end

	function modifier_talent_creep_gold:OnDeath(k)
		if k.attacker == self:GetParent() and k.unit:IsCreep() then
			Gold:ModifyGold(k.attacker, self:GetStackCount())
			local particle = ParticleManager:CreateParticleForPlayer("particles/units/heroes/hero_alchemist/alchemist_lasthit_msg_gold.vpcf", PATTACH_ABSORIGIN, k.unit, k.attacker:GetPlayerOwner())
			ParticleManager:SetParticleControl(particle, 1, Vector(0, self:GetStackCount(), 0))
			ParticleManager:SetParticleControl(particle, 2, Vector(2, string.len(self:GetStackCount()) + 1, 0))
			ParticleManager:SetParticleControl(particle, 3, Vector(255, 200, 33))
		end
	end
end
