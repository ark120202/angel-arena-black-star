LinkLuaModifier("modifier_saber_mana_burst", "heroes/hero_saber/mana_burst.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_saber_mana_burst_active", "heroes/hero_saber/mana_burst.lua", LUA_MODIFIER_MOTION_NONE)

saber_mana_burst = class({
	GetIntrinsicModifierName = function() return "modifier_saber_mana_burst" end,
})

function saber_mana_burst:GetManaCost(iLevel)
	return self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("mana_wasted_pct") * 0.01
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


modifier_saber_mana_burst = class({
	IsHidden         = function() return true end,
	DeclareFunctions = function() return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS} end,
	IsPurgable       = function() return false end
})

function modifier_saber_mana_burst:CheckState()
	return self:GetStackCount() == 1 and {
		[MODIFIER_STATE_DISARMED] = true
	}
end

function modifier_saber_mana_burst:GetModifierPhysicalArmorBonus()
	return self:GetStackCount() == 1 and self:GetAbility():GetSpecialValueFor("weakness_disarmor")
end

if IsServer() then
	function modifier_saber_mana_burst:OnCreated()
		self:StartIntervalThink(0.1)
	end

	function modifier_saber_mana_burst:OnIntervalThink()
		local parent = self:GetParent()
		if parent:IsAlive() then
			local ability = self:GetAbility()
			local manacost = ability:GetManaCost()
			local isWeak = (parent:GetMana() / parent:GetMaxMana()) * 100 < ability:GetSpecialValueFor("weakness_mana_pct")
			self:SetStackCount(isWeak and 1 or 0)
			if isWeak and not self.pfx then
				self.pfx = ParticleManager:CreateParticle("particles/generic_gameplay/generic_disarm.vpcf", PATTACH_OVERHEAD_FOLLOW, parent)
			elseif not isWeak and self.pfx then
				ParticleManager:DestroyParticle(self.pfx, false)
				self.pfx = nil
			end
			if ability:GetAutoCastState() and manacost * 2 < parent:GetMana() then
				parent:CastAbilityNoTarget(ability, parent:GetPlayerID())
			end
		end
	end
end

modifier_saber_mana_burst_active = class({
	IsPurgable    = function() return false end,
	GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
})
function modifier_saber_mana_burst_active:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_saber_mana_burst_active:GetModifierPreAttack_BonusDamage()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("damage_per_mana")
end
function modifier_saber_mana_burst_active:GetModifierPhysicalArmorBonus()
	return self:GetStackCount() * self:GetAbility():GetSpecialValueFor("armor_per_mana")
end
if IsServer() then
	function modifier_saber_mana_burst_active:OnCreated()
		local parent = self:GetParent()
		self.pfx = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_saber/mana_burst_stack.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(self.pfx, 0, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
	end
	function modifier_saber_mana_burst_active:OnDestroy()
		ParticleManager:DestroyParticle(self.pfx, false)
	end
end
