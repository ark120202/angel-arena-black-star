LinkLuaModifier("modifier_item_unstable_quasar_passive", "items/item_unstable_quasar.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_unstable_quasar_slow", "items/item_unstable_quasar.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_unstable_quasar_aura", "items/item_unstable_quasar.lua", LUA_MODIFIER_MOTION_NONE)

item_unstable_quasar = {
    GetIntrinsicModifierName = function() return "modifier_item_unstable_quasar_passive" end,
}

modifier_item_unstable_quasar_passive = class({
    DeclareFunctions = function() return {
        MODIFIER_EVENT_ON_ABILITY_EXECUTED,
        MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    } end,
    IsHidden   = function() return true end,
    IsPurgable = function() return false end,
    RemoveOnDeath = function() return false end,
})

modifier_item_unstable_quasar_slow = class({
    IsHidden   = function() return false end,
    IsPurgable = function() return true end,
    IsDebuff = function() return true end,
    GetEffectName = function() return "particles/items_fx/diffusal_slow.vpcf" end,
    DeclareFunctions = function() return { 
        MODIFIER_PROPERTY_MOVESPEED_MAX,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
     } end,
})

function item_unstable_quasar:GetManaCost(iLevel)
    local caster = self:GetCaster()
    if caster then 
        return self:GetSpecialValueFor("manacost") + caster:GetMaxMana() * self:GetSpecialValueFor("manacost_pct") * 0.01
    end
end

if IsServer() then
    function modifier_item_unstable_quasar_passive:OnAbilityExecuted(keys)
        local caster = self:GetParent()
        local ability = self:GetAbility()
        local usedAbility = keys.ability
        local team = caster:GetTeam()
        local pos = caster:GetAbsOrigin()
        local value = function(v)
            return ability:GetSpecialValueFor(v)
        end
        local manacost = ability:GetSpecialValueFor("manacost") + caster:GetMaxMana() * ability:GetSpecialValueFor("manacost_pct") * 0.01
        local radius = ability:GetSpecialValueFor("damage_radius")

        if usedAbility:GetCooldown(usedAbility:GetLevel()) >= ability:GetSpecialValueFor("min_ability_cooldown") and caster == keys.unit and caster:GetMana() >= manacost and usedAbility:GetManaCost(usedAbility:GetLevel() or nil) ~= 0 or nil then
            caster:SetMana(caster:GetMana() - manacost)
            for _,v in ipairs(FindUnitsInRadius(team, pos, nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)) do
                local enemyPos = v:GetAbsOrigin()
                local damage = v:GetHealth() * ability:GetSpecialValueFor("damage_pct") * 0.01 + ability:GetSpecialValueFor("base_damage")

                if caster:GetPrimaryAttribute() ~= 2 then
                    damage = damage * ability:GetSpecialValueFor("discrease_damage_pct") * 0.01
                end

                ApplyDamage({
                    attacker = caster,
                    victim = v,
                    damage = damage,
                    damage_type = ability:GetAbilityDamageType(),
                    damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
                    ability = self:GetAbility()
                })
                
                local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_zuus/zuus_arc_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
                ParticleManager:SetParticleControl(particle, 1, v:GetAbsOrigin())

                v:AddNewModifier(caster, ability, "modifier_item_unstable_quasar_slow", {duration = value("slow_duration")})

                local abs = GetGroundPosition(v:GetAbsOrigin() + (pos - v:GetAbsOrigin()):Normalized() * value("offset_distance"), caster)
                v:SetAbsOrigin(abs)

                --caster:EmitSound("Hero_Pugna.NetherWard")
            end
        end
    end
end

function modifier_item_unstable_quasar_slow:GetModifierMoveSpeed_Limit()
	return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_item_unstable_quasar_slow:GetModifierMoveSpeed_Max()
	return self:GetAbility():GetSpecialValueFor("speed")
end

function modifier_item_unstable_quasar_slow:GetModifierMoveSpeed_Absolute()
	return self:GetAbility():GetSpecialValueFor("speed")
end


function modifier_item_unstable_quasar_passive:GetBonusDayVision()
    return self:GetAbility():GetSpecialValueFor("bonus_day_vision")
end

function modifier_item_unstable_quasar_passive:GetBonusNightVision()
    return self:GetAbility():GetSpecialValueFor("bonus_night_vision")
end

function modifier_item_unstable_quasar_passive:GetModifierBonusStats_Intellect()
    return self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_unstable_quasar_passive:GetModifierSpellAmplify_Percentage()
    return self:GetAbility():GetSpecialValueFor("spell_amp_pct")
end

function modifier_item_unstable_quasar_passive:GetModifierTotalDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("increase_all_damage_pct")
end

function modifier_item_unstable_quasar_passive:GetModifierAura()
	return "modifier_item_unstable_quasar_aura"
end

function modifier_item_unstable_quasar_passive:IsAura()
	return true
end

function modifier_item_unstable_quasar_passive:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_item_unstable_quasar_passive:GetAuraSearchTeam()
	return self:GetAbility():GetAbilityTargetTeam()
end

function modifier_item_unstable_quasar_passive:GetAuraSearchType()
	return self:GetAbility():GetAbilityTargetType()
end

modifier_item_unstable_quasar_aura = class({
    DeclareFunctions = function() return {MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS} end,      
})

function modifier_item_unstable_quasar_aura:GetModifierMagicalResistanceBonus()
    return -self:GetAbility():GetSpecialValueFor("aura_descrease_resistange_pct")
end

function modifier_item_unstable_quasar_passive:CheckState()
    return {
        [MODIFIER_STATE_INVISIBLE] = false,
    }
end

