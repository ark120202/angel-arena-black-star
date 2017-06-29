sai_release_of_forge = class({})
LinkLuaModifier("modifier_release_of_forge", "heroes/hero_sai/modifier_release_of_forge.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_heroes_debuff", "heroes/hero_sai/modifier_release_of_forge.lua", LUA_MODIFIER_MOTION_NONE)

function OnSpellStart(keys)
	local caster = keys.caster
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", level) 
	caster:AddNewModifier(caster, ability, "modifier_release_of_forge", {duration = duration})
end

function HeroesDebuff(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local duration = ability:GetLevelSpecialValueFor("duration", level) 
	target:AddNewModifier(caster, ability, "modifier_heroes_debuff", {duration = duration})
end