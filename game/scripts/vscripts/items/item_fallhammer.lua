function ApplyModifiers(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local buff = "modifier_item_fallhammer_valor_buff"
	local debuff = "modifier_item_fallhammer_valor_debuff"
	if caster:GetTeam() == target:GetTeam() then
		if caster ~= target then
			ability:ApplyDataDrivenModifier(caster, caster, debuff, nil)
			ability:ApplyDataDrivenModifier(caster, target, buff, nil)
			
			caster:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
			target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
		else
			ability:RefundManaCost()
			ability:EndCooldown()
			Containers:EmitSoundOnClient(caster:GetPlayerID(), "General.CastFail_InvalidTarget_Hero")
			Containers:DisplayError(caster:GetPlayerID(), "#dota_hud_error_cant_cast_on_self")
		end
	else
		ability:ApplyDataDrivenModifier(caster, caster, debuff, nil)
		ability:ApplyDataDrivenModifier(caster, target, debuff, nil)
		
		caster:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
		target:EmitSound("DOTA_Item.MedallionOfCourage.Activate")
	end
end