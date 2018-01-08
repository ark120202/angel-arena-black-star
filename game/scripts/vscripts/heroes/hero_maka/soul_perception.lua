LinkLuaModifier("modifier_maka_soul_perception", "heroes/hero_maka/soul_perception.lua", LUA_MODIFIER_MOTION_NONE)

maka_soul_perception = class({})

modifier_maka_soul_perception = class({
	IsHidden   = function() return false end,
	IsPurgable = function() return true end,
})

function modifier_maka_soul_perception:GetCooldown()
	if self:GetCaster():HasModifier("modifier_maka_soul_resonance") then
		return self:GetCooldownTimeRemaining() * self:GetSpecialValueFor("cooldown_dicrease_pct") * 0.01
	else
		return self:GetCooldownTimeRemaining()
	end
end

if IsServer() then
	function maka_soul_perception:OnSpellStart()
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
		print(1)
		for _,v in ipairs(HeroList:GetAllHeroes()) do 
			if v:IsAlive() and v:GetTeamNumber() ~= caster:GetTeamNumber() then
				v:AddNewModifier(caster, self, "modifier_maka_soul_perception", {duration = duration}) 
			end
		end
	end
end

function modifier_maka_soul_perception:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}
end

function modifier_maka_soul_perception:CheckState()
	if self:GetCaster():HasModifier("modifier_maka_soul_resonance") then
		return {
			[MODIFIER_STATE_INVISIBLE] = false,
		}
	end
end

function modifier_maka_soul_perception:GetModifierProvidesFOWVision()
	return 1
end