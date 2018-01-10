LinkLuaModifier("modifier_soul_eater_transform_to_scythe_damage", "heroes/hero_maka/scythe_form.lua", LUA_MODIFIER_MOTION_NONE)

modifier_soul_eater_transform_to_scythe_damage = class({
    IsBuff = function() return true end, 
    IsPurgable = function() return false end,
    IsHidden = function() return true end,
})

maka_scythe_form = class({})

if IsServer() then 
    function maka_scythe_form:OnSpellStart()
        local target = self:GetCursorPosition()
        local caster = self:GetCaster()
        local position = caster:GetAbsOrigin()
        ProjectileManager:CreateLinearProjectile({
            Source = caster,    
            Ability = self,
            vSpawnOrigin = position,
            bHasFrontalCone = true,
            fStartRadius = self:GetAbilitySpecial("aoe_radius"),
            fEndRadius = self:GetAbilitySpecial("aoe_radius"),
            fDistance = self:GetAbilitySpecial("range"),
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
		    iUnitTargetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO,
			iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
            EffectName = "particles/arena/units/heroes/hero_maka/scythe_form.vpcf",
            vVelocity = (target - caster:GetAbsOrigin()):Normalized() * self:GetAbilitySpecial("projectile_speed"),
            bDeleteOnHit = true,
            fExpireTime = GameRules:GetGameTime() + self:GetAbilitySpecial("range") / self:GetAbilitySpecial("projectile_speed"),
        })
    end

    function maka_scythe_form:OnProjectileHit(hTarget)
        local maka = self:GetCaster()
        local soul = maka:GetLinkedHeroEntities()[1]
        local makaDamage = maka:GetAverageTrueAttackDamage(hTarget) 
        local soulDamage = 0

        if maka:HasModifier("modifier_maka_soul_resonance") then
            soulDamage = soul:GetAverageTrueAttackDamage(hTarget) 
        else
            soulDamage = 0
        end
        local damage = (makaDamage + soulDamage) * self:GetSpecialValueFor("attack_to_damage_pct") * 0.01 + self:GetSpecialValueFor("base_damage")

        if hTarget then
            if self:GetLevel() < self:GetSpecialValueFor("lvl_for_orbs") then
                ApplyDamage({
                    attacker = maka,
                    victim = hTarget,
                    damage = damage,
                    damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
                    damage_type = self:GetAbilityDamageType(),
                    ability = self
                })
            else
                maka:AddNewModifier(casrer, self, "modifier_soul_eater_transform_to_scythe_damage", {})
                maka:PerformAttack(hTarget, true, true, true, true, true, false, true)
                maka:RemoveModifierByName("modifier_soul_eater_transform_to_scythe_damage")           
            end
        end
    end

    function modifier_soul_eater_transform_to_scythe_damage:OnCreated()
		self:StartIntervalThink(0.01)
		self:OnIntervalThink()
	end

	function modifier_soul_eater_transform_to_scythe_damage:OnIntervalThink()
		local maka = self:GetParent()
        local soul = maka:GetLinkedHeroEntities()[1]
        local makaDamage = maka:GetAverageTrueAttackDamage(maka)
        self:SetStackCount(-(makaDamage - makaDamage * self:GetAbility():GetSpecialValueFor("attack_to_damage_pct") * 0.01))

        if maka:HasModifier("modifier_maka_soul_resonance") then
            self:SetStackCount(self:GetStackCount() + soul:GetAverageTrueAttackDamage(maka) * self:GetAbility():GetSpecialValueFor("attack_to_damage_pct") * 0.01)
        end
	end
end

function modifier_soul_eater_transform_to_scythe_damage:DeclareFunctions()
  return { MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE }
end

function modifier_soul_eater_transform_to_scythe_damage:GetModifierPreAttack_BonusDamage()
  	return self:GetStackCount() + self:GetAbility():GetSpecialValueFor("base_damage")
end
