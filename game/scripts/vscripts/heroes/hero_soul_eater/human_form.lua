soul_eater_human_form = class({})

if IsServer() then
	function soul_eater_human_form:OnSpellStart()
		local caster = self:GetCaster()
		local modifier = caster:FindModifierByName("modifier_soul_eater_demon_weapon_from")
		local maka = modifier:GetCaster()
		modifier:Destroy()
		local point = self:GetCursorPosition()
		
	end
end