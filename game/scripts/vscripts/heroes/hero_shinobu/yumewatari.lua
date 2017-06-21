shinobu_yumewatari_lua = class({})
LinkLuaModifier("modifier_shinobu_yumewatari", "heroes/hero_shinobu/yumewatari.lua", LUA_MODIFIER_MOTION_NONE)

function shinobu_yumewatari_lua:GetIntrinsicModifierName()
	return "modifier_shinobu_yumewatari"
end

function shinobu_yumewatari_lua:OnSpellStart() if IsServer() then
	local old_soul = self:GetCursorTarget()
	local max_ghost_level = self:GetSpecialValueFor("max_ghost_level")

	if old_soul and old_soul:GetUnitName() == "npc_shinobu_soul" and old_soul:GetTeamNumber() == DOTA_TEAM_NEUTRALS and (old_soul:GetLevel() <= max_ghost_level or max_ghost_level == 0) then
		old_soul:ForceKill(false)
		local caster = self:GetCaster()
		local soul = CreateUnitByName("npc_shinobu_soul", old_soul:GetAbsOrigin(), true, caster, nil, caster:GetTeam())
		soul:SetModel(old_soul:GetModelName())
		soul:SetOriginalModel(old_soul:GetModelName())
		soul:SetModelScale(old_soul:GetModelScale())
		soul:SetBaseMaxHealth(old_soul:GetMaxHealth())
		soul:SetMaxHealth(old_soul:GetMaxHealth())
		soul:SetHealth(old_soul:GetMaxHealth())
		soul:SetBaseDamageMin(old_soul:GetBaseDamageMin())
		soul:SetBaseDamageMax(old_soul:GetBaseDamageMax())
		soul:SetBaseAttackTime(old_soul:GetBaseAttackTime())
		soul:SetAttackCapability(old_soul:GetAttackCapability())

		soul:SetControllableByPlayer(caster:GetPlayerID(), true)
		soul:SetOwner(caster)
		soul:RemoveModifierByName("modifier_shinobu_soul_unit")
		soul:RemoveAbility("shinobu_soul_unit")
		if old_soul:GetLevel() > 1 then
			soul:CreatureLevelUp(old_soul:GetLevel() - 1)
		end
	end
end end

function shinobu_yumewatari_lua:CastFilterResultTarget(hTarget)
	local max_ghost_level = self:GetSpecialValueFor("max_ghost_level")
	return hTarget:GetUnitName() == "npc_shinobu_soul" and hTarget:GetTeamNumber() == DOTA_TEAM_NEUTRALS and (hTarget:GetLevel() <= max_ghost_level or max_ghost_level == 0) and UF_SUCCESS or UF_FAIL_CUSTOM
end

function shinobu_yumewatari_lua:GetCustomCastErrorTarget(hTarget)
	local max_ghost_level = self:GetSpecialValueFor("max_ghost_level")
	if hTarget:GetUnitName() == "npc_shinobu_soul" and hTarget:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
		return hTarget:GetLevel() <= max_ghost_level or max_ghost_level == 0 and "#dota_hud_error_cant_cast_creep_level" or ""
	else
		return "#arena_dota_hud_error_must_target_soul"
	end
end


modifier_shinobu_yumewatari = class({
	IsHidden   = function() return true end,
	IsPurgable = function() return false end,
})

function modifier_shinobu_yumewatari:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_shinobu_yumewatari:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end
