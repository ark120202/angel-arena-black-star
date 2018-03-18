local factorySYK = require("items/factory_sange_yasha_kaya")

item_nagascale_bow = {
	GetIntrinsicModifierName = function() return "modifier_item_nagascale_bow" end,
}

if IsServer() then
	function item_nagascale_bow:OnProjectileHit(hTarget)
		if not hTarget then return end
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		local number = #caster:FindAllModifiersByName(self:GetIntrinsicModifierName())

		ApplyDamage({
			attacker = caster,
			victim = hTarget,
			damage_type = DAMAGE_TYPE_PHYSICAL,
			damage = caster:GetAverageTrueAttackDamage(target) * self:GetSpecialValueFor("split_damage_pct") * 0.01 * number,
			ability = ability
		})

		hTarget:EmitSound("Hero_Medusa.AttackSplit")
	end
end

item_splitshot_ultimate = {
	GetIntrinsicModifierName = function() return "modifier_item_splitshot_ultimate" end,
	OnProjectileHit = item_nagascale_bow.OnProjectileHit,
}


LinkLuaModifier("modifier_item_nagascale_bow", "items/items_splitshots.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_nagascale_bow = {
	IsHidden = function() return true end,
	IsPurgable = function() return false end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
}

function modifier_item_nagascale_bow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_EVENT_ON_ATTACK,
	}
end
function modifier_item_nagascale_bow:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end
function modifier_item_nagascale_bow:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all")
end
function modifier_item_nagascale_bow:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all")
end
function modifier_item_nagascale_bow:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all")
end


local function fireSplitshotProjectiles(attacker, target, ability, modifierName)
	if not attacker:IsRangedUnit() then return end

	local lockName = "_lock_" .. modifierName
	if attacker[lockName] then return end
	attacker[lockName] = true
	Timers:CreateTimer(function() attacker[lockName] = false end)

	local radius = ability:GetSpecialValueFor("split_radius")
	local targets = FindUnitsInRadius(
		attacker:GetTeam(),
		target:GetAbsOrigin(),
		nil,
		radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
		FIND_CLOSEST,
		false
	)

	local projInfo = GenerateAttackProjectile(attacker, ability)
	for _,v in ipairs(targets) do
		if v ~= target and not v:IsAttackImmune() then
			projInfo.Target = v
			ProjectileManager:CreateTrackingProjectile(projInfo)
		end
	end
end

function modifier_item_nagascale_bow:OnAttack(keys)
	local target = keys.target
	local attacker = keys.attacker
	local ability = self:GetAbility()
	if attacker ~= self:GetParent() then return end
	fireSplitshotProjectiles(attacker, target, ability, self:GetName())
end

LinkLuaModifier("modifier_item_splitshot_ultimate", "items/items_splitshots.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_splitshot_ultimate_maim", "items/items_splitshots.lua", LUA_MODIFIER_MOTION_NONE)
modifier_item_splitshot_ultimate, modifier_item_splitshot_ultimate_maim = factorySYK(
	{ sange = "modifier_item_splitshot_ultimate_maim", yasha = true, kaya = true },
	{ MODIFIER_EVENT_ON_ATTACK }
)
function modifier_item_splitshot_ultimate:OnAttack(keys)
	local target = keys.target
	local attacker = keys.attacker
	local ability = self:GetAbility()
	if attacker ~= self:GetParent() then return end

	fireSplitshotProjectiles(attacker, target, ability, self:GetName())

	if RollPercentage(ability:GetSpecialValueFor("global_attack_chance_pct")) then
		local units = FindUnitsInRadius(
			attacker:GetTeamNumber(),
			Vector(0, 0, 0),
			nil,
			FIND_UNITS_EVERYWHERE,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
			FIND_ANY_ORDER,
			false
		)
		local unit = units[RandomInt(1, #units)]

		local projectile_info = GenerateAttackProjectile(attacker, self)
		projectile_info.Target = unit
		projectile_info.bProvidesVision = true
		projectile_info.iVisionRadius = 250
		projectile_info.iVisionTeamNumber = attacker:GetTeamNumber()
		ProjectileManager:CreateTrackingProjectile(projectile_info)
	end
end
