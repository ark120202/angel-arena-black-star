saitama_squats = class({})

if IsServer() then
	function saitama_squats:OnChannelFinish(bInterrupted)
		if not bInterrupted then
			local caster = self:GetCaster()
			caster:ModifyStrength(self:GetSpecialValueFor("bonus_strength"))
			ModifyStacksLua(self, caster, caster, "modifier_saitama_limiter", self:GetSpecialValueFor("stacks_amount"))
		end
	end
end
