modifier_arena_rune_vibration = class({})

function modifier_arena_rune_vibration:GetTexture()
	return "arena/arena_rune_vibration"
end

function modifier_arena_rune_vibration:GetEffectName()
	return "particles/arena/generic_gameplay/rune_vibration.vpcf"
end

function modifier_arena_rune_vibration:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

if IsServer() then
	function modifier_arena_rune_vibration:OnCreated(keys)
		self.minRadius = keys.minRadius
		self.fullRadius = keys.fullRadius
		self.minForce = keys.minForce
		self.fullForce = keys.fullForce
		self:StartIntervalThink(keys.interval)
	end

	function modifier_arena_rune_vibration:OnIntervalThink()
		local parent = self:GetParent()
		CreateExplosion(parent:GetAbsOrigin(), self.minRadius, self.fullRadius, self.minForce, self.fullForce, parent:GetTeamNumber(), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_DAMAGE_FLAG_NONE)
		ParticleManager:CreateParticle("particles/arena/generic_gameplay/rune_vibration_owner_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	end
end
