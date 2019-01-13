ogre_magi_multicast_arena = {
	GetIntrinsicModifierName = function() return "modifier_multicast_lua" end,
}

if IsServer() then
	function ogre_magi_multicast_arena:OnSpellStart()
		local caster = self:GetCaster()
		if not caster:HasScepter() then return end

		local target = self:GetCursorTarget()
		local duration = self:GetSpecialValueFor("duration_ally_scepter")
		target:EmitSound("Hero_OgreMagi.Fireblast.x3")
		target:AddNewModifier(caster, self, "modifier_multicast_lua", { duration = duration })
	end
end

function ogre_magi_multicast_arena:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function ogre_magi_multicast_arena:GetManaCost(...)
	return self:GetCaster():HasScepter() and self.BaseClass.GetManaCost(self, ...) or 0
end

function ogre_magi_multicast_arena:GetCastRange(...)
	return self:GetCaster():HasScepter() and self.BaseClass.GetCastRange(self, ...) or 0
end

function ogre_magi_multicast_arena:CastFilterResultTarget(target)
	local caster = self:GetCaster()
	if caster == target or target:FindAbilityByName("ogre_magi_multicast_arena") then
		return UF_FAIL_CUSTOM
	end

	return UnitFilter(target, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, caster:GetTeamNumber())
end


function ogre_magi_multicast_arena:GetCustomCastErrorTarget(target)
	if self:GetCaster() == target then
		return "#dota_hud_error_cant_cast_on_self"
	end
	if target:FindAbilityByName("ogre_magi_multicast_arena") then
		return "#dota_hud_error_cant_cast_on_other"
	end
	return ""
end


LinkLuaModifier("modifier_multicast_lua", "heroes/hero_ogre_magi/multicast.lua", LUA_MODIFIER_MOTION_NONE)
modifier_multicast_lua = {
	IsPurgable = function() return false end,
	GetEffectName = function() return "particles/arena/units/heroes/hero_ogre_magi/multicast_aghanims_buff.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
	DeclareFunctions = function() return { MODIFIER_EVENT_ON_ABILITY_EXECUTED } end,
}

if IsServer() then
	function modifier_multicast_lua:OnAbilityExecuted(keys)
		local parent = self:GetParent()
		if parent ~= keys.unit then return end
		local castedAbility = keys.ability

		local caster = self:GetParent()
		local target = keys.target or caster:GetCursorPosition()
		local ability = self:GetAbility()

		local ogreAbilities = {
			ogre_magi_bloodlust = true,
			ogre_magi_fireblast = true,
			ogre_magi_ignite = true,
			ogre_magi_unrefined_fireblast = true
		}
		if ogreAbilities[castedAbility:GetAbilityName()] then
			local mc = caster:AddAbility("ogre_magi_multicast")
			mc:SetHidden(true)
			mc:SetLevel(ability:GetLevel())
			Timers:NextTick(function() caster:RemoveAbility("ogre_magi_multicast") end)
			return
		end

		local multiplier = IsUltimateAbility(castedAbility) and 0.5 or 1
		local multicast
		if RollPercentage(ability:GetSpecialValueFor("multicast_4_times") * multiplier) then
			multicast = 4
		elseif RollPercentage(ability:GetSpecialValueFor("multicast_3_times") * multiplier) then
			multicast = 3
		elseif RollPercentage(ability:GetSpecialValueFor("multicast_2_times") * multiplier) then
			multicast = 2
		end

		if multicast then
			PreformMulticast(caster, castedAbility, multicast, ability:GetSpecialValueFor("multicast_delay"), target)
		end
	end
end
