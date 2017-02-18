saber_mana_burst = class({})
LinkLuaModifier("modifier_saber_mana_burst", "heroes/hero_saber/modifier_saber_mana_burst.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_saber_mana_burst_active", "heroes/hero_saber/modifier_saber_mana_burst.lua", LUA_MODIFIER_MOTION_NONE)
function saber_mana_burst:GetManaCost(iLevel)
	return self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("mana_wasted_pct") * 0.01
end
function saber_mana_burst:GetIntrinsicModifierName()
	return "modifier_saber_mana_burst"
end
if IsServer() then
	function saber_mana_burst:OnSpellStart()
		local caster = self:GetCaster()
		caster:EmitSound("Arena.Hero_Saber.ManaBurst")
		caster:AddNewModifier(caster, self, "modifier_saber_mana_burst_active", {duration = self:GetSpecialValueFor("duration")}):SetStackCount(self:GetManaCost())
		ParticleManager:CreateParticle("particles/econ/items/outworld_devourer/od_shards_exile/od_shards_exile_prison_end_mana_flash.vpcf", PATTACH_ABSORIGIN, caster)
		local pct = caster:GetHealthPercent()
		if pct <= self:GetSpecialValueFor("purge_health_pct") then
			local purgeStuns = pct <= self:GetSpecialValueFor("purge_stun_health_pct")
			caster:Purge(false, true, false, purgeStuns, false)
		end
	end
end