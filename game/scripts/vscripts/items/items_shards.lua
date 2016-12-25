function AddStat(keys)
	local caster = keys.caster
	if caster:HasModifier("modifier_arc_warden_tempest_double") then
		return
	end
	local ability = keys.ability
	local str = keys.str
	local agi = keys.agi
	local int = keys.int
	if str then
		caster:ModifyStrength(str)
		caster.Additional_str = (caster.Additional_str or 0) + str
	end
	if agi then
		caster:ModifyAgility(agi)
		caster.Additional_agi = (caster.Additional_agi or 0) + agi
	end
	if int then
		caster:ModifyIntellect(int)
		caster.Additional_int = (caster.Additional_int or 0) + int
	end
end
function AddAttackspeedModifier(keys)
	local caster = keys.caster
	if caster:HasModifier("modifier_arc_warden_tempest_double") then
		return
	end
	local ability = keys.ability
	if not caster:HasModifier("modifier_item_shard_attackspeed_stack") then
		caster:AddNewModifier(caster, ability, "modifier_item_shard_attackspeed_stack", {})
	end
	local mod = caster:FindModifierByName("modifier_item_shard_attackspeed_stack")
	if mod then
		mod:IncrementStackCount()
	end
	caster.Additional_attackspeed = mod:GetStackCount()
end

function AddLevel(keys)
	local caster = keys.caster
	local level = caster:GetLevel()
	local levels = 1
	for _,v in ipairs(caster:FindAllModifiersByName("modifier_arena_rune_acceleration")) do
		if v.xp_multiplier then
			levels = levels * v.xp_multiplier
		end
	end
	for i = 1, levels do
		if caster:HasModifier("modifier_arc_warden_tempest_double") or not XP_PER_LEVEL_TABLE[level + 1] then
			return
		end
		local ability = keys.ability
		caster:AddExperience(XP_PER_LEVEL_TABLE[level + 1] - XP_PER_LEVEL_TABLE[level], 0, false, false)
	end
end