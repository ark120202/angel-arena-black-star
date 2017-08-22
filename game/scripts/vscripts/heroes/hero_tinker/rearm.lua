tinker_rearm_arena = class({})

if IsServer() then
	function tinker_rearm_arena:OnSpellStart()
		local caster = self:GetCaster()
		caster:EmitSound("Hero_Tinker.Rearm")
		ParticleManager:CreateParticle("particles/units/heroes/hero_tinker/tinker_rearm.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		StartAnimation(caster, {
			duration = self:GetReducedCooldown(),
			activity = _G["ACT_DOTA_TINKER_REARM" .. self:GetLevel()] or ACT_DOTA_TINKER_REARM3
		})
		RefreshAbilities(caster, REFRESH_LIST_IGNORE_REARM)
		RefreshItems(caster, REFRESH_LIST_IGNORE_REARM)
	end

	function tinker_rearm_arena:OnAbilityPhaseStart()
		self:GetCaster():EmitSound("Hero_Tinker.RearmStart")
	end
end
