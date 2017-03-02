modifier_destroyer_frenzy = class({})

function modifier_destroyer_frenzy:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_destroyer_frenzy:GetModifierMoveSpeed_Max()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local level
	local healht_pct = parent:GetHealth() / parent:GetMaxHealth() * 100
	if healht_pct < ability:GetSpecialValueFor("hp_mark_pct_lvl3") then
		level = 3
	elseif	healht_pct < ability:GetSpecialValueFor("hp_mark_pct_lvl2") then
		level = 2
	elseif	healht_pct < ability:GetSpecialValueFor("hp_mark_pct_lvl1") then
		level = 1
	end
	if level then
		return ability:GetSpecialValueFor("max_speed_lvl" .. level)
	end
end
function modifier_destroyer_frenzy:GetModifierMoveSpeed_Limit()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local level
	local healht_pct = parent:GetHealth() / parent:GetMaxHealth() * 100
	if healht_pct < ability:GetSpecialValueFor("hp_mark_pct_lvl3") then
		level = 3
	elseif	healht_pct < ability:GetSpecialValueFor("hp_mark_pct_lvl2") then
		level = 2
	elseif	healht_pct < ability:GetSpecialValueFor("hp_mark_pct_lvl1") then
		level = 1
	end
	if level then
		return ability:GetSpecialValueFor("max_speed_lvl" .. level)
	end
end
function modifier_destroyer_frenzy:GetModifierPhysicalArmorBonus()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local level
	local healht_pct = parent:GetHealth() / parent:GetMaxHealth() * 100
	if healht_pct < ability:GetSpecialValueFor("hp_mark_pct_lvl3") then
		level = 3
	elseif	healht_pct < ability:GetSpecialValueFor("hp_mark_pct_lvl2") then
		level = 2
	elseif	healht_pct < ability:GetSpecialValueFor("hp_mark_pct_lvl1") then
		level = 1
	end
	if level then
		return ability:GetSpecialValueFor("bonus_armor_lvl" .. level)
	end
end
function modifier_destroyer_frenzy:GetModifierPreAttack_BonusDamage()
	local ability = self:GetAbility()
	local parent = self:GetParent()
	local level
	local healht_pct = parent:GetHealth() / parent:GetMaxHealth() * 100
	if healht_pct < ability:GetSpecialValueFor("hp_mark_pct_lvl3") then
		level = 3
	elseif	healht_pct < ability:GetSpecialValueFor("hp_mark_pct_lvl2") then
		level = 2
	elseif	healht_pct < ability:GetSpecialValueFor("hp_mark_pct_lvl1") then
		level = 1
	end
	if level then
		return ability:GetSpecialValueFor("bonus_damage_lvl" .. level)
	end
end