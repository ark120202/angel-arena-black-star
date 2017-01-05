modifier_duel_hero_disabled_for_duel = class({})

function modifier_duel_hero_disabled_for_duel:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_jade_stone.vpcf"
end

function modifier_duel_hero_disabled_for_duel:StatusEffectPriority()
	return 100
end

function modifier_duel_hero_disabled_for_duel:IsHidden()
	return true
end

function modifier_duel_hero_disabled_for_duel:CheckState() 
	return {
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NIGHTMARED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_LOW_ATTACK_PRIORITY] = true,
		[MODIFIER_STATE_HEXED] = true,
	}
end

function modifier_duel_hero_disabled_for_duel:IsPurgable()
	return false
end