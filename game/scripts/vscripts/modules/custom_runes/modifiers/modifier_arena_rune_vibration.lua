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
		local position = parent:GetAbsOrigin()
		for _,v in ipairs(FindUnitsInRadius(parent:GetTeamNumber(), position, nil, self.fullRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_DAMAGE_FLAG_NONE, FIND_CLOSEST, false)) do
			local force = 0
			local len = (position - v:GetAbsOrigin()):Length2D()
			if len < self.minRadius then
				force = self.fullForce
			elseif len <= self.fullRadius then
				local forceNotFullLen = self.fullRadius - self.minRadius
				local forceMid = self.fullForce - self.minForce
				local forceLevel = (self.fullRadius - len)/forceNotFullLen
				force = self.minForce + (forceMid*forceLevel)
			end

			v:AddNewModifier(caster, self, "modifier_knockback", {
				center_x = position.x,
				center_y = position.y,
				center_z = position.z,
				duration = force / 1000,
				knockback_duration = force / 1000,
				knockback_distance = force / 2,
				knockback_height = force / 50,
			})
		end
		ParticleManager:CreateParticle("particles/arena/generic_gameplay/rune_vibration_owner_wave.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
	end
end
