LinkLuaModifier("modifier_item_golden_arrow", "items/item_golden_arrow.lua", LUA_MODIFIER_MOTION_NONE)

item_golden_arrow = class({
	GetIntrinsicModifierName = function() return "modifier_item_golden_arrow" end
})

modifier_item_golden_arrow = class({
	IsHidden = function() return false end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
	IsPurgable = function() return false end,
	RemoveOnDeath = function() return false end,
})

function modifier_item_golden_arrow:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_item_golden_arrow:GetModifierPreAttack_BonusDamage()
	return self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_golden_arrow:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("bonus_armor")
end

if IsServer() then
	function item_golden_arrow:OnSpellStart()
		local caster = self:GetCaster()
		local modifier = caster:FindModifierByName("modifier_item_golden_arrow")

		if not modifier then
			caster:AddNewModifier(caster, self, "modifier_item_golden_arrow", {duration = duration})
		else
			modifier:IncrementStackCount()
		end

		local stacks = modifier:GetStackCount()
		local stats_debuff_per_stack = stacks * self:GetSpecialValueFor("stats_debuff_per_stack")
		local damage = stacks * self:GetSpecialValueFor("damage_per_stack")
		local cooldown = self:GetCooldown(self:GetLevel() ) + ( stacks * (self:GetSpecialValueFor("cooldown_per_stack")))
		local new_gold = stacks * self:GetSpecialValueFor("gold_per_stack")

		caster:EmitSound("Arena.Items.GoldenArrow.Activate")

		local particle = ParticleManager:CreateParticle("particles/arena/items_fx/coffee_bean_refresh.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)

		if caster:IsRealHero() then
			if caster:GetStrength() > 5 and caster:GetAgility() > 5 and caster:GetIntellect() > 5 then
				caster:ModifyStrength(stats_debuff_per_stack)
				caster:ModifyAgility(stats_debuff_per_stack)
				caster:ModifyIntellect(stats_debuff_per_stack)
				Gold:AddGoldWithMessage(caster, new_gold)
			elseif not caster:HasModifier("modifier_fountain_aura_arena") then
				ApplyDamage({
					victim = caster,
					attacker = caster,
					damage = damage,
					damage_type = DAMAGE_TYPE_PURE,
					ability = self
				})
				Gold:AddGoldWithMessage(caster, new_gold)
			end

			self:StartCooldown(cooldown)
		end
	end
end
