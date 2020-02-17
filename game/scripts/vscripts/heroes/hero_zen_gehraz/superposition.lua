function Superposition(keys)
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
	local distance = ability:GetAbilitySpecial("distance")
	local castPosition = caster:GetAbsOrigin()
	if (point - castPosition):Length2D() > distance then
		point = castPosition + (point - castPosition):Normalized() * distance
	end

	local illusion_duration = ability:GetAbilitySpecial("illusion_duration")
	local illusion = Illusions:create({
		unit = caster,
		damageIncoming = ability:GetAbilitySpecial("illusion_damage_percent_incoming"),
		damageOutgoing = ability:GetAbilitySpecial("illusion_damage_percent_outgoing"),
		duration = illusion_duration,
	})[1]

	FindClearSpaceForUnit(caster, point, false)
	caster:EmitSound("Arena.Hero_ZenGehraz.Superposition")

	Timers:NextTick(function()
		if not (ability.LastInterruptedAbilityTime and GameRules:GetGameTime() - ability.LastInterruptedAbilityTime < 0.5 and ability.LastInterruptedAbility and ability.LastInterruptedAbilityCastTime) then return end

		local name = ability.LastInterruptedAbility:GetAbilityName()
		local illusion_ability = illusion:FindAbilityByName(name)
		local channel_time = math.min(illusion_duration, illusion_ability:GetAbilitySpecial("channel_time") - (GameRules:GetGameTime() - ability.LastInterruptedAbilityCastTime))
		if channel_time > 0 then
			if name == "zen_gehraz_divine_intervention" then
				illusion:AddNewModifier(caster, ability, "modifier_stunned", {duration = channel_time})
				if ability.LastInterruptedAbilityTarget and IsValidEntity(ability.LastInterruptedAbilityTarget) then
					illusion_ability:ApplyDataDrivenModifier(illusion, ability.LastInterruptedAbilityTarget, "modifier_zen_gehraz_divine_intervention", {duration = channel_time})
				end
				illusion_ability.modifier_zen_gehraz_divine_intervention_destroy = function(_keys)
					_keys.caster:RemoveModifierByNameAndCaster("modifier_stunned", caster)
				end
			elseif name == "zen_gehraz_mystic_twister" then
				illusion:AddNewModifier(caster, ability, "modifier_stunned", {duration = channel_time})
				illusion_ability.thinker_dummy = CreateUnitByName("npc_dummy_unit", ability.LastInterruptedAbilityTarget, true, illusion, nil, illusion:GetTeam())
				illusion_ability:ApplyDataDrivenModifier(illusion, illusion_ability.thinker_dummy, "modifier_zen_gehraz_mystic_twister_thinker", nil)
				illusion_ability.thinker_dummy.particle = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_zen_gehraz/mystic_twister.vpcf", PATTACH_ABSORIGIN, illusion_ability.thinker_dummy)
				ParticleManager:SetParticleControl(illusion_ability.thinker_dummy.particle, 1, Vector(illusion_ability:GetAbilitySpecial("radius")))
				illusion_ability.thinker_dummy:EmitSound("Arena.Hero_ZenGehraz.MysticTwister")
				Timers:CreateTimer(channel_time, function()
					if IsValidEntity(illusion_ability) and IsValidEntity(illusion_ability.thinker_dummy) then
						ParticleManager:DestroyParticle(illusion_ability.thinker_dummy.particle, false)
						illusion_ability.thinker_dummy:StopSound("Arena.Hero_ZenGehraz.MysticTwister")
						illusion_ability.thinker_dummy:ForceKill(false)
						UTIL_Remove(illusion_ability.thinker_dummy)
						illusion_ability.thinker_dummy = nil
					end
				end)
			elseif name == "zen_gehraz_vow_of_silence" then
				illusion:AddNewModifier(caster, ability, "modifier_stunned", {duration = channel_time})
				illusion_ability:ApplyDataDrivenModifier(illusion, illusion, "modifier_zen_gehraz_vow_of_silence", {duration = channel_time})
			end
		end
	end)
end

function OnChanneledAbilityInterrupted(keys)
	local caster = keys.caster
	local ability = keys.ability
	local superposition = caster:FindAbilityByName("zen_gehraz_superposition")
	if superposition then
		superposition.LastInterruptedAbility = ability
		superposition.LastInterruptedAbilityTime = GameRules:GetGameTime()
	end
end

function OnChanneledAbilityExecuted(keys)
	local caster = keys.caster
	local ability = keys.ability
	local superposition = caster:FindAbilityByName("zen_gehraz_superposition")
	if superposition then
		superposition.LastInterruptedAbility = ability
		superposition.LastInterruptedAbilityTarget = keys.target
		superposition.LastInterruptedAbilityCastTime = GameRules:GetGameTime()
		if keys.target_points then
			superposition.LastInterruptedAbilityTarget = keys.target_points[1]
		end
	end
end
