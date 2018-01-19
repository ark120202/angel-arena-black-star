modifier_wisp_tether_aghanim_buff = class ({
	IsHidden   = function() return false end,
	IsPurgable = function() return false end,
	GetTexture = function () return "talents/heroes/wisp_aghanim" end,
})

function modifier_wisp_tether_aghanim_buff:DeclareFunctions()
	return { 
		MODIFIER_PROPERTY_IS_SCEPTER
	}
end

function modifier_wisp_tether_aghanim_buff:GetModifierScepter()
	return 1
end

if IsServer() then
	function modifier_wisp_tether_aghanim_buff:OnCreated()
		local parent = self:GetParent()
		for i = 0, parent:GetAbilityCount() - 1 do
			local ability = parent:GetAbilityByIndex(i)
			if ability and ability:GetKeyValue("IsGrantedByScepter") == 1 then
				if ability:GetKeyValue("ScepterGrantedLevel") ~= 0 then
					ability:SetLevel(1)
				end
				ability:SetHidden(false)
			end
		end
	end

	function modifier_wisp_tether_aghanim_buff:OnDestroy()
		local parent = self:GetParent()
		if not parent:HasScepter() then
			for i = 0, parent:GetAbilityCount() - 1 do
				local ability = parent:GetAbilityByIndex(i)
				if ability and ability:GetKeyValue("IsGrantedByScepter") == 1 then
					if ability:GetKeyValue("ScepterGrantedLevel") ~= 0 then
						ability:SetLevel(0)
					end
					ability:SetHidden(true)
				end
			end
		end
	end
end