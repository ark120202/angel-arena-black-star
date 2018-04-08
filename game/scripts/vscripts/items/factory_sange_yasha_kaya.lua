local sangeMaimModifier = {
  IsDebuff = function() return true end,
}

function sangeMaimModifier:GetEffectName()
  return "particles/items2_fx/sange_maim.vpcf"
end

function sangeMaimModifier:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function sangeMaimModifier:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
  }
end

function sangeMaimModifier:OnCreated()
  local isRanged = self:GetCaster():IsRangedAttacker()
  local ability = self:GetAbility()

  local movementSpeedSlowPctKey = isRanged and "maim_slow_movement_range_pct" or "maim_slow_movement_pct"
  self.movementSpeedSlowPct = ability:GetSpecialValueFor(movementSpeedSlowPctKey)
  local attackSpeedSlowKey = isRanged and "maim_slow_attack_range" or "maim_slow_attack"
  self.attackSpeedSlow = ability:GetSpecialValueFor(attackSpeedSlowKey)
end

function sangeMaimModifier:GetModifierMoveSpeedBonus_Percentage()
  return self.movementSpeedSlowPct
end

function sangeMaimModifier:GetModifierAttackSpeedBonus_Constant()
  return self.attackSpeedSlow
end

return function(parts, funcs)
  funcs = funcs or {}
  local sange_maim
  local storedSpecials = {}
  local modifier = {
    IsHidden = function() return true end,
    IsPurgable = function() return false end,
    DeclareFunctions = function() return funcs end,
    GetAttributes = function() return MODIFIER_ATTRIBUTE_MULTIPLE end,
  }

  function modifier:OnCreated()
    self:StoreAbilitySpecials(storedSpecials)
  end

  if parts.sange then
    sange_maim = sangeMaimModifier

    table.insert(funcs, MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE)
    table.insert(storedSpecials, "bonus_damage")
    function modifier:GetModifierPreAttack_BonusDamage()
      return self:GetSpecialValueFor("bonus_damage")
    end

    table.insert(funcs, MODIFIER_PROPERTY_STATS_STRENGTH_BONUS)
    table.insert(storedSpecials, "bonus_strength")
    function modifier:GetModifierBonusStats_Strength()
      return self:GetSpecialValueFor("bonus_strength")
    end

    if IsServer() then
      table.insert(funcs, MODIFIER_EVENT_ON_ATTACK_LANDED)
      table.insert(storedSpecials, "maim_chance_pct")
      table.insert(storedSpecials, "maim_duration")
      function modifier:OnAttackLanded(keys)
        local target = keys.target
        local attacker = keys.attacker

        if attacker == self:GetParent() and RollPercentage(self:GetSpecialValueFor("maim_chance_pct")) then
          target:EmitSound("DOTA_Item.Maim")
          target:AddNewModifier(
            attacker,
            self:GetAbility(),
            parts.sange,
            { duration = self:GetSpecialValueFor("maim_duration") }
          )
        end
      end
    end
  end

  if parts.yasha then
    table.insert(funcs, MODIFIER_PROPERTY_STATS_AGILITY_BONUS)
    table.insert(storedSpecials, "bonus_agility")
    function modifier:GetModifierBonusStats_Agility()
      return self:GetSpecialValueFor("bonus_agility")
    end

    table.insert(funcs, MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT)
    table.insert(storedSpecials, "bonus_attack_speed")
    function modifier:GetModifierAttackSpeedBonus_Constant()
      return self:GetSpecialValueFor("bonus_attack_speed")
    end

    table.insert(funcs, MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE)
    table.insert(storedSpecials, "bonus_movement_speed_pct")
    function modifier:GetModifierMoveSpeedBonus_Percentage()
      return self:GetSpecialValueFor("bonus_movement_speed_pct")
    end
  end

  if parts.kaya then
    table.insert(funcs, MODIFIER_PROPERTY_STATS_INTELLECT_BONUS)
    table.insert(storedSpecials, "bonus_intellect")
    function modifier:GetModifierBonusStats_Intellect()
      return self:GetSpecialValueFor("bonus_intellect")
    end

    table.insert(funcs, MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE)
    table.insert(storedSpecials, "spell_amp_pct")
    function modifier:GetModifierSpellAmplify_Percentage()
      return self:GetSpecialValueFor("spell_amp_pct")
    end

    table.insert(funcs, MODIFIER_PROPERTY_MANACOST_PERCENTAGE)
    table.insert(storedSpecials, "manacost_reduction_pct")
    function modifier:GetModifierPercentageManacost()
      return self:GetSpecialValueFor("manacost_reduction_pct")
    end
  end

  return modifier, sange_maim
end
