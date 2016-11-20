modifier_hero_selection_transformation = class({})

function modifier_hero_selection_transformation:CheckState() 
	return {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NO_TEAM_MOVE_TO] = true,
		[MODIFIER_STATE_NO_TEAM_SELECT] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
	}
end

function modifier_hero_selection_transformation:IsHidden()
	return true
end

function modifier_hero_selection_transformation:IsPurgable()
	return false
end

if IsServer() then
	function modifier_hero_selection_transformation:OnCreated()
		local target = self:GetParent()
		if target then
			target:AddNoDraw()
		end
	end

	function modifier_hero_selection_transformation:OnDestroy()
		local target = self:GetParent()
		if target then
			target:RemoveNoDraw()
		end
	end
end