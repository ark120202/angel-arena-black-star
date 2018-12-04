LinkLuaModifier("modifier_item_tree_banana_thinker", "items/item_tree_banana", LUA_MODIFIER_MOTION_NONE)

item_tree_banana = class({})

if IsServer() then
	function item_tree_banana:OnSpellStart()
		local caster = self:GetCaster()
		local banana = CreateUnitByName("npc_dummy_unit", caster:GetAbsOrigin(), false, caster, caster, caster:GetTeamNumber())
		banana:SetOriginalModel("models/props_gameplay/banana_prop_open.vmdl")
		banana:SetModel("models/props_gameplay/banana_prop_open.vmdl")
		banana:AddNewModifier(caster, self, "modifier_item_tree_banana_thinker", nil)
		caster:AddNewModifier(caster, self, "modifier_phased", {duration = 1/30})

		if caster:IsHero() then
			caster:ModifyIntellect(self:GetSpecialValueFor("intellect"))
		end

		self:SpendCharge()
	end
end


modifier_item_tree_banana_thinker = class({
	IsPurgable           = function() return false end,
	IsHidden             = function() return false end,
	GetOverrideAnimation = function() return ACT_DOTA_IDLE end,
})

function modifier_item_tree_banana_thinker:DeclareFunctions()
	return {MODIFIER_PROPERTY_OVERRIDE_ANIMATION}
end

if IsServer() then
	function modifier_item_tree_banana_thinker:OnCreated(keys)
		self:StoreAbilitySpecials({"slide_distance", "slide_duration", "radius"})
		self:StartIntervalThink(0.1)
	end

	function modifier_item_tree_banana_thinker:OnIntervalThink()
		local parent = self:GetParent()
		for _,v in ipairs(FindUnitsInRadius(parent:GetTeam(), parent:GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)) do
			self:SlideUnit(v)
			break
		end
	end

	function modifier_item_tree_banana_thinker:SlideUnit(unit)
		local parent = self:GetParent()
		local center = unit:GetAbsOrigin() + -unit:GetForwardVector()
		local duration = self:GetSpecialValueFor("slide_duration")
		unit:RemoveModifierByName("modifier_knockback")
		unit:AddNewModifier(self:GetCaster(), self, "modifier_knockback", {
			knockback_duration = duration,
			knockback_distance = self:GetSpecialValueFor("slide_distance"),
			knockback_height = 0,
			should_stun = 1,
			duration = duration,
			center_x = center.x,
			center_y = center.y,
			center_z = center.z
		})

		UTIL_Remove(parent)
	end
end
