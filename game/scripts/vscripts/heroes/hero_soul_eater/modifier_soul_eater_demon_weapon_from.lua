modifier_soul_eater_demon_weapon_from = class({})

if IsServer() then
	function modifier_soul_eater_demon_weapon_from:OnCreated(keys)
		PrintTable(keys)
		self.maka = keys.unit
		self:GetParent():AddNoDraw()
		self:StartIntervalThink(0.1)
	end
	function modifier_soul_eater_demon_weapon_from:OnIntervalThink()
		local parent = self:GetParent()
		parent:SetAbsOrigin(self.maka:GetAbsOrigin())
		if not self.maka:IsAlive() then
			self:Destroy()
		end
	end
	function modifier_soul_eater_demon_weapon_from:OnDestroy()
		self:GetParent():RemoveNoDraw()
		local scythe = self.maka:GetWearableInSlot("weapon")
		if scythe then
			local scythe_ent = scythe.entity
			if IsValidEntity(scythe_ent) then
				scythe_ent:SetVisible(true)
			end
		end
	end
end