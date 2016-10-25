function item_homemade_cheese_on_spell_start(keys)
	local ability = keys.ability
	local target = keys.target
	target:Heal(keys.HealthRestore, keys.caster)
	target:GiveMana(keys.ManaRestore)
	if target == keys.caster then
		ability:EndCooldown()
		ability:StartCooldown(ability:GetSpecialValueFor("alternative_cooldown"))
	end
end