modifier_item_radiance_lua = class({})
function modifier_item_radiance_lua:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_item_radiance_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS
	}
end

function modifier_item_radiance_lua:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_radiance_lua:GetModifierBonusStats_Strength()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_radiance_lua:GetModifierBonusStats_Agility()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_radiance_lua:GetModifierBonusStats_Intellect()
	return self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_radiance_lua:GetModifierHealthBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_health")
end

function modifier_item_radiance_lua:GetModifierManaBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_mana")
end

function modifier_item_radiance_lua:IsPurgable()
	return false
end

function modifier_item_radiance_lua:IsHidden()
	return true
end

if IsServer() then
	function modifier_item_radiance_lua:OnDestroy()
		local ability = self:GetAbility()
		if IsValidEntity(ability) and ability.pfx then
			ParticleManager:DestroyParticle(ability.pfx, false)
			ability.pfx = nil
		end
	end
	function modifier_item_radiance_lua:OnCreated()
		local ability = self:GetAbility()
		ability.pfx = ParticleManager:CreateParticle(ability.particle_owner, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		self:StartIntervalThink(0.1)
	end

	function modifier_item_radiance_lua:OnIntervalThink()
		local target = self:GetParent()
		local ability = self:GetAbility()
		if not ability.disabled then
			for _,v in ipairs(FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, ability:GetSpecialValueFor("aura_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)) do
				if not v:IsBoss() then
					local modifier = v:FindModifierByNameAndCaster("modifier_item_radiance_lua_effect", target)
					if not modifier then
						v:AddNewModifier(target, ability, "modifier_item_radiance_lua_effect", {duration = 0.11})
					else
						modifier:SetDuration(0.11, false)
					end
				end
			end
		end
	end
end