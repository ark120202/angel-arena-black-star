LinkLuaModifier("modifier_boss_kel_thuzad_immortality", "heroes/bosses/kel_thuzad/immortality.lua", LUA_MODIFIER_MOTION_NONE)
boss_kel_thuzad_immortality = class({
	GetIntrinsicModifierName = function() return "modifier_boss_kel_thuzad_immortality" end,
})


modifier_boss_kel_thuzad_immortality = class({
	IsPurgable = function() return false end,
})

if IsServer() then
	function modifier_boss_kel_thuzad_immortality:OnCreated()
		self:SetStackCount(self:GetAbility():GetSpecialValueFor("initial_stack_count"))
	end

	function modifier_boss_kel_thuzad_immortality:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_MIN_HEALTH
		}
	end

	function modifier_boss_kel_thuzad_immortality:OnTakeDamage(keys)
		local parent = keys.unit
		if parent == self:GetParent() and parent:GetHealth() <= 1 then
			if self:GetStackCount() > 0 then
				self:DecrementStackCount()
				parent:SetHealth(parent:GetMaxHealth())
				ParticleManager:CreateParticle("particles/arena/units/heroes/hero_sara/fragment_of_logic.vpcf", PATTACH_ABSORIGIN, parent)
				parent:EmitSound("Hero_Chen.HandOfGodHealHero")
			end
		end
	end

	function modifier_boss_kel_thuzad_immortality:GetMinHealth()
		if self:GetStackCount() > 0 then
			return 1
		end
	end
end
