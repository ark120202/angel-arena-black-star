boss_cursed_zeld_mind_crack = {}

if IsServer() then
	function boss_cursed_zeld_mind_crack:OnSpellStart()
		local caster = self:GetCaster()
		local health = self:GetSpecialValueFor("clone_health")
		local modelScale = self:GetSpecialValueFor("clone_model_scale")
		local armor = caster:GetPhysicalArmorBaseValue()
		local damageMultiplier = self:GetSpecialValueFor("clone_damage_pct") * 0.01
		local damageMin = caster:GetBaseDamageMin() * damageMultiplier
		local damageMax = caster:GetBaseDamageMax() * damageMultiplier

		for i = 1, self:GetSpecialValueFor("clone_count") do
			local clone = CreateUnitByName(caster:GetUnitName(), caster:GetAbsOrigin() + RandomVector(400), true, nil, nil, caster:GetTeamNumber())
			clone.isMindCrackClone = true
			clone:SetBaseMaxHealth(health)
			clone:SetMaxHealth(health)
			clone:SetHealth(health)
			clone:SetPhysicalArmorBaseValue(armor)
			clone:SetBaseDamageMin(damageMin)
			clone:SetBaseDamageMax(damageMax)
			clone:SetModelScale(modelScale)
			clone:SetDeathXP(0)
			clone:FindAbilityByName("boss_cursed_zeld_shadows_curse"):SetActivated(false)
			clone:FindAbilityByName("boss_cursed_zeld_mind_crack"):SetActivated(false)

			Bosses:MakeBossAI(clone, "cursed_zeld", {})
		end
	end
end
