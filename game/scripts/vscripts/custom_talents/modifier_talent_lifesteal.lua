modifier_talent_lifesteal = class({})
function modifier_talent_lifesteal:IsHidden() return true end
function modifier_talent_lifesteal:IsPermanent() return true end
function modifier_talent_lifesteal:IsPurgable() return false end
function modifier_talent_lifesteal:DestroyOnExpire() return false end
function modifier_talent_lifesteal:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end
if IsServer() then
	function modifier_talent_evasion:DeclareFunctions()
		return {MODIFIER_EVENT_ON_ATTACK_LANDED}
	end

	function modifier_talent_lifesteal:OnAttackLanded()
		if k.attacker == self:GetParent() then
			SafeHeal(k.attacker, k.damage * self:GetStackCount() * 0.01, self)
			ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, k.attacker)
		end
	end
end

function modifier_talent_lifesteal:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end