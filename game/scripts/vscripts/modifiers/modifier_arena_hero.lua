modifier_arena_hero = class({})

function modifier_arena_hero:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_START
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
end