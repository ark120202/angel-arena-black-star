boss_cursed_zeld_mental_influence = {}

if IsServer() then
	function boss_cursed_zeld_mental_influence:OnSpellStart()
		local caster = self:GetCaster()

		local team = caster:GetTeamNumber()
		local count = self:GetSpecialValueFor("illusion_count")
		local units = FindUnitsInRadius(
			caster:GetTeamNumber(),
			caster:GetAbsOrigin(),
			nil,
			self:GetSpecialValueFor("radius"),
			self:GetAbilityTargetTeam(),
			self:GetAbilityTargetType(),
			self:GetAbilityTargetFlags(),
			FIND_ANY_ORDER,
			false
		)
		for _, unit in ipairs(units) do
			for i = 1, count do
				local illusion = Illusions:create({
					unit = unit,
					ability = self,
					origin = unit:GetAbsOrigin() + RandomVector(100),
					damageIncoming = self:GetSpecialValueFor("illusion_incoming_damage_pct"),
					damageOutgoing = self:GetSpecialValueFor("illusion_outgoing_damage_pct"),
					duration = self:GetSpecialValueFor("illusion_duration"),
					team = team,
					isOwned = false,
				})
				illusion:SetForceAttackTarget(unit)
			end
		end
	end
end
