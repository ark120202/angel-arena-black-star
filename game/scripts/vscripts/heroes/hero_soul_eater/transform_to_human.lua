LinkLuaModifier("modifier_soul_eater_transform_to_human_projectile", "heroes/hero_soul_eater/soul_resonance.lua", LUA_MODIFIER_MOTION_NONE)

soul_eater_transform_to_human = class({})

if IsServer() then
	function soul_eater_transform_to_human:OnSpellStart()
		local soul = self:GetCaster()
		local point = self:GetCursorPosition()
		local soulPos = soul:GetAbsOrigin()

		local team = soul:GetTeamNumber()
		self.dummy = CreateUnitByName("npc_dummy_unit", point, false, soul, soul, team)

		soul:AddNewModifier(soul, self, "modifier_soul_eater_transform_to_human_projectile", nil)
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

	function soul_eater_transform_to_human:OnProjectileHit(hTarget, vLocation)
		local soul = self:GetCaster()
		local maka = soul:GetLinkedHeroEntities()[1]
		local modifier  = soul:FindModifierByName("modifier_soul_eater_transform_to_scythe") 
		local modifier2 = maka:FindModifierByName("modifier_soul_eater_transform_to_scythe_buff") 
		modifier:Destroy()
		modifier2:Destroy()
		UTIL_Remove(self.dummy)
		soul:RemoveModifierByName("modifier_soul_eater_transform_to_human_projectile")
		FindClearSpaceForUnit(soul, vLocation, true)
	end

	function soul_eater_transform_to_human:Spawn()
		self:SetLevel(1)
	end
end


modifier_soul_eater_transform_to_human_projectile = class({
	IsPurgable = function() return false end,
	IsHidden   = function() return true end,
})

function modifier_soul_eater_transform_to_human_projectile:CheckState()
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
	function modifier_soul_eater_transform_to_human_projectile:OnCreated()
		self:GetParent():AddNoDraw()
	end

	function modifier_soul_eater_transform_to_human_projectile:OnDestroy()
		self:GetParent():RemoveNoDraw()
	end
end
