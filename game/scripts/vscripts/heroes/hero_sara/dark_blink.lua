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

				FindClearSpaceForUnit(caster, point, false)
				ProjectileManager:ProjectileDodge(caster)
			end
		end
	end
else
	function sara_dark_blink:GetCastRange()
		return self:GetSpecialValueFor("blink_range") + self:GetSpecialValueFor("energy_to_blink_range") * self:GetCaster():GetMana()
	end
end