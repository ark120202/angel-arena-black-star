modifier_arena_hero_wisp = class({})

function modifier_arena_hero_wisp:IsPurgable()
	return false
end

function modifier_arena_hero_wisp:IsHidden()
	return true
end

function modifier_arena_hero_wisp:RemoveOnDeath()
	return false
end

function modifier_arena_hero_wisp:GetAttributes()
	return MODIFIER_ATTRIBUTE_PERMANENT
end

if IsServer() then
	function modifier_arena_hero_wisp:OnCreated()
		self:StartIntervalThink(0.1)
	end
	function modifier_arena_hero_wisp:DeclareFunctions()
		return {
			--MODIFIER_EVENT_ON_DEATH,
			--MODIFIER_EVENT_ON_STATE_CHANGED
		}
	end
	--todo
	--[[function modifier_arena_hero_wisp:OnDeath(keys)
		if k.unit == self:GetParent() then
			ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/.vpcf", PATTACH_ABSORIGIN_FOLLOW, k.unit)
		end
	end]]
	function modifier_arena_hero_wisp:OnIntervalThink()
		local parent = self:GetParent()
		local isStunned = parent:IsStunned()
		if isStunned and not self.pfx then
			self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_stunned_original.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent, 0, "attach_hitloc")
		elseif not isStunned and self.pfx then
			ParticleManager:DestroyParticle(self.pfx, false)
			self.pfx = nil
		end
	end
end