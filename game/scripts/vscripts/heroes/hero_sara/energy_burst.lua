sara_energy_burst = class({})

if IsServer() then
	function sara_energy_burst:OnSpellStart()
		local caster = self:GetCaster()
		if caster.GetEnergy then
			local wasted = caster:GetEnergy() * self:GetSpecialValueFor("energy_pct") * 0.01
			caster:ModifyEnergy(-wasted)
			local target = self:GetCursorTarget()
			self.damageMap = self.damageMap or {}
			self.damageMap[target] = self.damageMap[target] or {}
			table.insert(self.damageMap[target], wasted * self:GetSpecialValueFor("damage_per_energy_point"))
			print("inserted " .. wasted * self:GetSpecialValueFor("damage_per_energy_point"))
			ProjectileManager:CreateTrackingProjectile({
				EffectName = "particles/units/heroes/hero_vengeful/vengeful_magic_missle.vpcf",
				Ability = self,
				vSpawnOrigin = caster:GetAbsOrigin(),
				Target = target,
				Source = caster,
				bHasFrontalCone = false,
				iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
				bReplaceExisting = false,
			})
		end
	end

	function sara_energy_burst:OnProjectileHit(hTarget)
		local damageMap = self.damageMap
		if hTarget and hTarget ~= self:GetCaster() and damageMap and damageMap[hTarget] and #damageMap[hTarget] > 0 then
			local t = damageMap[hTarget]
			print("Found T: ")
			PrintTable(t)
			local damage = table.remove(t, #t)
			print("apply: " .. damage)
			ApplyDamage({
				attacker = self:GetCaster(),
				victim = hTarget,
				damage_type = self:GetAbilityDamageType(),
				damage = damage,
				ability = self
			})
			--if #t == 0 then self.damageMap[hTarget] = nil end
		end
	end
else
	function sara_energy_burst:GetManaCost()
		return self:GetCaster():GetMana() * self:GetSpecialValueFor("energy_pct") * 0.01
	end
end