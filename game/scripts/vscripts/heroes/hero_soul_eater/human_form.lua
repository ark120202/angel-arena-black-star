LinkLuaModifier("modifier_soul_eater_human_form_transformation", "heroes/hero_soul_eater/human_form.lua", LUA_MODIFIER_MOTION_NONE)

soul_eater_human_form = class({})

if IsServer() then
	function soul_eater_human_form:OnSpellStart()
		local soul = self:GetCaster()
		local point = self:GetCursorPosition()
		local soulPos = soul:GetAbsOrigin()
		local modifier = soul:FindModifierByName("modifier_soul_eater_demon_weapon_from")
		modifier:Destroy()

		local team = soul:GetTeamNumber()
		self.dummy = CreateUnitByName("npc_dummy_unit", point, false, soul, soul, team)

		soul:AddNewModifier(soul, self, "modifier_soul_eater_human_form_transformation", nil)
		ProjectileManager:CreateTrackingProjectile({
			Target = self.dummy,
			Source = soul,
			Ability = self,
			EffectName = "particles/units/heroes/hero_arc_warden/arc_warden_wraith_prj.vpcf",
			iMoveSpeed = self:GetAbilitySpecial("projectile_speed"),
			bProvidesVision = true,
			iVisionRadius = self:GetAbilitySpecial("vision_radius"),
			iVisionTeamNumber = team,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
		})
	end

	function soul_eater_human_form:OnProjectileHit(hTarget, vLocation)
		local soul = self:GetCaster()
		UTIL_Remove(self.dummy)
		soul:RemoveModifierByName("modifier_soul_eater_human_form_transformation")
		FindClearSpaceForUnit(soul, vLocation, true)
	end
end


modifier_soul_eater_human_form_transformation = class({
	IsPurgable = function() return false end,
	IsHidden   = function() return true end,
})

function modifier_soul_eater_human_form_transformation:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
end

if IsServer() then
	function modifier_soul_eater_human_form_transformation:OnCreated()
		self:GetParent():AddNoDraw()
	end

	function modifier_soul_eater_human_form_transformation:OnDestroy()
		self:GetParent():RemoveNoDraw()
	end
end
