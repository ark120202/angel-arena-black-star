soul_transform = class({})

function soul_transform:OnSpellStart()
	local caster = self:GetCaster()
	local makas = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 500, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER,false)
	if #makas > 0 then
		local maka = makas[1]
		local scythe = maka:GetWearableInSlot("weapon")
		if scythe then
			local scythe_ent = scythe.entity
			if IsValidEntity(scythe_ent) then
				scythe_ent:SetVisible(true)
			end
		end

		caster:AddNewModifier(caster, self, "soul_transform_scythe_form", nil)
	end
end