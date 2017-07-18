maka_soul_resonance = class({})

if IsServer() then
	function maka_soul_resonance:CastFilterResult()
		local soul = self:GetCaster():GetLinkedHeroEntities()[1]
		return soul:HasModifier("modifier_soul_eater_demon_weapon_from") and UF_SUCCESS or UF_FAIL_CUSTOM
	end

	function maka_soul_resonance:GetCustomCastError()
		local soul = self:GetCaster():GetLinkedHeroEntities()[1]
		return soul:HasModifier("modifier_soul_eater_demon_weapon_from") and "" or "arena_hud_error_todo"
	end

	function maka_soul_resonance:OnSpellStart()
		local maka = self:GetCaster()
		local soul = maka:GetLinkedHeroEntities()[1]
		if soul:HasModifier("modifier_soul_eater_soul_resonance_channel") then
			local duration = self:GetSpecialValueFor("duration")
			print("RESONANCE!")
			maka:AddNewModifier(maka, self, "", {duration = duration})
			soul:AddNewModifier(maka, self, "", {duration = duration})
		end
	end
end
