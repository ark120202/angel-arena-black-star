require("kv")
function Interval(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	caster:SetModifierStackCount("modifier_boss_kel_thuzad_immortality", caster, caster:GetModifierStackCount("modifier_boss_kel_thuzad_immortality", caster) + 1)
	local summon_undead = caster:FindAbilityByName("boss_kel_thuzad_summon_undead")
	if summon_undead then
		SummonUnit({
			caster = caster,
			ability = summon_undead,
			summoned = "npc_arena_boss_kel_thuzad_ghost",
			amount = ability:GetSpecialValueFor("ghosts_amount"),
			duration = summon_undead:GetSpecialValueFor("duration"),
			health = summon_undead:GetSpecialValueFor("health"),
			damage = summon_undead:GetSpecialValueFor("damage"),
			movespeed = summon_undead:GetSpecialValueFor("movespeed"),
			base_attack_time = summon_undead:GetSpecialValueFor("base_attack_time"),
			radius = summon_undead:GetSpecialValueFor("radius"),
		})
	end
	local presence_of_death = caster:FindAbilityByName("boss_kel_thuzad_presence_of_death")
	if presence_of_death then
		presence_of_death:OnChannelFinish(false)
	end
end