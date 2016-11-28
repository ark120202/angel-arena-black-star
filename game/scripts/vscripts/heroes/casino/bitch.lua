function ShowBubble(keys)
	BShowBubble(keys.caster)
end

function DestroyBubble(keys)
	local caster = keys.caster
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, keys.ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	if #heroes < 1 and not caster.Inactive then
		caster:DestroyAllSpeechBubbles()
		caster.HasSpeechBubble = false
	end
end

function Attach(keys)
	local caster = keys.caster
	CosmeticLib:EquipSet( caster, "npc_dota_hero_lina", 20769 )
end