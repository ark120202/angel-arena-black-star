modifier_item_lotus_sphere_passive = class({})

function modifier_item_lotus_sphere_passive:IsHidden()
	return true
end

function modifier_item_lotus_sphere_passive:IsPurgable()
	return false
end

function modifier_item_lotus_sphere_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_REFLECT_SPELL,
		MODIFIER_PROPERTY_ABSORB_SPELL
	}
end

if IsServer() then

	function modifier_item_lotus_sphere_passive:GetReflectSpell(keys)
		local ability = self:GetAbility()
		if ability:IsCooldownReady() then
			--[[if self.stored then
				self.stored:RemoveSelf()
			end]]
			local hCaster = self:GetParent()
			local hAbility = hCaster:AddAbility(keys.ability:GetAbilityName())
			if hAbility then
				hAbility:SetStolen(true)
				hAbility:SetHidden(true)
				hAbility:SetLevel(keys.ability:GetLevel())
				hCaster:SetCursorCastTarget(keys.ability:GetCaster())
				hAbility:OnSpellStart()
			end
			hAbility:RemoveSelf()
			--[[self.stored = hAbility
			hAbility:SetLevel(0)
			hAbility:Set]]
		end
	end

	function modifier_item_lotus_sphere_passive:GetAbsorbSpell(keys)
		local ability = self:GetAbility()
		if ability:IsCooldownReady() then
			local target = self:GetParent()
			ability:StartCooldown(GetAbilityCooldown(target, ability))

			local pfx = ParticleManager:CreateParticle("particles/arena/items_fx/lotus_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControlEnt(pfx, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)

			return 1
		end
		return false
	end
end