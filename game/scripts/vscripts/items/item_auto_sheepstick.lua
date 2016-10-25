function AutoSheepstick(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target:IsHero() then
		if target:IsIllusion() then
			target:Kill(ability, caster)
		elseif PreformAbilityPrecastActions(caster, ability) then
			caster:SetCursorCastTarget(target)
			ability:OnSpellStart()
		end
	end
end

function CastHex(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if target:IsIllusion() then
		target:Kill(ability, caster)
	else
		target:AddNewModifier(caster, ability, "modifier_sheepstick_debuff", {duration = keys.hex_duration, sheep_movement_speed = keys.sheep_movement_speed})
		target:AddNewModifier(caster, ability, "modifier_banned", {duration = keys.ban_duration})
	end
end