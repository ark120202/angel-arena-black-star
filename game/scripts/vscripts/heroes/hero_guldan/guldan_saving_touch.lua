LinkLuaModifier("modifier_guldan_saving_touch", "heroes/hero_guldan/guldan_saving_touch.lua", LUA_MODIFIER_MOTION_NONE)

guldan_saving_touch = class ({
	GetInstricModifierName = function() return 'modifier_guldan_saving_touch' end
})

modifier_guldan_saving_touch = class({
	IsPurgable = function() return false end,
})

if IsServer() then
	function guldan_saving_touch:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		target:AddNewModifier(caster, self, 'modifier_guldan_saving_touch', {duration = self:GetSpecialValueFor("duration")})
		target:EmitSound("Arena.Hero_Guldan.SavingTouch.Cast")
	end

	function modifier_guldan_saving_touch:OnCreated()
		local caster = self:GetCaster()
		local parent = self:GetParent()
		pfx = ParticleManager:CreateParticle("particles/arena/units/heroes/hero_guldan/guldan_saving_touch.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
		ParticleManager:SetParticleControlEnt(pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), false)
	end

	function modifier_guldan_saving_touch:OnDestroy()
		ParticleManager:DestroyParticle(pfx, false)
	end
end

function modifier_guldan_saving_touch:CheckState()
	return	{[MODIFIER_STATE_MAGIC_IMMUNE] = true}
end

function modifier_guldan_saving_touch:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor('bonus_armor')
end

function modifier_guldan_saving_touch:DeclareFunctions()
	return { MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS }
end
