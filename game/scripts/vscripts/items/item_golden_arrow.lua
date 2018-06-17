LinkLuaModifier("modifier_item_golden_arrow", "items/item_golden_arrow.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_golden_arrow_counter", "items/item_golden_arrow.lua", LUA_MODIFIER_MOTION_NONE)

item_golden_arrow = class({
	GetIntrinsicModifierName = function() return "modifier_item_golden_arrow" end
})

function item_golden_arrow:GetAbilityTextureName()
	return self:GetNetworkableEntityInfo("notEnoughAttributes") == 1 and "item_arena/golden_arrow_damage" or "item_arena/golden_arrow_attributes"
end

if IsServer() then
	function item_golden_arrow:HasEnoughAttributes()
		local caster = self:GetCaster()
		local stacks = caster:GetModifierStackCount("modifier_item_golden_arrow_counter", caster)
		local requiredAttributes = -self:GetSpecialValueFor("attributes_per_stack") * stacks
		return (
			caster:GetStrength() > requiredAttributes and
			caster:GetAgility() > requiredAttributes and
			caster:GetIntellect() > requiredAttributes
		)
	end

	function item_golden_arrow:CastFilterResult()
		local caster = self:GetCaster()
		return self:HasEnoughAttributes() or not caster:HasModifier("modifier_fountain_aura_arena") and UF_SUCCESS or UF_FAIL_CUSTOM
	end

	function item_golden_arrow:GetCustomCastError()
		local caster = self:GetCaster()
		return caster:HasModifier("modifier_fountain_aura_arena") and "#arena_hud_error_cant_cast_on_fountain" or ""
	end

	function item_golden_arrow:OnSpellStart()
		local caster = self:GetCaster()
		local modifier = caster:FindModifierByName("modifier_item_golden_arrow_counter")
		if not modifier then modifier = caster:AddNewModifier(caster, self, "modifier_item_golden_arrow_counter", nil) end
		modifier:IncrementStackCount()
		local stacks = modifier:GetStackCount()

		local particle = ParticleManager:CreateParticle("particles/arena/items_fx/golden_arrow.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		caster:EmitSound("Arena.Items.GoldenArrow.Activate")

		if not caster:IsRealHero() then return end
		if self:HasEnoughAttributes() then
			local attributes = self:GetSpecialValueFor("attributes_per_stack") * stacks
			caster:ModifyStrength(attributes)
			caster:ModifyAgility(attributes)
			caster:ModifyIntellect(attributes)
		else
			local damage = self:GetSpecialValueFor("damage_per_stack") * stacks
			ApplyDamage({
				victim = caster,
				attacker = caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_PURE,
				ability = self
			})
		end

		local gold = self:GetSpecialValueFor("gold_per_stack") * stacks
		Gold:AddGoldWithMessage(caster, gold)

		local cooldown = self:GetSpecialValueFor("cooldown_base") + self:GetSpecialValueFor("cooldown_per_stack") * stacks
		self:StartCooldown(cooldown)
	end
end

modifier_item_golden_arrow = class({
	IsHidden = function() return true end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable = function() return false end,
})

if IsServer() then
	function modifier_item_golden_arrow:OnCreated()
		self:StartIntervalThink(0.1)
		self:OnIntervalThink()
	end

	function modifier_item_golden_arrow:OnIntervalThink()
		local ability = self:GetAbility()
		ability:SetNetworkableEntityInfo("notEnoughAttributes", not ability:HasEnoughAttributes())
	end
end

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
	GetTexture = function() return "item_arena/golden_arrow_attributes" end,
	IsHidden = function() return false end,
	IsPurgable = function() return false end,
	RemoveOnDeath = function() return false end,
})
