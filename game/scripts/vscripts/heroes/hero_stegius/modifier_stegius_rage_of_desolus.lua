function BaseAttackTime(keys)
	local caster = keys.caster
	if caster:HasTalent("talent_hero_stegius_rage_of_desolus") then
		keys.target:SetBaseAttackTime(caster:GetTalentSpecial("talent_hero_stegius_rage_of_desolus", "base_attack_time"))
	end
end

function OnBuffDestroy(keys)
	if keys.target:IsHero() then
		keys.target:CalculateStatBonus()
	end
end