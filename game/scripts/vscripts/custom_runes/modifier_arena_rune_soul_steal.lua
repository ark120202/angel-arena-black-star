modifier_arena_rune_soul_steal = class({})

function modifier_arena_rune_soul_steal:GetTexture()
	return "arena/arena_rune_soul_steal"
end

function modifier_arena_rune_soul_steal:DeclareFunctions()
	return {MODIFIER_PROPERTY_TOOLTIP}
end

if IsServer() then
	function modifier_arena_rune_soul_steal:GetModifierAura()
		return "modifier_arena_rune_soul_steal_effect"
	end
	function modifier_arena_rune_soul_steal:OnCreated(keys)
		self.radius = keys.radius
		local parent = self:GetParent()
		self.pfx = ParticleManager:CreateParticle("particles/neutral_fx/prowler_shaman_stomp_debuff_glow.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(self.pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
	end
	function modifier_arena_rune_soul_steal:OnDestroy()
		ParticleManager:DestroyParticle(self.pfx, false)
	end
	function modifier_arena_rune_soul_steal:IsAura()
		return true
	end
	function modifier_arena_rune_soul_steal:GetAuraRadius()
		return self.radius
	end
	function modifier_arena_rune_soul_steal:GetAuraDuration()
		return 0.5
	end
	function modifier_arena_rune_soul_steal:GetAuraEntityReject(hEntity)
		return hEntity == self:GetParent() or not hEntity:IsTrueHero()
	end
	function modifier_arena_rune_soul_steal:GetAuraSearchTeam()
		return DOTA_UNIT_TARGET_TEAM_FRIENDLY
	end
	function modifier_arena_rune_soul_steal:GetAuraSearchType()
		return DOTA_UNIT_TARGET_HERO
	end
	function modifier_arena_rune_soul_steal:GetAuraSearchFlags()
		return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS
	end
else
	function modifier_arena_rune_soul_steal:OnTooltip()
		return self:GetStackCount()
	end
end

modifier_arena_rune_soul_steal_effect = class({})

function modifier_arena_rune_soul_steal_effect:GetTexture()
	return "arena/arena_rune_soul_steal"
end

function modifier_arena_rune_soul_steal_effect:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_TOOLTIP}
end

if IsServer() then
	function modifier_arena_rune_soul_steal_effect:OnTakeDamage(keys)
		if keys.unit == self:GetParent() then
			local caster = self:GetCaster()
			local heal = keys.damage * caster:GetModifierStackCount("modifier_arena_rune_soul_steal", caster) * 0.01
			SafeHeal(caster, heal, self:GetAbility())
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, caster, heal, nil)
			local pfx = ParticleManager:CreateParticle("particles/arena/generic_gameplay/rune_soul_steal_owner_effect.vpcf", PATTACH_POINT_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(pfx, 0, keys.unit, PATTACH_POINT_FOLLOW, "attach_hitloc", keys.unit:GetAbsOrigin(), true)
			ParticleManager:SetParticleControlEnt(pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		end
	end
else
	function modifier_arena_rune_soul_steal_effect:OnTooltip()
		local caster = self:GetCaster()
		return caster:GetModifierStackCount("modifier_arena_rune_soul_steal", caster)
	end
end