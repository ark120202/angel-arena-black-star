tinker_rearm_arena = class({})

function tinker_rearm_arena:GetChannelTime()
	return self:GetSpecialValueFor("channel_time")
end

if IsServer() then
	function tinker_rearm_arena:OnAbilityPhaseStart()
		self:GetCaster():EmitSound("Hero_Tinker.RearmStart")
		return true
	end

	function tinker_rearm_arena:OnSpellStart()
		local caster = self:GetCaster()
		caster:EmitSound("Hero_Tinker.Rearm")
		ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_rearm.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		StartAnimation(caster, {
			duration = self:GetChannelTime(),
			activity = _G["ACT_DOTA_TINKER_REARM" .. self:GetLevel()] or ACT_DOTA_TINKER_REARM3
		})
	end

	function tinker_rearm_arena:OnChannelFinish(bInterrupted)
		if not bInterrupted then
			local caster = self:GetCaster()
			RefreshAbilities(caster, REFRESH_LIST_IGNORE_REARM)
			RefreshItems(caster, REFRESH_LIST_IGNORE_REARM)
		end
	end
end
