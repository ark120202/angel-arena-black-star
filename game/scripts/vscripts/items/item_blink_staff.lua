function item_blink_staff_blink(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target
	if not ability:GetCursorTargetingNothing() then
		target = ability:GetCursorTarget()
	end
	local point = ability:GetCursorPosition()
	local MaxBlinkRange = keys.MaxBlinkRange
	local SelectedUntiModifierName = "modifier_item_blink_staff_selected_unit"

	local hModifier = caster:FindModifierByNameAndCaster(SelectedUntiModifierName, caster)
	if hModifier then
		local target2 = EntIndexToHScript(hModifier:GetStackCount())
		if target2:FindModifierByNameAndCaster(SelectedUntiModifierName, caster) and target ~= target2 then
			Blink(ability, caster, target2, point, MaxBlinkRange)
			target2:RemoveModifierByName(SelectedUntiModifierName)
			caster:RemoveModifierByName(SelectedUntiModifierName)
		else
			Blink(ability, caster, caster, point, MaxBlinkRange)
			target2:RemoveModifierByName(SelectedUntiModifierName)
			caster:RemoveModifierByName(SelectedUntiModifierName)
		end
	else
		if target then
			if caster == target then
				local hModifier = caster:FindModifierByNameAndCaster(SelectedUntiModifierName, caster)
				if hModifier then
					target = EntIndexToHScript(hModifier:GetStackCount())
					if target:FindModifierByNameAndCaster(SelectedUntiModifierName, caster) then
						Blink(ability, caster, target, point, MaxBlinkRange)
						target:RemoveModifierByName(SelectedUntiModifierName)
						caster:RemoveModifierByName(SelectedUntiModifierName)
					else
						Blink(ability, caster, caster, point, MaxBlinkRange)
						target:RemoveModifierByName(SelectedUntiModifierName)
						caster:RemoveModifierByName(SelectedUntiModifierName)
					end
				else
					point = caster:GetAbsOrigin() + (caster:GetForwardVector():Normalized() * MaxBlinkRange)
					Blink(ability, caster, caster, point, MaxBlinkRange)
				end
			else
				ability:ApplyDataDrivenModifier(caster, target, SelectedUntiModifierName,  { duration = ability:GetReducedCooldown()} )
				ability:ApplyDataDrivenModifier(caster, caster, SelectedUntiModifierName,  { duration = ability:GetReducedCooldown()} )
				local hModifier = caster:FindModifierByNameAndCaster(SelectedUntiModifierName, caster)
				local nTargetIndex = target:GetEntityIndex()
				hModifier:SetStackCount(nTargetIndex)
				ability:EndCooldown()
				ability:RefundManaCost()
			end
		else
			Blink(ability, caster, caster, point, MaxBlinkRange)
		end
	end
end

function Blink(ability, caster, Target, Point, MaxBlink)
	local Origin = Target:GetAbsOrigin()
	ProjectileManager:ProjectileDodge(Target)
	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_start.vpcf", PATTACH_ABSORIGIN, Target)
	Target:EmitSound("DOTA_Item.BlinkDagger.Activate")
	local Diff = Point - Origin
	if Diff:Length2D() > MaxBlink then
		Point = Origin + (Point - Origin):Normalized() * MaxBlink
	end
	Target:SetAbsOrigin(Point)
	FindClearSpaceForUnit(Target, Point, true)
	ParticleManager:CreateParticle("particles/items_fx/blink_dagger_end.vpcf", PATTACH_ABSORIGIN, Target)
	ability:ApplyDataDrivenModifier(caster, Target, "modifier_item_blink_staff_unobstructed_movement", {})
end

function modifier_item_blink_staff_damage_cooldown(keys)
	local attacker = keys.attacker
	if attacker then
		if keys.Damage > keys.blink_damage_to_cooldown and ((attacker.IsControllableByAnyPlayer and attacker:IsControllableByAnyPlayer()) or attacker:IsBoss()) then
			if keys.ability:GetCooldownTimeRemaining() < keys.BlinkDamageCooldown then
				keys.ability:StartCooldown(keys.BlinkDamageCooldown)
			end
		end
	end
end

function CreatePfx(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	if target ~= caster then
		if not ability.Pfxes then ability.Pfxes = {} end
		if ability.Pfxes[target] then
			ParticleManager:DestroyParticle(ability.Pfxes[target], false)
		end
		ability.Pfxes[target] = ParticleManager:CreateParticleForTeam("particles/econ/courier/courier_trail_05/courier_trail_05.vpcf", PATTACH_ABSORIGIN_FOLLOW, target, caster:GetTeamNumber())
		ParticleManager:SetParticleControl(ability.Pfxes[target], 15, Vector(20, 0, 255))
	end
end

function DestroyPfx(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if ability.Pfxes and ability.Pfxes[target] then
		ParticleManager:DestroyParticle(ability.Pfxes[target], false)
	end
end