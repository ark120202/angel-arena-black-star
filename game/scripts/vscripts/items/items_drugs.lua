function DrugEffectStrangeMoveKV(keys)
	local target = keys.target
	local amplitude = keys.amplitude
	DrugEffectStrangeMove(target, amplitude)
end

function DrugEffectRandomParticlesKV(keys)
	local target = keys.target
	if RandomInt(1, 25) <= 2 then
		DrugEffectRandomParticles(target, keys.duration)
	end
end

----------------------------------------------------------------------------------------------

function ApplyDrugModifers(keys)
	local target = keys.target or keys.caster
	target.DrugEffectInversedOrders = true
	local ability = keys.ability
	local modifier_addiction = keys.modifier_addiction
	local modifier_buff = keys.modifier_buff
	local modifier_debuff = keys.modifier_debuff

	LinkLuaModifier(modifier_addiction, "items/lua/modifiers/" .. modifier_addiction .. ".lua", LUA_MODIFIER_MOTION_NONE)
	local multiplier = target:GetModifierStackCount(modifier_addiction, target) / 2
	if multiplier < 1 then multiplier = 1 end
	local duration_debuff = multiplier * ability:GetSpecialValueFor("duration_debuff_multiplier")
	ModifyStacksLua(ability, target, target, modifier_addiction, 1, true, {keys=keys})
	ability:ApplyDataDrivenModifier(target, target, modifier_debuff, {duration=duration_debuff})
	ability:ApplyDataDrivenModifier(target, target, modifier_buff, {})
end