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

	local refreshIgnoreList = {
		tinker_rearm_arena = true,
		item_refresher_arena = true,
		item_refresher_core = true,
		item_titanium_bar = true,
		item_guardian_greaves_arena = true,
		item_demon_king_bar = true,
		item_pipe = true,
		item_arcane_boots = true,
		item_helm_of_the_dominator = true,
		item_sphere = true,
		item_necronomicon = true,
		item_hand_of_midas_arena = true,
		item_hand_of_midas_2_arena = true,
		item_hand_of_midas_3_arena = true,
		item_mekansm_arena = true,
		item_mekansm_2 = true,
		item_black_king_bar_arena = true,
		item_black_king_bar_2 = true,
		item_black_king_bar_3 = true,
		item_black_king_bar_4 = true,
		item_black_king_bar_5 = true,
		item_black_king_bar_6 = true,

		destroyer_body_reconstruction = true,
		stargazer_cosmic_countdown = true,
		faceless_void_chronosphere = true,
		zuus_thundergods_wrath = true,
		enigma_black_hole = true,
		freya_pain_reflection = true,
		skeleton_king_reincarnation = true,
		dazzle_shallow_grave = true,
		zuus_cloud = true,
		ancient_apparition_ice_blast = true,
		silencer_global_silence = true,
		naga_siren_song_of_the_siren = true,
		slark_shadow_dance = true,
	}

	function tinker_rearm_arena:OnChannelFinish(bInterrupted)
		if not bInterrupted then
			local caster = self:GetCaster()
			RefreshAbilities(caster, refreshIgnoreList)
			RefreshItems(caster, refreshIgnoreList)
		end
	end
end
