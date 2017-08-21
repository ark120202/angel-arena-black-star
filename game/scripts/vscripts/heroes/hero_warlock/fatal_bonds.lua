LinkLuaModifier("modifier_warlock_fatal_bonds_arena", "heroes/hero_warlock/fatal_bonds.lua", LUA_MODIFIER_MOTION_NONE)

warlock_fatal_bonds_arena = class({})


function warlock_fatal_bonds_arena:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local search_aoe = self:GetSpecialValueFor("search_aoe")

	target:EmitSound("Hero_Warlock.FatalBonds")

	local targets = { [target] = true }
	local counter = self:GetSpecialValueFor("count") - 1
	for _,v in ipairs(FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, search_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_CLOSEST, false)) do
		if counter >= 1 and not targets[v] then
			counter = counter - 1
			targets[v] = true
		end
	end

	for target in pairs(targets) do
		target.FatalBondsBoundUnits = targets
		target:AddNewModifier(caster, self, "modifier_warlock_fatal_bonds_arena", {
			duration = self:GetSpecialValueFor("duration")
		})

		for v in pairs(targets) do
			local p = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_fatal_bonds_pulse.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
			ParticleManager:SetParticleControl(p, 01, v:GetAbsOrigin() + Vector(0,0,64))
		end
	end
end


modifier_warlock_fatal_bonds_arena = class({
	GetEffectName       = function() return "particles/units/heroes/hero_warlock/warlock_fatal_bonds_icon.vpcf" end,
	GetEffectAttachType = function() return PATTACH_OVERHEAD_FOLLOW end,
	GetAttributes       = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
})

function modifier_warlock_fatal_bonds_arena:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_PROPERTY_TOOLTIP,
	}
end

function modifier_warlock_fatal_bonds_arena:GetModifierIncomingDamage_Percentage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage_taken")
end

function modifier_warlock_fatal_bonds_arena:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("damage_share_percentage")
end

if IsServer() then
	function modifier_warlock_fatal_bonds_arena:OnCreated(keys)
		local parent = self:GetParent()
		self.FatalBondsBoundUnits = parent.FatalBondsBoundUnits
		parent.FatalBondsBoundUnits = nil
	end

	function modifier_warlock_fatal_bonds_arena:OnTakeDamage(keys)
		local target = self:GetParent()
		local ability = self:GetAbility()
		if target == keys.unit and
			not (keys.inflictor and keys.inflictor:GetAbilityName() == ability:GetAbilityName()) then
			if IsValidEntity(target) and target:IsAlive() then
				target:EmitSound("Hero_Warlock.FatalBondsDamage")
				local dmg = keys.damage * self:OnTooltip() * 0.01
				for v in pairs(self.FatalBondsBoundUnits) do
					if IsValidEntity(v) and v ~= target and not v:IsInvulnerable() then
						local p = ParticleManager:CreateParticle("particles/units/heroes/hero_warlock/warlock_fatal_bonds_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
						ParticleManager:SetParticleControl(p, 1, v:GetAbsOrigin() + Vector(0,0,64))
						v:EmitSound("Hero_Warlock.FatalBondsDamage")
						ApplyDamage({
							victim = v,
							attacker = self:GetCaster(),
							damage = dmg,
							damage_type = DAMAGE_TYPE_PURE,
							damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
							ability = ability
						})
					end
				end
			end
		end
	end
end
