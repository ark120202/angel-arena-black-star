LinkLuaModifier("modifier_soul_eater_transform_to_scythe", "heroes/hero_soul_eater/transform_to_scythe.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_soul_eater_transform_to_scythe_projectile", "heroes/hero_soul_eater/transform_to_scythe.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_soul_eater_transform_to_scythe_buff", "heroes/hero_soul_eater/transform_to_scythe.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_soul_eater_transform_to_scythe_debuff", "heroes/hero_soul_eater/transform_to_scythe.lua", LUA_MODIFIER_MOTION_NONE)

soul_eater_transform_to_scythe = class({})

if IsServer() then
	function soul_eater_transform_to_scythe:CastFilterResult()
		local soul = self:GetCaster()
		local maka = soul:GetLinkedHeroEntities()[1]
		local position = soul:GetAbsOrigin()
		return maka and (maka:GetAbsOrigin() - position):Length2D() <= self:GetCastRange(position, maka) and UF_SUCCESS or UF_FAIL_INVALID_LOCATION
	end

	function soul_eater_transform_to_scythe:GetCustomCastError()
		local soul = self:GetCaster()
		local maka = soul:GetLinkedHeroEntities()[1]
		local position = soul:GetAbsOrigin()
		return maka and (maka:GetAbsOrigin() - position):Length2D() <= self:GetCastRange(position, maka) or ""
	end

	function soul_eater_transform_to_scythe:OnSpellStart()
		local soul = self:GetCaster()
		local maka = soul:GetLinkedHeroEntities()[1]
		local position = soul:GetAbsOrigin()
		if maka and (maka:GetAbsOrigin() - position):Length2D() <= self:GetCastRange(position, maka) then
			self.maka = maka
			local team = soul:GetTeamNumber()

			soul:AddNewModifier(soul, self, "modifier_soul_eater_transform_to_scythe_projectile", nil)
			ProjectileManager:CreateTrackingProjectile({
				Target = maka,
				Source = soul,
				Ability = self,
				EffectName = "particles/units/heroes/hero_arc_warden/arc_warden_wraith_prj.vpcf",
				iMoveSpeed = self:GetAbilitySpecial("projectile_speed"),
				bProvidesVision = true,
				iVisionRadius = self:GetAbilitySpecial("vision_radius"),
				iVisionTeamNumber = team,
				iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
			})
		end
	end

	function soul_eater_transform_to_scythe:OnProjectileHit(hTarget, vLocation)
		local soul = self:GetCaster()
		local maka = soul:GetLinkedHeroEntities()[1]
		soul:RemoveModifierByName("modifier_soul_eater_transform_to_scythe_projectile")
		soul:AddNewModifier(soul, self, "modifier_soul_eater_transform_to_scythe", nil)
		maka:AddNewModifier(soul, self, "modifier_soul_eater_transform_to_scythe_buff", nil)
	end
end

modifier_soul_eater_transform_to_scythe_projectile = class({
	IsPurgable = function() return false end,
	IsHidden   = function() return true end,
})

function modifier_soul_eater_transform_to_scythe_projectile:CheckState()
	return {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
	}
end

if IsServer() then
	function modifier_soul_eater_transform_to_scythe_projectile:OnCreated()
		self:GetParent():AddNoDraw()
	end

	function modifier_soul_eater_transform_to_scythe_projectile:OnDestroy()
		self:GetParent():RemoveNoDraw()
	end
end

modifier_soul_eater_transform_to_scythe = class({
	IsPurgable = function() return false end,
	IsHidden   = function() return true end,
})

function modifier_soul_eater_transform_to_scythe:CheckState()
	return {
		--[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MUTED] = true,
	}
end

if IsServer() then
	function modifier_soul_eater_transform_to_scythe:OnCreated()
		local soul = self:GetParent()
		local maka = soul:GetLinkedHeroEntities()[1]
		local scythe = maka:GetWearableInSlot("weapon")
		if scythe then
			local scythe_ent = scythe.entity
			if IsValidEntity(scythe_ent) then
				scythe_ent:SetVisible(true)
			end
		end

		soul:AddNoDraw()
		self:StartIntervalThink(1/30)
		soul:SwapAbilities("soul_eater_transform_to_scythe", "soul_eater_transform_to_human", false, true)
	end

	function modifier_soul_eater_transform_to_scythe:OnIntervalThink()
		local soul = self:GetParent()
		local maka = soul:GetLinkedHeroEntities()[1]
		soul:SetAbsOrigin(maka:GetAbsOrigin())
		if not maka:IsAlive() then
			self:Destroy()
		end
	end
	function modifier_soul_eater_transform_to_scythe:OnDestroy()
		local soul = self:GetParent()
		soul:RemoveNoDraw()
		local maka = soul:GetLinkedHeroEntities()[1]
		local scythe = maka:GetWearableInSlot("weapon")
		if scythe then
			local scythe_ent = scythe.entity
			if IsValidEntity(scythe_ent) then
				scythe_ent:SetVisible(false)
			end
		end
		soul:SwapAbilities("soul_eater_transform_to_scythe", "soul_eater_transform_to_human", true, false)
	end
end

modifier_soul_eater_transform_to_scythe_buff = class({
	IsPurgable = function() return false end,
	IsHidden   = function() return true end,
})

modifier_soul_eater_transform_to_scythe_debuff = class({
	IsPurgable = function() return false end,
	IsHidden   = function() return false end,
})

function modifier_soul_eater_transform_to_scythe_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
end

function modifier_soul_eater_transform_to_scythe:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end

if IsServer() then
	function modifier_soul_eater_transform_to_scythe:OnAttackLanded(keys)
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local duration = ability:GetSpecialValueFor("debuff_duration")
		if keys.attacker == parent then 
			keys.target:AddNewModifier(parent, ability, "modifier_soul_eater_transform_to_scythe_debuff", {duration = duration})
		end
	end

	function modifier_soul_eater_transform_to_scythe_buff:OnCreated()
		self:StartIntervalThink(0.1)
		self:OnIntervalThink()
	end

	function modifier_soul_eater_transform_to_scythe_buff:OnIntervalThink()
		local caster = self:GetCaster()
		local targer = caster:GetLinkedHeroEntities()[1]
		self:SetStackCount(caster:GetAverageTrueAttackDamage(targer) * self:GetAbility():GetSpecialValueFor("bonus_damage_pct") * 0.01)
	end
end

function modifier_soul_eater_transform_to_scythe_buff:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount()
end

function modifier_soul_eater_transform_to_scythe:GetModifierBaseAttackTimeConstant()
	return self:GetAbility():GetSpecialValueFor("base_attack_time")
end

function modifier_soul_eater_transform_to_scythe:GetModifierTotalDamageOutgoing_Percentage()
	return -self:GetAbility():GetSpecialValueFor("decrease_damage_pct")
end

function modifier_soul_eater_transform_to_scythe:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_attack_range")
end