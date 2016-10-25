LinkLuaModifier("modifier_elder_dragon_form_lua", "heroes/hero_dragon_knight/modifiers/modifier_elder_dragon_form_lua.lua", LUA_MODIFIER_MOTION_NONE)

dragon_knight_elder_dragon_form_arena = class({})

function OnSpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local level = ability:GetLevel() - 1
	local duration = ability:GetLevelSpecialValueFor("duration", level) 
	if caster.DragonFormIllusions then
		for _,v in ipairs(caster.DragonFormIllusions) do
			if v and not v:IsNull() and v:IsAlive() then
				v:ForceKill(false)
			end
		end
	end
	if ability:GetLevel() >= 7 then
		caster.DragonFormIllusions = {}
		local forms = UniqueRandomInts(1, 6, ability:GetLevelSpecialValueFor("illusion_amount", level))
		for i = 1, ability:GetLevelSpecialValueFor("illusion_amount", level) do
			local illusion = CreateIllusion(caster, ability, caster:GetAbsOrigin() + RandomVector(100), ability:GetLevelSpecialValueFor("illusion_damage_percent_incoming", level), ability:GetLevelSpecialValueFor("illusion_damage_percent_outgoing", level), duration)
			illusion:SetForwardVector(caster:GetForwardVector())
			illusion:AddNewModifier(caster, ability, "modifier_elder_dragon_form_lua", {duration = duration, Level = forms[i]})
			FindClearSpaceForUnit(illusion, illusion:GetAbsOrigin(), true)
			table.insert(caster.DragonFormIllusions, illusion)
		end
		FindClearSpaceForUnit(caster, caster:GetAbsOrigin() + RandomVector(100), true)
	end
	caster:RemoveModifierByName("modifier_elder_dragon_form_lua")
	caster:AddNewModifier(caster, ability, "modifier_elder_dragon_form_lua", {duration = duration})
end

function PoisonDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ApplyDamage({
		attacker = caster,
		victim = target,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage = ability:GetLevelSpecialValueFor("poison_damage", ability:GetLevel() - 1),
		ability = ability
	})
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_POISON_DAMAGE, target, ability:GetLevelSpecialValueFor("poison_damage", ability:GetLevel() - 1), nil)
end

function ColdDamage(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local dmg = target:GetHealth() * ability:GetLevelSpecialValueFor("cold_damage_pct", ability:GetLevel() - 1) * 0.01
	ApplyDamage({
		attacker = caster,
		victim = target,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage = dmg,
		ability = ability
	})
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, dmg, nil)
end

function AddDebuffStack(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ModifyStacks(ability, caster, target, "modifier_dragon_knight_elder_dragon_form_arena_flame_debuff_tooltip", 1, true)
end

function RemoveDebuffStack(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	ModifyStacks(ability, caster, target, "modifier_dragon_knight_elder_dragon_form_arena_flame_debuff_tooltip", -1, true)
end