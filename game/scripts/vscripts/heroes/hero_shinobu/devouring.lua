LinkLuaModifier("modifier_shinobu_devouring", "heroes/hero_shinobu/devouring.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shinobu_devouring_debuff", "heroes/hero_shinobu/devouring.lua", LUA_MODIFIER_MOTION_NONE)

modifier_shinobu_devouring = class({
	IsHidden        = function() return true end,
	IsPermanent     = function() return true end,
	IsPurgable      = function() return false end,
	DestroyOnExpire = function() return false end,
})

function modifier_shinobu_devouring:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ATTACK_LANDED}
end

function modifier_shinobu_devouring:OnAttackLanded(keys)
	local parent = self:GetParent()
	local unit = keys.target
	if keys.attacker == parent and unit:IsRealHero() and not unit:IsIllusion() then 
		local duration = parent:GetTalentSpecial("talent_hero_shinobu_devouring", "duration")
		local modifier = unit:AddNewModifier(parent, nil, "modifier_shinobu_devouring_debuff", {duration = duration})
	end
end

modifier_shinobu_devouring_debuff = class({
	IsHidden   = function() return false end,
	IsPurgable = function() return false end,
	GetTexture = function () return "talents/heroes/shinobu_devouring" end,
})

if IsServer() then
	function modifier_shinobu_devouring_debuff:OnCreated()
		modifier_shinobu_devouring_debuff.thick_interval = 0.5
		self:StartIntervalThink(self.thick_interval)
		self:OnIntervalThink()
	end

	function modifier_shinobu_devouring_debuff:OnIntervalThink()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local damage = parent:GetHealth() * caster:GetTalentSpecial("talent_hero_shinobu_devouring", "damage_pct") * 0.01 * self.thick_interval
		ApplyDamage({
			victim = parent,
			attacker = caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_PURE,
			damage_flags = DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_HPLOSS,
			ability = nil
		})
		caster:SetHealth(caster:GetHealth() + damage * caster:GetTalentSpecial("talent_hero_shinobu_devouring", "damage_to_heal_pct") * 0.01)
	end
end