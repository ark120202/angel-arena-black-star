function StealHealth(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local pct = ability:GetAbilitySpecial("lifesteal_pct_lvl" .. ability.CurrentLevel)
	if pct then
		local amount = keys.damage * pct * 0.01
		caster:SetHealth(caster:GetHealth() + amount)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, amount, nil)
		ParticleManager:CreateParticle("particles/arena/units/heroes/hero_shinobu/lifesteal_lvl" .. ability.CurrentLevel ..".vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
	end
end

function UpdateStateLevel(keys)
	local caster = keys.caster
	local ability = keys.ability
	if IsValidEntity(ability) then
		local hp = caster:GetHealthPercent()
		local mark_lvl2 = ability:GetAbilitySpecial("hp_mark_pct_lvl2")
		local mark_lvl3 = ability:GetAbilitySpecial("hp_mark_pct_lvl3")
		local mark_lvl4 = ability:GetAbilitySpecial("hp_mark_pct_lvl4")
		local lvl = 1
		if hp >= mark_lvl4 then
			lvl = 4
		elseif hp >= mark_lvl3 then
			lvl = 3
		elseif hp >= mark_lvl2 then
			lvl = 2
		end
		for i = 1, 4 do
			if i ~= lvl then
				caster:RemoveModifierByName("modifier_shinobu_vampire_blood_buff_lvl" .. i)
			end
		end
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_shinobu_vampire_blood_buff_lvl" .. lvl, nil)
		ability.CurrentLevel = lvl
	end
end

function RespawnHealth(keys)
	local caster = keys.caster
	local ability = keys.ability
	Timers:CreateTimer(0.1, function()
		if IsValidEntity(caster) and not caster:IsIllusion() then
			caster:SetHealth(caster:GetMaxHealth() * 0.5)
		end
	end)
end
