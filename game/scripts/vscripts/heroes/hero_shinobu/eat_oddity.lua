function Eat(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local gold = RandomInt(target:GetMinimumGoldBounty(), target:GetMaximumGoldBounty())
	gold = gold + gold * ability:GetAbilitySpecial("bonus_gold_pct") * 0.01
	Gold:ModifyGold(caster, gold)
	target:EmitSound("DOTA_Item.Hand_Of_Midas")
	local midas_particle = ParticleManager:CreateParticle("particles/items2_fx/hand_of_midas.vpcf", PATTACH_ABSORIGIN, target)	
	ParticleManager:SetParticleControl(midas_particle, 1, caster:GetAbsOrigin())
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_GOLD, caster, gold, nil)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_shinobu_eat_oddity_buff", { duration = ability:GetAbilitySpecial("buff_duration") })
	caster:SetModifierStackCount("modifier_shinobu_eat_oddity_buff", caster, math.floor(target:GetHealth() * ability:GetAbilitySpecial("buff_health_pct") * 0.01))
	caster:CalculateStatBonus()
	FindClearSpaceForUnit(caster, target:GetAbsOrigin(), true)
	target:SetMinimumGoldBounty(0)
	target:SetMaximumGoldBounty(0)
	target:Kill(ability, caster)
end