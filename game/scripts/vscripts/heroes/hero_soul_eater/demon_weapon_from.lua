LinkLuaModifier("modifier_soul_eater_demon_weapon_from", "heroes/hero_soul_eater/demon_weapon_from.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_soul_eater_demon_weapon_from_transformation", "heroes/hero_soul_eater/demon_weapon_from.lua", LUA_MODIFIER_MOTION_NONE)

soul_eater_demon_weapon_from = class({})

if IsServer() then
	function soul_eater_demon_weapon_from:CastFilterResult()
		local soul = self:GetCaster()
		local maka = soul:GetLinkedHeroEntities()[1]
		local position = soul:GetAbsOrigin()
		return (maka:GetAbsOrigin() - position):Length2D() <= self:GetCastRange(position, maka) and UF_FAIL_INVALID_LOCATION or UF_SUCCESS
	end

	--[[function soul_eater_demon_weapon_from:GetCustomCastError()
		local soul = self:GetCaster()
		local maka = soul:GetLinkedHeroEntities()[1]
		local position = soul:GetAbsOrigin()
		return (maka:GetAbsOrigin() - position):Length2D() <= self:GetCastRange(position, maka) and "#dota_hud_error_target_out_of_range" or ""
	end]]

	function soul_eater_demon_weapon_from:OnSpellStart()
		local soul = self:GetCaster()
		local maka = soul:GetLinkedHeroEntities()[1]
		local position = soul:GetAbsOrigin()
		if maka and (maka:GetAbsOrigin() - position):Length2D() <= self:GetCastRange(position, maka) then
			self.maka = maka
			local team = soul:GetTeamNumber()

			soul:AddNewModifier(maka, self, "modifier_soul_eater_demon_weapon_from_transformation", nil)
			ProjectileManager:CreateTrackingProjectile({
				Target = maka,
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
	end

	function soul_eater_demon_weapon_from:OnProjectileHit(hTarget, vLocation)
		local soul = self:GetCaster()
		soul:RemoveModifierByName("modifier_soul_eater_demon_weapon_from_transformation")
		soul:AddNewModifier(self.maka, self, "modifier_soul_eater_demon_weapon_from", nil)
	end
end


modifier_soul_eater_demon_weapon_from_transformation = class({
	IsPurgable = function() return false end,
	IsHidden   = function() return true end,
})

function modifier_soul_eater_demon_weapon_from_transformation:CheckState()
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
	function modifier_soul_eater_demon_weapon_from_transformation:OnCreated()
		self:GetParent():AddNoDraw()
	end

	function modifier_soul_eater_demon_weapon_from_transformation:OnDestroy()
		self:GetParent():RemoveNoDraw()
	end
end


modifier_soul_eater_demon_weapon_from = class({
	IsPurgable = function() return false end,
	IsHidden   = function() return true end,
})

function modifier_soul_eater_demon_weapon_from:CheckState()
	return {
		--[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
end

if IsServer() then
	function modifier_soul_eater_demon_weapon_from:OnCreated()
		local soul = self:GetParent()
		local maka = self:GetCaster()
		local scythe = maka:GetWearableInSlot("weapon")
		if scythe then
			local scythe_ent = scythe.entity
			if IsValidEntity(scythe_ent) then
				scythe_ent:SetVisible(true)
			end
		end

		soul:AddNoDraw()
		self:StartIntervalThink(1/30)
		soul:SwapAbilities("soul_eater_demon_weapon_from", "soul_eater_human_form", false, true)
	end

	function modifier_soul_eater_demon_weapon_from:OnIntervalThink()
		local soul = self:GetParent()
		local maka = self:GetCaster()
		soul:SetAbsOrigin(maka:GetAbsOrigin())
		if not maka:IsAlive() then
			self:Destroy()
		end
	end
	function modifier_soul_eater_demon_weapon_from:OnDestroy()
		local soul = self:GetParent()
		soul:RemoveNoDraw()
		local maka = self:GetCaster()
		local scythe = maka:GetWearableInSlot("weapon")
		if scythe then
			local scythe_ent = scythe.entity
			if IsValidEntity(scythe_ent) then
				scythe_ent:SetVisible(false)
			end
		end
		soul:SwapAbilities("soul_eater_demon_weapon_from", "soul_eater_human_form", true, false)
	end
end
