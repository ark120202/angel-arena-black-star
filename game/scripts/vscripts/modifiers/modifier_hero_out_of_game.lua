modifier_hero_out_of_game = class({
	IsHidden =      function() return true end,
	IsPurgable =    function() return false end,
	IsPermanent =   function() return true end,
	RemoveOnDeath = function() return false end,
})

function modifier_hero_out_of_game:CheckState()
	return {
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_BLIND] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_HEXED] = true
	}
end

if IsServer() then
	function modifier_hero_out_of_game:OnCreated()
		self:GetParent():AddNoDraw()
	end

	function modifier_hero_out_of_game:OnDestroy()
		self:GetParent():RemoveNoDraw()
	end
end
