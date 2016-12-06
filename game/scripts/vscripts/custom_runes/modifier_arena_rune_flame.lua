modifier_arena_rune_flame = class({})

function modifier_arena_rune_flame:GetEffectName()
	return "particles/units/heroes/hero_ember_spirit/ember_spirit_flameguard.vpcf"
end

function modifier_arena_rune_flame:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_arena_rune_flame:IsPurgable()
	return false
end

function modifier_arena_rune_flame:GetTexture()
	return "arena_rune_flame"
end

if IsServer() then
	function modifier_arena_rune_flame:OnCreated()
		self:StartIntervalThink(0.1)
	end

	function modifier_arena_rune_flame:OnIntervalThink()
		local parent = self:GetParent()
		for _,v in ipairs(FindUnitsInRadius(parent:GetTeam(), parent:GetAbsOrigin(), nil, 350, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			ApplyDamage({
				attacker = parent,
				victim = v,
				damage_type = DAMAGE_TYPE_MAGICAL,
				damage = 80 * 0.1,
				ability = self:GetAbility()
			})
		end
	end
end