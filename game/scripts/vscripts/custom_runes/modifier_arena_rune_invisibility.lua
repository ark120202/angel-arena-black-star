modifier_arena_rune_invisibility = class({})

function modifier_arena_rune_invisibility:CheckState() 
	return {
		[MODIFIER_STATE_INVISIBLE] = true
	}
end

function modifier_arena_rune_invisibility:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
		MODIFIER_EVENT_ON_ATTACK
	}
end

function modifier_arena_rune_invisibility:GetModifierInvisibilityLevel()
	return 1
end

function modifier_arena_rune_invisibility:IsPurgable()
	return false
end

function modifier_arena_rune_invisibility:GetTexture()
	return "rune_invis"
end

if IsServer() then
	function modifier_arena_rune_invisibility:OnAbilityExecuted(keys)
		if keys.unit == self:GetParent() then
			self:Destroy()
		end
	end

	function modifier_arena_rune_invisibility:OnAttack(keys)
		if keys.attacker == self:GetParent() then
			self:Destroy()
		end
	end
end