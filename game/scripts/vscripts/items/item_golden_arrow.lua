LinkLuaModifier("modifier_item_golden_arrow", "items/item_golden_arrow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_golden_arrow_counter", "items/item_golden_arrow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_golden_arrow_target", "items/item_golden_arrow.lua", LUA_MODIFIER_MOTION_NONE)

item_golden_arrow = class({
	GetIntrinsicModifierName = function() return "modifier_item_golden_arrow" end
})

function item_golden_arrow:GetAbilityTextureName()
	return self:GetNetworkableEntityInfo("texture") or "item_arena/golden_arrow"
end


modifier_item_golden_arrow_target = class({
	IsPurgable = function() return true end,
	IsHidden = function() return false end,
})

if IsServer() then
	function item_golden_arrow:CastFilterResultTarget()
		return self:GetCaster():GetLevel() >= self:GetSpecialValueFor("max_caster_level") and UF_FAIL_CUSTOM or UF_SUCCESS
	end

	function item_golden_arrow:GetCustomCastErrorTarget()
		return self:GetCaster():GetLevel() >= self:GetSpecialValueFor("max_caster_level") and "#arena_hud_too_big_level" or ""
	end

	function item_golden_arrow:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		target:AddNewModifier(caster, self, "modifier_item_golden_arrow_target", {duration = self:GetSpecialValueFor("duration")})
	end

	function modifier_item_golden_arrow_target:OnCreated()
		self:StartIntervalThink(0.6)
	end

	function modifier_item_golden_arrow_target:OnIntervalThink()
		local caster = self:GetCaster()
		local particle = ParticleManager:CreateParticle("particles/arena/items_fx/golden_arrow_target_b.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
		ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
	end

	function modifier_item_golden_arrow_target:OnDestroy()
		local parent = self:GetParent()
		local caster = self:GetCaster()
		local ability = self:GetAbility()
		local modifier = caster:FindModifierByName("modifier_item_golden_arrow_counter")
		local max_stacks = ability:GetSpecialValueFor("max_stacks")
		local gold = ability:GetSpecialValueFor("gold_per_stack") * max_stacks
		local exp = ability:GetSpecialValueFor("xp_per_stack") * max_stacks
		if caster:GetLevel() >= ability:GetSpecialValueFor("level_to_divine") then
			gold = gold / 2
			exp = exp/2
		end

		if not parent:IsAlive() then
			if not modifier then modifier = caster:AddNewModifier(caster, ability, "modifier_item_golden_arrow_counter", nil) end
			modifier:IncrementStackCount()
		else
			Gold:AddGoldWithMessage(parent, ability:GetSpecialValueFor("target_gold"))
		end

		if modifier and modifier:GetStackCount() > (max_stacks / 2) - 1 then
			ability:SetNetworkableEntityInfo("texture", "item_arena/golden_arrow_streak")
		else
			ability:SetNetworkableEntityInfo("texture", "item_arena/golden_arrow")
		end

		if modifier and modifier:GetStackCount() == max_stacks then
			caster:RemoveModifierByName("modifier_item_golden_arrow_counter")
			Gold:AddGoldWithMessage(caster,gold)
			caster:AddExperience(exp, false, false)
			caster:EmitSound("Arena.Items.GoldenArrow.Activate")
			local particle = ParticleManager:CreateParticle("particles/arena/items_fx/golden_arrow.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControlEnt(particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
		end
	end
end


modifier_item_golden_arrow = class({
	IsHidden = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable = function() return false end,
})

function modifier_item_golden_arrow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}
end

function modifier_item_golden_arrow:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_golden_arrow:GetModifierMoveSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_speed")
end

modifier_item_golden_arrow_counter = class({
	GetTexture = function() return "item_arena/golden_arrow" end,
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
})
