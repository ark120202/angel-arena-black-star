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
	return "arena/arena_rune_flame"
end

if IsServer() then
	function modifier_arena_rune_flame:OnCreated(kv)
		--self:SetStackCount(kv.damage_per_second_max_hp_pct)
		self.damage_per_second_max_hp_pct = kv.damage_per_second_max_hp_pct
		self:StartIntervalThink(0.1)
	end

	function modifier_arena_rune_flame:OnIntervalThink()
		local parent = self:GetParent()
		for _,v in ipairs(FindUnitsInRadius(parent:GetTeam(), parent:GetAbsOrigin(), nil, 350, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			if not v:IsBoss() then
				ApplyDamage({
					attacker = parent,
					victim = v,
					damage_type = DAMAGE_TYPE_MAGICAL,
					damage = self.damage_per_second_max_hp_pct * v:GetMaxHealth() * 0.01 * 0.1,
					ability = self:GetAbility()
				})
			end
		end
	end
end
