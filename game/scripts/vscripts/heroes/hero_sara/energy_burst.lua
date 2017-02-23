sara_energy_burst = class({})

function sara_energy_burst:CastFilterResultTarget(hTarget)
	if IsServer() then
		if hTarget and hTarget:IsMagicImmune() and not self:GetCaster():HasScepter() then
			return UF_FAIL_MAGIC_IMMUNE_ENEMY
		end
		return UnitFilter(hTarget, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), self:GetCaster():GetTeamNumber())
	end
	return UF_SUCCESS
end

if IsServer() then
	function sara_energy_burst:OnSpellStart()
		local caster = self:GetCaster()
		if caster.GetEnergy then
			local wasted = math.max(self:GetSpecialValueFor("min_cost"), caster:GetEnergy() * self:GetSpecialValueFor("energy_pct") * 0.01)
			if caster:GetEnergy() >= wasted then
				caster:ModifyEnergy(-wasted)
				local target = self:GetCursorTarget()
				local pfx = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_sara/energy_burst.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
				ParticleManager:SetParticleControlEnt(pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_attack2", caster:GetOrigin(), true)
				ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetOrigin(), true)
				Timers:CreateTimer(0.2, function()
					if IsValidEntity(caster) and IsValidEntity(self) and IsValidEntity(target) then
						caster:EmitSound("Ability.LagunaBlade")
						target:EmitSound("Ability.LagunaBladeImpact")
						for _,v in ipairs(caster:HasScepter() and FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, self:GetSpecialValueFor("damage_aoe_scepter"), self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags() + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false) or {target}) do
							ApplyDamage({
								attacker = caster,
								victim = v,
								damage_type = self:GetAbilityDamageType(),
								damage = wasted * self:GetSpecialValueFor("damage_per_energy_point"),
								ability = self
							})
							if caster:HasScepter() then
								ApplyDamage({
									attacker = caster,
									victim = v,
									damage_type = DAMAGE_TYPE_PURE,
									damage = wasted * self:GetSpecialValueFor("pure_per_energy_point_scepter"),
									ability = self
								})
							end
						end
					end
				end)
			end
		end
	end
else
	function sara_energy_burst:GetManaCost()
		return math.max(self:GetSpecialValueFor("min_cost"), self:GetCaster():GetMana() * self:GetSpecialValueFor("energy_pct") * 0.01)
	end
end