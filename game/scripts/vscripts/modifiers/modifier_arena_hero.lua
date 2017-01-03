modifier_arena_hero = class({})

function modifier_arena_hero:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
end

function modifier_arena_hero:IsPurgable()
	return false
end

function modifier_arena_hero:IsHidden()
	return true
end

function modifier_arena_hero:RemoveOnDeath()
	return false
end

function modifier_arena_hero:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

if IsServer() then
	function modifier_arena_hero:OnAttackStart(keys)
		local parent = self:GetParent()
		if keys.attacker == parent and keys.target:IsCustomRune() then
			parent:Stop()
			ExecuteOrderFromTable({
				UnitIndex = parent:GetEntityIndex(), 
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				Position = parent:GetAbsOrigin(),
			})
		end
	end
	function modifier_arena_hero:OnAbilityExecuted(keys)
		if self:GetParent() == keys.unit then
			local ability_cast = keys.ability
			local abilityname = ability_cast ~= nil and ability_cast:GetAbilityName()
			local caster = self:GetParent()
			local target = keys.target or caster:GetCursorPosition()
			if caster.talents_ability_multicast and caster.talents_ability_multicast[abilityname] then
				for i = 1, caster.talents_ability_multicast[abilityname] - 1 do
					Timers:CreateTimer(0.1*i, function()
						if IsValidEntity(caster) and IsValidEntity(ability_cast) then
							CastAdditionalAbility(caster, ability_cast, target)
						end
					end)
				end
			end
		end
	end
end