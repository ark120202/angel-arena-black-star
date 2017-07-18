LinkLuaModifier("modifier_soul_eater_demon_weapon_from", "heroes/hero_soul_eater/demon_weapon_from.lua", LUA_MODIFIER_MOTION_NONE)

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
			local scythe = maka:GetWearableInSlot("weapon")
			if scythe then
				local scythe_ent = scythe.entity
				if IsValidEntity(scythe_ent) then
					scythe_ent:SetVisible(true)
				end
			end
			soul:AddNewModifier(maka, self, "modifier_soul_eater_demon_weapon_from", nil)
		end
	end
end


modifier_soul_eater_demon_weapon_from = class({})

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
