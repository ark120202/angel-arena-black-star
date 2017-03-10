function ModifyKarma(unit, amount)
	PLAYER_DATA[unit:GetPlayerID()].Karma = (PLAYER_DATA[unit:GetPlayerID()].Karma or 0) + amount
	if amount < 0 then
		PopupNumbers(unit, "damage", Vector(255, 0, 0), 1.0, -amount, POPUP_SYMBOL_PRE_MINUS, POPUP_SYMBOL_POST_EYE)
	elseif amount > 0 then
		PopupNumbers(unit, "damage", Vector(255, 255, 255), 1.0, amount, POPUP_SYMBOL_PRE_PLUS, POPUP_SYMBOL_POST_EYE)
	end
end

function KarmaOverflowKill(unit)
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_leshrac/leshrac_lightning_bolt.vpcf", PATTACH_WORLDORIGIN, unit)
	ParticleManager:SetParticleControl(particle, 0, unit:GetAbsOrigin() + Vector(0, 0, 0))
	ParticleManager:SetParticleControl(particle, 1, unit:GetAbsOrigin() + Vector(0, 0, 500))
	unit:TrueKill()
end

function SacrificialDaggerOnAttack(keys)
	local ability = keys.ability
	local caster = keys.caster
	local self_damage = ability:GetLevelSpecialValueFor("self_damage", ability:GetLevel() - 1)
	ApplyDamage({
		victim = caster,
		attacker = caster,
		damage = self_damage,
		damage_type = ability:GetAbilityDamageType(),
		ability = ability,
		damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS
	})
	if not caster:HasModifier("modifier_item_consecrated_sword") then
		ModifyKarma(caster, -ability:GetLevelSpecialValueFor("karma_decreasement", ability:GetLevel() - 1))
	elseif caster:IsAlive() then
		KarmaOverflowKill(caster)
	end
end

function ConsecratedSwordOnAttack(keys)
	local ability = keys.ability
	local caster = keys.caster
	local enemy_heal = ability:GetLevelSpecialValueFor("enemy_heal", ability:GetLevel() - 1)
	keys.target:Heal(enemy_heal, ability)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, keys.target, enemy_heal, nil)
	if not caster:HasModifier("modifier_item_sacrificial_dagger") then
		ModifyKarma(caster, ability:GetLevelSpecialValueFor("karma_increasement", ability:GetLevel() - 1))
	elseif caster:IsAlive() then
		KarmaOverflowKill(caster)
	end
end