omniknight_purification_lua = class({})

function omniknight_purification_lua:OnSpellStart() if IsServer() then
	local radius = self:GetSpecialValueFor("radius")
	local targets = {}
	if self:GetCaster():HasModifier("modifier_omniknight_select_allies") or self:GetCaster():HasModifier("modifier_omniknight_select_enemies") then
		if self:GetCaster():HasModifier("modifier_omniknight_select_allies") then
			for _,v in ipairs(HeroList:GetAllHeroes()) do
				if v:IsAlive() and self:GetCaster():GetTeamNumber() == v:GetTeamNumber() then
					table.insert(targets, v)
				end
			end
		elseif self:GetCaster():HasModifier("modifier_omniknight_select_enemies") then
			for _,v in ipairs(HeroList:GetAllHeroes()) do
				if v:IsAlive() and self:GetCaster():GetTeamNumber() ~= v:GetTeamNumber() then
					table.insert(targets, v)
				end
			end
		end
	else
		targets = {self:GetCursorTarget()}
	end
	for _,target in ipairs(targets) do
		target:EmitSound("Hero_Omniknight.Purification")
		local pfx = ParticleManager:CreateParticle(self:GetCaster():TranslateParticle("particles/units/heroes/hero_omniknight/omniknight_purification.vpcf"), PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControl(pfx, 1, Vector(radius, radius, radius))
		ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		for _,v in ipairs(FindUnitsInRadius(self:GetCaster():GetTeamNumber(), target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)) do
			if self:GetCaster():GetTeamNumber() == v:GetTeamNumber() then
				SafeHeal(v, self:GetSpecialValueFor("heal"), self:GetCaster())
				SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, v, self:GetSpecialValueFor("heal"), nil)
			else
				ApplyDamage({
					victim = v,
					attacker = self:GetCaster(),
					damage = self:GetSpecialValueFor("heal"),
					damage_type = self:GetAbilityDamageType(),
					ability = self
				})
			end
			local hit_pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_purification_hit.vpcf", PATTACH_ABSORIGIN, target)
			ParticleManager:SetParticleControlEnt(hit_pfx, 1, v, PATTACH_POINT_FOLLOW, "follow_origin", v:GetAbsOrigin(), true)
		end
	end
end end

function omniknight_purification_lua:GetBehavior()
	if self:GetCaster():HasModifier("modifier_omniknight_select_allies") or self:GetCaster():HasModifier("modifier_omniknight_select_enemies") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
end