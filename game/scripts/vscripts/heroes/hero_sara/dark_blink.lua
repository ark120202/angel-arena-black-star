sara_dark_blink = class({})

if IsServer() then
	function sara_dark_blink:OnSpellStart()
		local caster = self:GetCaster()
		if caster.GetEnergy then
			local energyBeforeCast = caster:GetEnergy()
			local wasted = math.max(self:GetSpecialValueFor("min_cost"), caster:GetEnergy() * self:GetSpecialValueFor("energy_pct") * 0.01)
			if caster:GetEnergy() >= wasted then
				caster:ModifyEnergy(-wasted)

				local point = self:GetCursorPosition()
				local casterPos = caster:GetAbsOrigin()
				local blinkRange = self:GetSpecialValueFor("blink_range") + self:GetSpecialValueFor("energy_to_blink_range") * energyBeforeCast * 0.01

				if (point - casterPos):Length2D() > blinkRange then
					point = casterPos + (point - casterPos):Normalized() * blinkRange
				end
				caster:EmitSound('Hero_Antimage.Blink_out')
				ParticleManager:CreateParticle("particles/arena/units/heroes/hero_sara/dark_blink_start.vpcf", PATTACH_ABSORIGIN, caster)
				FindClearSpaceForUnit(caster, point, false)
				caster:EmitSound('Hero_Antimage.Blink_in')
				ParticleManager:CreateParticle("particles/arena/units/heroes/hero_sara/dark_blink_end.vpcf", PATTACH_ABSORIGIN, caster)
				ProjectileManager:ProjectileDodge(caster)
			end
		end
	end
else
	function sara_dark_blink:GetCastRange()
		return self:GetSpecialValueFor("blink_range") + self:GetSpecialValueFor("energy_to_blink_range") * self:GetCaster():GetMana() * 0.01
	end
end
