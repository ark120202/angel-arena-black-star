LinkLuaModifier( "modifier_movespeed_cap", "libraries/modifiers/modifier_movespeed_cap.lua" ,LUA_MODIFIER_MOTION_NONE )

function AddThirst(keys)
	local target = keys.unit
	local caster = keys.caster
	local ability = keys.ability
	local sight_modifier = "modifier_murzik_debuff_datadriven"
	local buff_modifier = "modifier_murzik_buff"
	local buff_visual = "modifier_murzik_visual"
	local healthPercentage = target:GetHealth() / target:GetMaxHealth()
	local buff_threshold = ability:GetLevelSpecialValueFor( "buff_threshold_pct", ability:GetLevel() - 1 )/100
	local visibility_threshold = ability:GetLevelSpecialValueFor( "visibility_threshold_pct", ability:GetLevel() - 1 )/100
	
	if caster:HasModifier("modifier_movespeed_cap") == false then
		caster:AddNewModifier(caster, nil, "modifier_movespeed_cap", {})
	end
	
	if target.stacks == nil then
		target.stacks = 0
	end
	
	local previous_stacks
	if caster:HasModifier(buff_modifier) then
		previous_stacks = caster:GetModifierStackCount(buff_modifier, ability)
	else
		previous_stacks = 0
	end
	
	if target:IsAlive() and healthPercentage <= buff_threshold then
		if healthPercentage < visibility_threshold then
			ability:ApplyDataDrivenModifier(caster, target, sight_modifier, {})
			healthPercentage = visibility_threshold
		end
		if caster:HasModifier(buff_modifier) == false then
			ability:ApplyDataDrivenModifier(caster, caster, buff_modifier, {})
			ability:ApplyDataDrivenModifier(caster, caster, buff_visual, {})
		end
		local new_stacks = math.floor((buff_threshold - healthPercentage)*100)
		caster:SetModifierStackCount(buff_modifier, ability, new_stacks + previous_stacks - target.stacks)
		target.stacks = new_stacks
	else
		caster:SetModifierStackCount(buff_modifier, ability, previous_stacks - target.stacks)
		target.stacks = 0
		if caster:GetModifierStackCount(buff_modifier, ability) == 0 then
			caster:RemoveModifierByName(buff_modifier)
			caster:RemoveModifierByName(buff_visual)
		end
	end
end

function RemoveThirst(keys)
	local target = keys.unit
	local caster = keys.caster
	local ability = keys.ability
	local sight_modifier = "modifier_thirst_debuff_datadriven"
	local buff_modifier = "modifier_thirst_buff"
	local buff_visual = "modifier_thirst_visual"
	local healthPercentage = target:GetHealth() / target:GetMaxHealth()
	local buff_threshold = ability:GetLevelSpecialValueFor( "buff_threshold_pct", ability:GetLevel() - 1 )/100
	local visibility_threshold = ability:GetLevelSpecialValueFor( "visibility_threshold_pct", ability:GetLevel() - 1 )/100
	
	if target.stacks == nil then
		target.stacks = 0
	end
	local previous_stacks
	if caster:HasModifier(buff_modifier) then
		previous_stacks = caster:GetModifierStackCount(buff_modifier, ability)
	else
		previous_stacks = 0
	end
	
	if healthPercentage >= visibility_threshold then
		if target:HasModifier(sight_modifier) then
			target:RemoveModifierByName(sight_modifier)
		end
	end
	
	if healthPercentage > buff_threshold then
		if caster:HasModifier(buff_modifier) then
			caster:SetModifierStackCount(buff_modifier, ability, previous_stacks - target.stacks)
			target.stacks = 0
			if caster:GetModifierStackCount(buff_modifier, ability) == 0 then
				caster:RemoveModifierByName(buff_modifier)
				caster:RemoveModifierByName(buff_visual)
			end
		end
	else
		if healthPercentage < visibility_threshold then
			healthPercentage = visibility_threshold
		end
		local new_stacks =	math.floor((buff_threshold - healthPercentage)*100)
		caster:SetModifierStackCount(buff_modifier, ability, new_stacks + previous_stacks - target.stacks)
		target.stacks = new_stacks
	end
end

function GiveVision(keys)
	caster = keys.caster
	target = keys.target
	
	AddFOWViewer(caster:GetTeam(), target:GetAbsOrigin(), 10, 0.01, false)
end