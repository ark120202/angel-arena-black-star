LinkLuaModifier("modifier_boss_cursed_zeld_three_cores", "heroes/bosses/cursed_zeld/three_cores.lua", LUA_MODIFIER_MOTION_NONE)

boss_cursed_zeld_three_cores = {
	GetIntrinsicModifierName = function() return "modifier_boss_cursed_zeld_three_cores" end,
}


modifier_boss_cursed_zeld_three_cores = {
	IsPurgable = function() return false end,
}

if IsServer() then
	function modifier_boss_cursed_zeld_three_cores:DeclareFunctions()
		return {
			MODIFIER_PROPERTY_REFLECT_SPELL,
			MODIFIER_PROPERTY_ABSORB_SPELL,
		}
	end

	function modifier_boss_cursed_zeld_three_cores:GetReflectSpell(keys)
		local ability = self:GetAbility()
		local parent = self:GetParent()
		local reflectedAbility = keys.ability
		local reflectedCaster = reflectedAbility:GetCaster()

		if ability:PerformPrecastActions() then
			self.isAbsorbed = true
			ParticleManager:SetParticleControlEnt(ParticleManager:CreateParticle("particles/arena/items_fx/lotus_sphere.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent), 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
			parent:EmitSound("Item.LotusOrb.Activate")

			local effect = RandomInt(1, 3)
			if effect == 1 then
				if IsValidEntity(self.reflect_stolen_ability) then
					self.reflect_stolen_ability:RemoveSelf()
				end
				local hAbility = parent:AddAbility(reflectedAbility:GetAbilityName())
				if hAbility then
					hAbility:SetStolen(true)
					hAbility:SetHidden(true)
					hAbility:SetLevel(reflectedAbility:GetLevel())
					parent:SetCursorCastTarget(reflectedCaster)
					hAbility:OnSpellStart()
					hAbility:SetActivated(false)
					self.reflect_stolen_ability = hAbility
				end
			elseif effect == 2 then
				ApplyDamage({
					victim = reflectedCaster,
					attacker = parent,
					damage = parent:GetHealth() * ability:GetAbilitySpecial("damage_pct") * 0.01,
					damage_type = ability:GetAbilityDamageType(),
					ability = ability
				})
			else
				reflectedCaster:AddNewModifier(parent, ability, "modifier_stunned", {
					duration = ability:GetSpecialValueFor("stun_duration"),
				})
			end
		end
	end

	function modifier_boss_cursed_zeld_three_cores:GetAbsorbSpell()
		if self.isAbsorbed then
			self.isAbsorbed = false
			return 1
		end
	end
end
