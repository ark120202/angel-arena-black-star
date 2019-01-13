modifier_arthas_vsolyanova_active = class({
	IsPurgable          = function() return false end,
	IsHidden            = function() return true end,
	GetEffectName       = function() return "particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
})

function modifier_arthas_vsolyanova_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_arthas_vsolyanova_active:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

if IsServer() then
	function modifier_arthas_vsolyanova_active:OnCreated()
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_terrorblade/terrorblade_metamorphosis_ambient.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:AddParticle(pfx, false, false, -1, true, false)
	end

	function modifier_arthas_vsolyanova_active:GetModifierModelChange()
		return "models/heroes/terrorblade/demon.vmdl"
	end

	function modifier_arthas_vsolyanova_active:OnAttackLanded(keys)
		if keys.attacker == self:GetParent() then
			local attacker = keys.attacker
			local ability = self:GetAbility()
			local target = keys.target
			local chance = ability:GetAbilitySpecial(attacker:IsIllusion() and "nia_chance_illusions" or "nia_chance") * (attacker:GetTalentSpecial("talent_hero_arthas_vsolyanova_bunus_chance", "chance_multiplier") or 1)
			if not target:IsBoss() and RollPercentage(chance) then
				local duration = ability:GetLevelSpecialValueFor("roar_duration", ability:GetLevel() - 1)
				target:EmitSound("Hero_SkeletonKing.CriticalStrike")
				local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, attacker)
				ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "follow_origin", target:GetAbsOrigin(), true)
				target:TrueKill(ability, attacker)
				if target:IsRealHero() then
					CreateGlobalParticle("particles/arena/units/heroes/hero_skeletonking/alternative_vsolyanova_screen.vpcf", function(particle)
						Timers:CreateTimer(duration, function()
							ParticleManager:DestroyParticle(particle, false)
						end)
					end, PATTACH_EYES_FOLLOW)
					EmitGlobalSound("Arena.Hero_Arthas.Vsolyanova.Impact")
					Notifications:TopToAll({text="#arthas_vsolyanova_notifiaction", duration = duration, style={color="red", ["font-size"]="72px"}})
					local enemies = FindUnitsInRadius(attacker:GetTeamNumber(), attacker:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
					for _,v in ipairs(enemies) do
						ability:ApplyDataDrivenModifier(attacker, v, "modifier_stunned", {duration=duration})
					end
					local allies = FindUnitsInRadius(attacker:GetTeamNumber(), attacker:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
					for _,v in ipairs(allies) do
						if v ~= attacker then
							ability:ApplyDataDrivenModifier(attacker, v, "modifier_silence", {duration=duration})
						end
					end
				end
			end
		end
	end
end
