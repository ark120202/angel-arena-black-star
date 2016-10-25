ogre_magi_multicast_arena = class({})
LinkLuaModifier("modifier_multicast_lua", "heroes/hero_ogre_magi/modifier_multicast_lua.lua", LUA_MODIFIER_MOTION_NONE)

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

function ogre_magi_multicast_arena:GetIntrinsicModifierName()
	return "modifier_multicast_lua"
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