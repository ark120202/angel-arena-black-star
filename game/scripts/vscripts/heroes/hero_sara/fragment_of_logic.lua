LinkLuaModifier("modifier_sara_fragment_of_logic", "heroes/hero_sara/fragment_of_logic.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sara_fragment_of_logic_debuff", "heroes/hero_sara/fragment_of_logic.lua", LUA_MODIFIER_MOTION_NONE)

sara_fragment_of_logic = class({
	GetIntrinsicModifierName = function() return "modifier_sara_fragment_of_logic" end,
})

if IsClient() then
	function sara_fragment_of_logic:GetManaCost()
		return self:GetSpecialValueFor("energy_const") + self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("energy_pct") * 0.01
	end
end


modifier_sara_fragment_of_logic = class({
	IsHidden   = function() return true end,
	IsPurgable = function() return false end,
})

if IsServer() then
	function modifier_sara_fragment_of_logic:DeclareFunctions()
		return {
			MODIFIER_EVENT_ON_TAKEDAMAGE,
			MODIFIER_PROPERTY_MIN_HEALTH
		}
	end

	function modifier_sara_fragment_of_logic:OnTakeDamage(keys)
		local parent = keys.unit
		if parent == self:GetParent() and parent:GetHealth() <= 1 and not parent:IsIllusion() and parent.GetEnergy then
			local ability = self:GetAbility()
			local toWaste = ability:GetSpecialValueFor("energy_const") + parent:GetMaxEnergy() * ability:GetSpecialValueFor("energy_pct") * 0.01
			if ability:IsCooldownReady() and parent:GetEnergy() >= toWaste then
				if parent:HasScepter() then
					ability:StartCooldown(ability:GetSpecialValueFor("cooldown_scepter"))
				else
					ability:AutoStartCooldown()
				end
				parent:AddNewModifier(parent, ability, "modifier_sara_fragment_of_logic_debuff", {duration = ability:GetSpecialValueFor("debuff_duration")})
				parent:ModifyEnergy(-toWaste)
				parent:SetHealth(parent:GetMaxHealth())
				parent:Purge(false, true, false, true, false)
				ParticleManager:CreateParticle("particles/arena/units/heroes/hero_sara/fragment_of_logic.vpcf", PATTACH_ABSORIGIN, parent)
				parent:EmitSound("Hero_Chen.HandOfGodHealHero")
			end
		end
	end

	function modifier_sara_fragment_of_logic:GetMinHealth(keys)
		local parent = self:GetParent()
		if not parent:IsIllusion() and parent.GetEnergy then
			local ability = self:GetAbility()
			if ability:IsCooldownReady() and parent:GetEnergy() >= ability:GetSpecialValueFor("energy_const") + parent:GetMaxEnergy() * ability:GetSpecialValueFor("energy_pct") * 0.01 then
				return 1
			end
		end
	end
end

modifier_sara_fragment_of_logic_debuff = class({
	IsPurgable = function() return false end,
	IsDebuff = function() return true end,
})
