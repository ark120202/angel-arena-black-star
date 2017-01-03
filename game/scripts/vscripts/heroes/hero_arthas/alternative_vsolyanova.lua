function ModelSwapStart( keys )
	SwapModel(keys.caster, keys.model, 10, true)
end
function ModelSwapEnd( keys )
	SwapModelBack(keys.caster, true)
end

function CheckEnemies( keys )
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", ability:GetLevel() - 1)
	local modifier = keys.modifier

	local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)

	if #allies <= 1 then
		if not caster:HasModifier(modifier) and not caster:HasModifier("modifier_arthas_vikared") then
			ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
			caster:EmitSound("Arena.Hero_Arthas.Vsolyanova.Transformate")
		end
	else
		if caster:HasModifier(modifier) then
			caster:RemoveModifierByName(modifier)
		end
	end
end

function InstantKill(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local chance = ability:GetAbilitySpecial(caster:IsIllusion() and "nia_chance_illusions" or "nia_chance") * (caster:GetTalentSpecial("talent_hero_arthas_vsolyanova_bunus_chance", "chance_multiplier") or 1)
	if not target:IsBoss() and RollPercentage(chance) then
		local duration = ability:GetLevelSpecialValueFor("roar_duration", ability:GetLevel() - 1)
		target:EmitSound("Hero_SkeletonKing.CriticalStrike")
		local pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, caster)
		ParticleManager:SetParticleControlEnt(pfx, 1, target, PATTACH_POINT_FOLLOW, "follow_origin", target:GetAbsOrigin(), true)
		TrueKill(caster, caster, target)
		if target:IsRealHero() then
			CreateGlobalParticle("particles/arena/units/heroes/hero_skeletonking/alternative_vsolyanova_screen.vpcf", function(particle)
				Timers:CreateTimer(duration, function()
					ParticleManager:DestroyParticle(particle, false)
				end)
			end, PATTACH_EYES_FOLLOW)
			EmitGlobalSound("Arena.Hero_Arthas.Vsolyanova.Impact")
			Notifications:TopToAll({text="#arthas_vsolyanova_notifiaction", duration = duration, style={color="red", ["font-size"]="72px"}})
			local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
			for _,v in ipairs(enemies) do
				ability:ApplyDataDrivenModifier(caster, v, "modifier_stunned", {duration=duration})
			end
			local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
			for _,v in ipairs(allies) do
				if v ~= caster then
					ability:ApplyDataDrivenModifier(caster, v, "modifier_silence", {duration=duration})
				end
			end
		end
	end
end