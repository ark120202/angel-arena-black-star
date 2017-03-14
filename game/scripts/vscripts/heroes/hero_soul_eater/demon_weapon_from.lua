soul_eater_demon_weapon_from = class({})
LinkLuaModifier("modifier_soul_eater_demon_weapon_from", "heroes/hero_soul_eater/modifier_soul_eater_demon_weapon_from.lua", LUA_MODIFIER_MOTION_NONE)

if IsServer() then
	function soul_eater_demon_weapon_from:CastFilterResult()
		local parent = self:GetParent()
		local maka = parent:GetLinkedHeroEntities()[1]
		local parentabs = parent:GetAbsOrigin()
		return (maka:GetAbsOrigin() - parentabs):Length2D() <= self:GetCastRange(parentabs, maka) and UF_FAIL_INVALID_LOCATION or UF_SUCCESS
	end

	--[[function soul_eater_demon_weapon_from:GetCustomCastError()
		local parent = self:GetParent()
		local maka = parent:GetLinkedHeroEntities()[1]
		local parentabs = parent:GetAbsOrigin()
		return (maka:GetAbsOrigin() - parentabs):Length2D() <= self:GetCastRange(parentabs, maka) and "#dota_hud_error_target_out_of_range" or ""
	end]]

	function soul_eater_demon_weapon_from:OnSpellStart()
		local parent = self:GetParent()
		local maka = parent:GetLinkedHeroEntities()[1]
		local parentabs = parent:GetAbsOrigin()
		if maka and (maka:GetAbsOrigin() - parentabs):Length2D() <= self:GetCastRange(parentabs, maka) then
			local scythe = maka:GetWearableInSlot("weapon")
			if scythe then
				local scythe_ent = scythe.entity
				if IsValidEntity(scythe_ent) then
					scythe_ent:SetVisible(true)
				end
			end
			caster:AddNewModifier(maka, self, "modifier_soul_eater_demon_weapon_from", nil)
		end
	end
end