omniknight_guardian_angel_lua = class({})

LinkLuaModifier("modifier_omniknight_guardian_angel_lua", "heroes/hero_omniknight/modifiers/modifier_omniknight_guardian_angel_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_omniknight_guardian_angel_inverse_lua", "heroes/hero_omniknight/modifiers/modifier_omniknight_guardian_angel_inverse_lua", LUA_MODIFIER_MOTION_NONE)
function omniknight_guardian_angel_lua:OnSpellStart() if IsServer() then
	local targets = {}
	if self:GetCaster():HasModifier("modifier_omniknight_select_allies") or self:GetCaster():HasModifier("modifier_omniknight_select_enemies") then
		if self:GetCaster():HasModifier("modifier_omniknight_select_allies") then
			for _,v in ipairs(HeroList:GetAllHeroes()) do
				if v:IsAlive() and self:GetCaster():GetTeamNumber() == v:GetTeamNumber() then
					table.insert(targets, v)
				end
			end
		elseif self:GetCaster():HasModifier("modifier_omniknight_select_enemies") then
			for _,v in ipairs(HeroList:GetAllHeroes()) do
				if v:IsAlive() and self:GetCaster():GetTeamNumber() ~= v:GetTeamNumber() then
					table.insert(targets, v)
				end
			end
		end
	else
		targets = {self:GetCursorTarget()}
	end
	for _,target in ipairs(targets) do
		target:EmitSound("Hero_Omniknight.GuardianAngel.Cast")
		if target:GetTeam() == self:GetCaster():GetTeam() then
			target:AddNewModifier(self:GetCaster(), self, "modifier_omniknight_guardian_angel_lua", {duration = self:GetSpecialValueFor("duration")})
			ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_repel_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		elseif self:GetCaster():HasScepter() then
			target:AddNewModifier(self:GetCaster(), self, "modifier_omniknight_guardian_angel_inverse_lua", {duration = self:GetSpecialValueFor("duration")})
			ParticleManager:CreateParticle("particles/units/heroes/hero_omniknight/omniknight_repel_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
		end
	end
end end

function omniknight_guardian_angel_lua:GetBehavior()
	if self:GetCaster():HasModifier("modifier_omniknight_select_allies") or self:GetCaster():HasModifier("modifier_omniknight_select_enemies") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET
	else
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
	end
end

function omniknight_guardian_angel_lua:CastFilterResultTarget(hTarget)
	if not self:GetCaster():HasScepter() and self:GetCaster():GetTeamNumber() ~= hTarget:GetTeamNumber() then
		return UF_FAIL_CUSTOM
	end
 
	local nResult = UnitFilter(hTarget, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, self:GetCaster():GetTeamNumber())
	if nResult ~= UF_SUCCESS then
		return nResult
	end
	return UF_SUCCESS
end
  
function omniknight_guardian_angel_lua:GetCustomCastErrorTarget(hTarget)
	if not self:GetCaster():HasScepter() and self:GetCaster():GetTeamNumber() ~= hTarget:GetTeamNumber() then
		return "#dota_hud_error_cant_cast_on_enemy"
	end
	return ""
end

function omniknight_guardian_angel_lua:GetCastAnimation()
	return ACT_DOTA_CAST_ABILITY_2
end