LinkLuaModifier("modifier_multicast_lua", "heroes/hero_ogre_magi/multicast.lua", LUA_MODIFIER_MOTION_NONE)
ogre_magi_multicast_arena = class({
	GetIntrinsicModifierName = function() return "modifier_multicast_lua" end,
})

function ogre_magi_multicast_arena:GetManaCost(iLevel)
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("scepter_manacost")
	else
		return 0
	end
end

function ogre_magi_multicast_arena:OnSpellStart()
	if IsServer() and self:GetCaster():HasScepter() then
		self:GetCursorTarget():EmitSound("Hero_OgreMagi.Fireblast.x3")
		self:GetCursorTarget():AddNewModifier(self:GetCaster(), self, "modifier_multicast_lua", {duration = self:GetSpecialValueFor("duration_ally")})
	end
end

function ogre_magi_multicast_arena:GetBehavior()
	if self:GetCaster():HasScepter() then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_PASSIVE
	end
end

function ogre_magi_multicast_arena:GetCastRange()
	if self:GetCaster():HasScepter() then
		return self:GetSpecialValueFor("multicast_cast_range")
	else
		return 0
	end
end

function ogre_magi_multicast_arena:CastFilterResultTarget( hTarget )
	if hTarget and self:GetCaster() == hTarget or (hTarget.FindAbilityByName and hTarget:FindAbilityByName("ogre_magi_multicast_arena")) then
		return UF_FAIL_CUSTOM
	end

	local nResult = UnitFilter( hTarget, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber() )
	if nResult ~= UF_SUCCESS then
		return nResult
	end

	return UF_SUCCESS
end


function ogre_magi_multicast_arena:GetCustomCastErrorTarget( hTarget )
	if self:GetCaster() == hTarget then
		return "#dota_hud_error_cant_cast_on_self"
	end

	if hTarget:FindAbilityByName("ogre_magi_multicast_arena") then
		return "#dota_hud_error_cant_cast_on_other"
	end

	return ""
end


modifier_multicast_lua = class({
	DeclareFunctions    = function() return {MODIFIER_EVENT_ON_ABILITY_EXECUTED} end,
	GetEffectName       = function() return "particles/arena/units/heroes/hero_ogre_magi/multicast_aghanims_buff.vpcf" end,
	GetEffectAttachType = function() return PATTACH_ABSORIGIN_FOLLOW end,
	IsPurgable          = function() return false end,
})

function modifier_multicast_lua:OnAbilityExecuted(keys)
	if IsServer() and self:GetParent() == keys.unit then
		local ability_cast = keys.ability
		local caster = self:GetParent()
		local target = keys.target or caster:GetCursorPosition()
		local ability = self:GetAbility()
		local ogre_abilities = {
			"ogre_magi_bloodlust",
			"ogre_magi_fireblast",
			"ogre_magi_ignite",
			"ogre_magi_unrefined_fireblast"
		}
		if ability_cast and not ability_cast:IsItem() and not ability_cast:IsToggle() then
			if table.includes(ogre_abilities, ability_cast:GetName()) then
				local mc = caster:AddAbility("ogre_magi_multicast")
				mc:SetHidden(true)
				mc:SetLevel(ability:GetLevel())
				Timers:CreateTimer(0.01, function()
					caster:RemoveAbility("ogre_magi_multicast")
				end)
			else
				local multicast
				local pct_4 = ability:GetSpecialValueFor("multicast_4_times")
				local pct_3 = ability:GetSpecialValueFor("multicast_3_times")
				local pct_2 = ability:GetSpecialValueFor("multicast_2_times")
				if IsUltimateAbility(ability_cast) then
					pct_4 = pct_4 / 2
					pct_3 = pct_3 / 2
					pct_2 = pct_2 / 2
				end
				if RollPercentage(pct_4) then
					multicast = 4
				elseif RollPercentage(pct_3) then
					multicast = 3
				elseif RollPercentage(pct_2) then
					multicast = 2
				end
				if ability_cast ~= nil and multicast then
					PreformMulticast(caster, ability_cast, multicast, ability:GetSpecialValueFor( "multicast_delay"), target)
				end
			end
		end
	end
end
