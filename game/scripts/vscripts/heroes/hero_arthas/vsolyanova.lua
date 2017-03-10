LinkLuaModifier("modifier_arthas_vsolyanova_active", "heroes/hero_arthas/modifier_arthas_vsolyanova_active", LUA_MODIFIER_MOTION_NONE)
function CheckEnemies( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier

	local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)

	if #allies <= 1 then
		if not caster:HasModifier("modifier_arthas_vsolyanova_active") then
			caster:AddNewModifier(caster, ability, "modifier_arthas_vsolyanova_active", nil)
			caster:EmitSound("Arena.Hero_Arthas.Vsolyanova.Transformate")
		end
	else
		if caster:HasModifier("modifier_arthas_vsolyanova_active") then
			caster:RemoveModifierByName("modifier_arthas_vsolyanova_active")
		end
	end
end