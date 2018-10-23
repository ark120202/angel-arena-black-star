modifier_arena_wearable = class({})
function modifier_arena_wearable:IsHidden() return true end
function modifier_arena_wearable:CheckState()
	return {
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_BLIND] = true,
	}
end


function modifier_arena_wearable:DeclareFunctions()
	return { MODIFIER_PROPERTY_INVISIBILITY_LEVEL }
end

if IsServer() then
	function modifier_arena_wearable:OnCreated()
		self:StartIntervalThink(1/30)
	end

	function modifier_arena_wearable:OnIntervalThink()
		if self:GetStackCount() > 100  then
			if not self.notDrawing then
				self:GetParent():AddNoDraw()
				--self:GetParent():AddNewModifier(self:GetParent(), nil, "modifier_invisible", nil)
				self.notDrawing = true
			end
		elseif self.notDrawing then
			self:GetParent():RemoveNoDraw()
			self.notDrawing = false
		end
	end
end

if IsClient() then
	function modifier_arena_wearable:GetModifierInvisibilityLevel()
		local stacks = self:GetStackCount()

        if stacks > 100 then
            return (stacks - 101) / 100
        end

        return stacks / 100
	end
end
