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
		local parent = self:GetParent()
		local maka = self:GetCaster()
		parent:AddNoDraw()
		self:StartIntervalThink(1/30)
		parent:SwapAbilities("soul_eater_demon_weapon_from", "soul_eater_human_form", false, true)
	end
	
	function modifier_soul_eater_demon_weapon_from:OnIntervalThink()
		local parent = self:GetParent()
		local maka = self:GetCaster()
		parent:SetAbsOrigin(maka:GetAbsOrigin())
		if not maka:IsAlive() then
			self:Destroy()
		end
	end
	function modifier_soul_eater_demon_weapon_from:OnDestroy()
		local parent = self:GetParent()
		parent:RemoveNoDraw()
		local maka = self:GetCaster()
		local scythe = maka:GetWearableInSlot("weapon")
		if scythe then
			local scythe_ent = scythe.entity
			if IsValidEntity(scythe_ent) then
				scythe_ent:SetVisible(true)
			end
		end
		parent:SwapAbilities("soul_eater_demon_weapon_from", "soul_eater_human_form", true, false)
	end
end