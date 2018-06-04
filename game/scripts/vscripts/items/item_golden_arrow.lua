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
		caster:EmitSound("Arena.Items.GoldenArrow.Activate")
		ModifyStacksLua(self, caster,caster, "modifier_item_golden_arrow", 1)
		local stacks = caster:GetModifierStackCount("modifier_item_golden_arrow", self)
		local coof = stacks*self:GetSpecialValueFor("gold_per_stack")
		local base_gold = (self:GetSpecialValueFor("base_gold")+(caster:GetLevel()*30))
		local stats_debuff_per_stack = stacks*self:GetSpecialValueFor("stats_debuff_per_stack")
		local damage = (caster:GetModifierStackCount("modifier_item_golden_arrow", self)) * (self:GetSpecialValueFor("damage_per_stack"))
		local cooldown = self:GetCooldown(self:GetLevel() ) + ( stacks * (self:GetSpecialValueFor("cooldown_per_stack")))
		ParticleManager:SetParticleControlEnt(ParticleManager:CreateParticle("particles/arena/items_fx/coffee_bean_refresh.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster), 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		if caster:IsRealHero() then
			if caster:GetStrength() and caster:GetAgility() and caster:GetIntellect() > 5 then
				caster:ModifyStrength(stats_debuff_per_stack)
				caster:ModifyAgility(stats_debuff_per_stack)
				caster:ModifyIntellect(stats_debuff_per_stack)
				Gold:ModifyGold(caster, base_gold)
				Gold:AddGoldWithMessage(caster,coof)
			elseif not caster:HasModifier("modifier_fountain_aura_arena") then
				ApplyDamage({victim = caster, attacker = caster, damage = damage, damage_type = DAMAGE_TYPE_PURE, ability = self})
				Gold:ModifyGold(caster, base_gold)
				Gold:AddGoldWithMessage(caster,coof)
			end
			self:StartCooldown(cooldown)
		end
	end
end
