modifier_generic = class({})

function modifier_generic:OnCreated(kv)
	if IsServer() then
		self.kv = kv
		if kv.OnCreated ~= nil and type(kv.OnCreated) == "function" then
			kv.OnCreated()
		end
	end
end

function modifier_generic:AllowIllusionDuplicate(keys)
	if self.kv.AllowIllusionDuplicate ~= nil then
		if type(self.kv.AllowIllusionDuplicate) == "function" then
			return self.kv.AllowIllusionDuplicate(keys)
		else
			return self.kv.AllowIllusionDuplicate
		end
	end
end
function modifier_generic:DestroyOnExpire(keys)
	if self.kv.DestroyOnExpire ~= nil then
		if type(self.kv.DestroyOnExpire) == "function" then
			return self.kv.DestroyOnExpire(keys)
		else
			return self.kv.DestroyOnExpire
		end
	end
end
function modifier_generic:GetAttributes(keys)
	if self.kv.GetAttributes ~= nil then
		if type(self.kv.GetAttributes) == "function" then
			return self.kv.GetAttributes(keys)
		else
			return self.kv.GetAttributes
		end
	end
end
function modifier_generic:GetAuraEntityReject(keys)
	if self.kv.GetAuraEntityReject ~= nil then
		if type(self.kv.GetAuraEntityReject) == "function" then
			return self.kv.GetAuraEntityReject(keys)
		else
			return self.kv.GetAuraEntityReject
		end
	end
end
function modifier_generic:GetAuraRadius(keys)
	if self.kv.GetAuraRadius ~= nil then
		if type(self.kv.GetAuraRadius) == "function" then
			return self.kv.GetAuraRadius(keys)
		else
			return self.kv.GetAuraRadius
		end
	end
end
function modifier_generic:GetAuraSearchFlags(keys)
	if self.kv.GetAuraSearchFlags ~= nil then
		if type(self.kv.GetAuraSearchFlags) == "function" then
			return self.kv.GetAuraSearchFlags(keys)
		else
			return self.kv.GetAuraSearchFlags
		end
	end
end
function modifier_generic:GetAuraSearchTeam(keys)
	if self.kv.GetAuraSearchTeam ~= nil then
		if type(self.kv.GetAuraSearchTeam) == "function" then
			return self.kv.GetAuraSearchTeam(keys)
		else
			return self.kv.GetAuraSearchTeam
		end
	end
end
function modifier_generic:GetAuraSearchType(keys)
	if self.kv.GetAuraSearchType ~= nil then
		if type(self.kv.GetAuraSearchType) == "function" then
			return self.kv.GetAuraSearchType(keys)
		else
			return self.kv.GetAuraSearchType
		end
	end
end
function modifier_generic:GetEffectAttachType(keys)
	if self.kv.GetEffectAttachType ~= nil then
		if type(self.kv.GetEffectAttachType) == "function" then
			return self.kv.GetEffectAttachType(keys)
		else
			return self.kv.GetEffectAttachType
		end
	end
end
function modifier_generic:GetEffectName(keys)
	if self.kv.GetEffectName ~= nil then
		if type(self.kv.GetEffectName) == "function" then
			return self.kv.GetEffectName(keys)
		else
			return self.kv.GetEffectName
		end
	end
end
function modifier_generic:GetHeroEffectName(keys)
	if self.kv.GetHeroEffectName ~= nil then
		if type(self.kv.GetHeroEffectName) == "function" then
			return self.kv.GetHeroEffectName(keys)
		else
			return self.kv.GetHeroEffectName
		end
	end
end
function modifier_generic:GetModifierAura(keys)
	if self.kv.GetModifierAura ~= nil then
		if type(self.kv.GetModifierAura) == "function" then
			return self.kv.GetModifierAura(keys)
		else
			return self.kv.GetModifierAura
		end
	end
end
function modifier_generic:GetStatusEffectName(keys)
	if self.kv.GetStatusEffectName ~= nil then
		if type(self.kv.GetStatusEffectName) == "function" then
			return self.kv.GetStatusEffectName(keys)
		else
			return self.kv.GetStatusEffectName
		end
	end
end
function modifier_generic:GetTexture(keys)
	if self.kv.GetTexture ~= nil then
		if type(self.kv.GetTexture) == "function" then
			return self.kv.GetTexture(keys)
		else
			return self.kv.GetTexture
		end
	end
end
function modifier_generic:HeroEffectPriority(keys)
	if self.kv.HeroEffectPriority ~= nil then
		if type(self.kv.HeroEffectPriority) == "function" then
			return self.kv.HeroEffectPriority(keys)
		else
			return self.kv.HeroEffectPriority
		end
	end
end
function modifier_generic:IsAura(keys)
	if self.kv.IsAura ~= nil then
		if type(self.kv.IsAura) == "function" then
			return self.kv.IsAura(keys)
		else
			return self.kv.IsAura
		end
	end
end
function modifier_generic:IsAuraActiveOnDeath(keys)
	if self.kv.IsAuraActiveOnDeath ~= nil then
		if type(self.kv.IsAuraActiveOnDeath) == "function" then
			return self.kv.IsAuraActiveOnDeath(keys)
		else
			return self.kv.IsAuraActiveOnDeath
		end
	end
end
function modifier_generic:IsDebuff(keys)
	if self.kv.IsDebuff ~= nil then
		if type(self.kv.IsDebuff) == "function" then
			return self.kv.IsDebuff(keys)
		else
			return self.kv.IsDebuff
		end
	end
end
function modifier_generic:IsHidden(keys)
	if self.kv.IsHidden ~= nil then
		if type(self.kv.IsHidden) == "function" then
			return self.kv.IsHidden(keys)
		else
			return self.kv.IsHidden
		end
	end
end
function modifier_generic:IsPurgable(keys)
	if self.kv.IsPurgable ~= nil then
		if type(self.kv.IsPurgable) == "function" then
			return self.kv.IsPurgable(keys)
		else
			return self.kv.IsPurgable
		end
	end
end
function modifier_generic:IsPurgeException(keys)
	if self.kv.IsPurgeException ~= nil then
		if type(self.kv.IsPurgeException) == "function" then
			return self.kv.IsPurgeException(keys)
		else
			return self.kv.IsPurgeException
		end
	end
end
function modifier_generic:IsStunDebuff(keys)
	if self.kv.IsStunDebuff ~= nil then
		if type(self.kv.IsStunDebuff) == "function" then
			return self.kv.IsStunDebuff(keys)
		else
			return self.kv.IsStunDebuff
		end
	end
end
function modifier_generic:RemoveOnDeath(keys)
	if self.kv.RemoveOnDeath ~= nil then
		if type(self.kv.RemoveOnDeath) == "function" then
			return self.kv.RemoveOnDeath(keys)
		else
			return self.kv.RemoveOnDeath
		end
	end
end
function modifier_generic:StatusEffectPriority(keys)
	if self.kv.StatusEffectPriority ~= nil then
		if type(self.kv.StatusEffectPriority) == "function" then
			return self.kv.StatusEffectPriority(keys)
		else
			return self.kv.StatusEffectPriority
		end
	end
end

function modifier_generic:GetModifierPreAttack_BonusDamage(keys)
	if self.kv.GetModifierPreAttack_BonusDamage ~= nil then
		if type(self.kv.GetModifierPreAttack_BonusDamage) == "function" then
			return self.kv.GetModifierPreAttack_BonusDamage(keys)
		else
			return self.kv.GetModifierPreAttack_BonusDamage
		end
	end
end
function modifier_generic:GetModifierPreAttack_BonusDamagePostCrit(keys)
	if self.kv.GetModifierPreAttack_BonusDamagePostCrit ~= nil then
		if type(self.kv.GetModifierPreAttack_BonusDamagePostCrit) == "function" then
			return self.kv.GetModifierPreAttack_BonusDamagePostCrit(keys)
		else
			return self.kv.GetModifierPreAttack_BonusDamagePostCrit
		end
	end
end
function modifier_generic:GetModifierBaseAttack_BonusDamage(keys)
	if self.kv.GetModifierBaseAttack_BonusDamage ~= nil then
		if type(self.kv.GetModifierBaseAttack_BonusDamage) == "function" then
			return self.kv.GetModifierBaseAttack_BonusDamage(keys)
		else
			return self.kv.GetModifierBaseAttack_BonusDamage
		end
	end
end
function modifier_generic:GetModifierProcAttack_BonusDamage_Physical(keys)
	if self.kv.GetModifierProcAttack_BonusDamage_Physical ~= nil then
		if type(self.kv.GetModifierProcAttack_BonusDamage_Physical) == "function" then
			return self.kv.GetModifierProcAttack_BonusDamage_Physical(keys)
		else
			return self.kv.GetModifierProcAttack_BonusDamage_Physical
		end
	end
end
function modifier_generic:GetModifierProcAttack_BonusDamage_Magical(keys)
	if self.kv.GetModifierProcAttack_BonusDamage_Magical ~= nil then
		if type(self.kv.GetModifierProcAttack_BonusDamage_Magical) == "function" then
			return self.kv.GetModifierProcAttack_BonusDamage_Magical(keys)
		else
			return self.kv.GetModifierProcAttack_BonusDamage_Magical
		end
	end
end
function modifier_generic:GetModifierProcAttack_BonusDamage_Pure(keys)
	if self.kv.GetModifierProcAttack_BonusDamage_Pure ~= nil then
		if type(self.kv.GetModifierProcAttack_BonusDamage_Pure) == "function" then
			return self.kv.GetModifierProcAttack_BonusDamage_Pure(keys)
		else
			return self.kv.GetModifierProcAttack_BonusDamage_Pure
		end
	end
end
function modifier_generic:GetModifierProcAttack_Feedback(keys)
	if self.kv.GetModifierProcAttack_Feedback ~= nil then
		if type(self.kv.GetModifierProcAttack_Feedback) == "function" then
			return self.kv.GetModifierProcAttack_Feedback(keys)
		else
			return self.kv.GetModifierProcAttack_Feedback
		end
	end
end
function modifier_generic:GetModifierPreAttack(keys)
	if self.kv.GetModifierPreAttack ~= nil then
		if type(self.kv.GetModifierPreAttack) == "function" then
			return self.kv.GetModifierPreAttack(keys)
		else
			return self.kv.GetModifierPreAttack
		end
	end
end
function modifier_generic:GetModifierInvisibilityLevel(keys)
	if self.kv.GetModifierInvisibilityLevel ~= nil then
		if type(self.kv.GetModifierInvisibilityLevel) == "function" then
			return self.kv.GetModifierInvisibilityLevel(keys)
		else
			return self.kv.GetModifierInvisibilityLevel
		end
	end
end
function modifier_generic:GetModifierPersistentInvisibility(keys)
	if self.kv.GetModifierPersistentInvisibility ~= nil then
		if type(self.kv.GetModifierPersistentInvisibility) == "function" then
			return self.kv.GetModifierPersistentInvisibility(keys)
		else
			return self.kv.GetModifierPersistentInvisibility
		end
	end
end
function modifier_generic:GetModifierMoveSpeedBonus_Constant(keys)
	if self.kv.GetModifierMoveSpeedBonus_Constant ~= nil then
		if type(self.kv.GetModifierMoveSpeedBonus_Constant) == "function" then
			return self.kv.GetModifierMoveSpeedBonus_Constant(keys)
		else
			return self.kv.GetModifierMoveSpeedBonus_Constant
		end
	end
end
function modifier_generic:GetModifierMoveSpeedOverride(keys)
	if self.kv.GetModifierMoveSpeedOverride ~= nil then
		if type(self.kv.GetModifierMoveSpeedOverride) == "function" then
			return self.kv.GetModifierMoveSpeedOverride(keys)
		else
			return self.kv.GetModifierMoveSpeedOverride
		end
	end
end
function modifier_generic:GetModifierMoveSpeedBonus_Percentage(keys)
	if self.kv.GetModifierMoveSpeedBonus_Percentage ~= nil then
		if type(self.kv.GetModifierMoveSpeedBonus_Percentage) == "function" then
			return self.kv.GetModifierMoveSpeedBonus_Percentage(keys)
		else
			return self.kv.GetModifierMoveSpeedBonus_Percentage
		end
	end
end
function modifier_generic:GetModifierMoveSpeedBonus_Percentage_Unique(keys)
	if self.kv.GetModifierMoveSpeedBonus_Percentage_Unique ~= nil then
		if type(self.kv.GetModifierMoveSpeedBonus_Percentage_Unique) == "function" then
			return self.kv.GetModifierMoveSpeedBonus_Percentage_Unique(keys)
		else
			return self.kv.GetModifierMoveSpeedBonus_Percentage_Unique
		end
	end
end
function modifier_generic:GetModifierMoveSpeedBonus_Special_Boots(keys)
	if self.kv.GetModifierMoveSpeedBonus_Special_Boots ~= nil then
		if type(self.kv.GetModifierMoveSpeedBonus_Special_Boots) == "function" then
			return self.kv.GetModifierMoveSpeedBonus_Special_Boots(keys)
		else
			return self.kv.GetModifierMoveSpeedBonus_Special_Boots
		end
	end
end
function modifier_generic:GetModifierMoveSpeed_Absolute(keys)
	if self.kv.GetModifierMoveSpeed_Absolute ~= nil then
		if type(self.kv.GetModifierMoveSpeed_Absolute) == "function" then
			return self.kv.GetModifierMoveSpeed_Absolute(keys)
		else
			return self.kv.GetModifierMoveSpeed_Absolute
		end
	end
end
function modifier_generic:GetModifierMoveSpeed_AbsoluteMin(keys)
	if self.kv.GetModifierMoveSpeed_AbsoluteMin ~= nil then
		if type(self.kv.GetModifierMoveSpeed_AbsoluteMin) == "function" then
			return self.kv.GetModifierMoveSpeed_AbsoluteMin(keys)
		else
			return self.kv.GetModifierMoveSpeed_AbsoluteMin
		end
	end
end
function modifier_generic:GetModifierMoveSpeed_Limit(keys)
	if self.kv.GetModifierMoveSpeed_Limit ~= nil then
		if type(self.kv.GetModifierMoveSpeed_Limit) == "function" then
			return self.kv.GetModifierMoveSpeed_Limit(keys)
		else
			return self.kv.GetModifierMoveSpeed_Limit
		end
	end
end
function modifier_generic:GetModifierMoveSpeed_Max(keys)
	if self.kv.GetModifierMoveSpeed_Max ~= nil then
		if type(self.kv.GetModifierMoveSpeed_Max) == "function" then
			return self.kv.GetModifierMoveSpeed_Max(keys)
		else
			return self.kv.GetModifierMoveSpeed_Max
		end
	end
end
function modifier_generic:GetModifierAttackSpeedBonus_Constant(keys)
	if self.kv.GetModifierAttackSpeedBonus_Constant ~= nil then
		if type(self.kv.GetModifierAttackSpeedBonus_Constant) == "function" then
			return self.kv.GetModifierAttackSpeedBonus_Constant(keys)
		else
			return self.kv.GetModifierAttackSpeedBonus_Constant
		end
	end
end
function modifier_generic:GetModifierAttackSpeedBonus_Constant_PowerTreads(keys)
	if self.kv.GetModifierAttackSpeedBonus_Constant_PowerTreads ~= nil then
		if type(self.kv.GetModifierAttackSpeedBonus_Constant_PowerTreads) == "function" then
			return self.kv.GetModifierAttackSpeedBonus_Constant_PowerTreads(keys)
		else
			return self.kv.GetModifierAttackSpeedBonus_Constant_PowerTreads
		end
	end
end
function modifier_generic:GetModifierAttackSpeedBonus_Constant_Secondary(keys)
	if self.kv.GetModifierAttackSpeedBonus_Constant_Secondary ~= nil then
		if type(self.kv.GetModifierAttackSpeedBonus_Constant_Secondary) == "function" then
			return self.kv.GetModifierAttackSpeedBonus_Constant_Secondary(keys)
		else
			return self.kv.GetModifierAttackSpeedBonus_Constant_Secondary
		end
	end
end
function modifier_generic:GetModifierCooldownReduction_Constant(keys)
	if self.kv.GetModifierCooldownReduction_Constant ~= nil then
		if type(self.kv.GetModifierCooldownReduction_Constant) == "function" then
			return self.kv.GetModifierCooldownReduction_Constant(keys)
		else
			return self.kv.GetModifierCooldownReduction_Constant
		end
	end
end
function modifier_generic:GetModifierBaseAttackTimeConstant(keys)
	if self.kv.GetModifierBaseAttackTimeConstant ~= nil then
		if type(self.kv.GetModifierBaseAttackTimeConstant) == "function" then
			return self.kv.GetModifierBaseAttackTimeConstant(keys)
		else
			return self.kv.GetModifierBaseAttackTimeConstant
		end
	end
end
function modifier_generic:GetModifierAttackPointConstant(keys)
	if self.kv.GetModifierAttackPointConstant ~= nil then
		if type(self.kv.GetModifierAttackPointConstant) == "function" then
			return self.kv.GetModifierAttackPointConstant(keys)
		else
			return self.kv.GetModifierAttackPointConstant
		end
	end
end
function modifier_generic:GetModifierDamageOutgoing_Percentage(keys)
	if self.kv.GetModifierDamageOutgoing_Percentage ~= nil then
		if type(self.kv.GetModifierDamageOutgoing_Percentage) == "function" then
			return self.kv.GetModifierDamageOutgoing_Percentage(keys)
		else
			return self.kv.GetModifierDamageOutgoing_Percentage
		end
	end
end
function modifier_generic:GetModifierDamageOutgoing_Percentage_Illusion(keys)
	if self.kv.GetModifierDamageOutgoing_Percentage_Illusion ~= nil then
		if type(self.kv.GetModifierDamageOutgoing_Percentage_Illusion) == "function" then
			return self.kv.GetModifierDamageOutgoing_Percentage_Illusion(keys)
		else
			return self.kv.GetModifierDamageOutgoing_Percentage_Illusion
		end
	end
end
function modifier_generic:GetModifierTotalDamageOutgoing_Percentage(keys)
	if self.kv.GetModifierTotalDamageOutgoing_Percentage ~= nil then
		if type(self.kv.GetModifierTotalDamageOutgoing_Percentage) == "function" then
			return self.kv.GetModifierTotalDamageOutgoing_Percentage(keys)
		else
			return self.kv.GetModifierTotalDamageOutgoing_Percentage
		end
	end
end
function modifier_generic:GetModifierMagicDamageOutgoing_Percentage(keys)
	if self.kv.GetModifierMagicDamageOutgoing_Percentage ~= nil then
		if type(self.kv.GetModifierMagicDamageOutgoing_Percentage) == "function" then
			return self.kv.GetModifierMagicDamageOutgoing_Percentage(keys)
		else
			return self.kv.GetModifierMagicDamageOutgoing_Percentage
		end
	end
end
function modifier_generic:GetModifierBaseDamageOutgoing_Percentage(keys)
	if self.kv.GetModifierBaseDamageOutgoing_Percentage ~= nil then
		if type(self.kv.GetModifierBaseDamageOutgoing_Percentage) == "function" then
			return self.kv.GetModifierBaseDamageOutgoing_Percentage(keys)
		else
			return self.kv.GetModifierBaseDamageOutgoing_Percentage
		end
	end
end
function modifier_generic:GetModifierBaseDamageOutgoing_PercentageUnique(keys)
	if self.kv.GetModifierBaseDamageOutgoing_PercentageUnique ~= nil then
		if type(self.kv.GetModifierBaseDamageOutgoing_PercentageUnique) == "function" then
			return self.kv.GetModifierBaseDamageOutgoing_PercentageUnique(keys)
		else
			return self.kv.GetModifierBaseDamageOutgoing_PercentageUnique
		end
	end
end
function modifier_generic:GetModifierIncomingDamage_Percentage(keys)
	if self.kv.GetModifierIncomingDamage_Percentage ~= nil then
		if type(self.kv.GetModifierIncomingDamage_Percentage) == "function" then
			return self.kv.GetModifierIncomingDamage_Percentage(keys)
		else
			return self.kv.GetModifierIncomingDamage_Percentage
		end
	end
end
function modifier_generic:GetModifierIncomingPhysicalDamage_Percentage(keys)
	if self.kv.GetModifierIncomingPhysicalDamage_Percentage ~= nil then
		if type(self.kv.GetModifierIncomingPhysicalDamage_Percentage) == "function" then
			return self.kv.GetModifierIncomingPhysicalDamage_Percentage(keys)
		else
			return self.kv.GetModifierIncomingPhysicalDamage_Percentage
		end
	end
end
function modifier_generic:GetModifierIncomingSpellDamageConstant(keys)
	if self.kv.GetModifierIncomingSpellDamageConstant ~= nil then
		if type(self.kv.GetModifierIncomingSpellDamageConstant) == "function" then
			return self.kv.GetModifierIncomingSpellDamageConstant(keys)
		else
			return self.kv.GetModifierIncomingSpellDamageConstant
		end
	end
end
function modifier_generic:GetModifierEvasion_Constant(keys)
	if self.kv.GetModifierEvasion_Constant ~= nil then
		if type(self.kv.GetModifierEvasion_Constant) == "function" then
			return self.kv.GetModifierEvasion_Constant(keys)
		else
			return self.kv.GetModifierEvasion_Constant
		end
	end
end
function modifier_generic:GetModifierAvoidDamage(keys)
	if self.kv.GetModifierAvoidDamage ~= nil then
		if type(self.kv.GetModifierAvoidDamage) == "function" then
			return self.kv.GetModifierAvoidDamage(keys)
		else
			return self.kv.GetModifierAvoidDamage
		end
	end
end
function modifier_generic:GetModifierAvoidSpell(keys)
	if self.kv.GetModifierAvoidSpell ~= nil then
		if type(self.kv.GetModifierAvoidSpell) == "function" then
			return self.kv.GetModifierAvoidSpell(keys)
		else
			return self.kv.GetModifierAvoidSpell
		end
	end
end
function modifier_generic:GetModifierMiss_Percentage(keys)
	if self.kv.GetModifierMiss_Percentage ~= nil then
		if type(self.kv.GetModifierMiss_Percentage) == "function" then
			return self.kv.GetModifierMiss_Percentage(keys)
		else
			return self.kv.GetModifierMiss_Percentage
		end
	end
end
function modifier_generic:GetModifierPhysicalArmorBonus(keys)
	if self.kv.GetModifierPhysicalArmorBonus ~= nil then
		if type(self.kv.GetModifierPhysicalArmorBonus) == "function" then
			return self.kv.GetModifierPhysicalArmorBonus(keys)
		else
			return self.kv.GetModifierPhysicalArmorBonus
		end
	end
end
function modifier_generic:GetModifierPhysicalArmorBonusIllusions(keys)
	if self.kv.GetModifierPhysicalArmorBonusIllusions ~= nil then
		if type(self.kv.GetModifierPhysicalArmorBonusIllusions) == "function" then
			return self.kv.GetModifierPhysicalArmorBonusIllusions(keys)
		else
			return self.kv.GetModifierPhysicalArmorBonusIllusions
		end
	end
end
function modifier_generic:GetModifierPhysicalArmorBonusUnique(keys)
	if self.kv.GetModifierPhysicalArmorBonusUnique ~= nil then
		if type(self.kv.GetModifierPhysicalArmorBonusUnique) == "function" then
			return self.kv.GetModifierPhysicalArmorBonusUnique(keys)
		else
			return self.kv.GetModifierPhysicalArmorBonusUnique
		end
	end
end
function modifier_generic:GetModifierPhysicalArmorBonusUniqueActive(keys)
	if self.kv.GetModifierPhysicalArmorBonusUniqueActive ~= nil then
		if type(self.kv.GetModifierPhysicalArmorBonusUniqueActive) == "function" then
			return self.kv.GetModifierPhysicalArmorBonusUniqueActive(keys)
		else
			return self.kv.GetModifierPhysicalArmorBonusUniqueActive
		end
	end
end
function modifier_generic:GetModifierMagicalResistanceBonus(keys)
	if self.kv.GetModifierMagicalResistanceBonus ~= nil then
		if type(self.kv.GetModifierMagicalResistanceBonus) == "function" then
			return self.kv.GetModifierMagicalResistanceBonus(keys)
		else
			return self.kv.GetModifierMagicalResistanceBonus
		end
	end
end
function modifier_generic:GetModifierMagicalResistanceItemUnique(keys)
	if self.kv.GetModifierMagicalResistanceItemUnique ~= nil then
		if type(self.kv.GetModifierMagicalResistanceItemUnique) == "function" then
			return self.kv.GetModifierMagicalResistanceItemUnique(keys)
		else
			return self.kv.GetModifierMagicalResistanceItemUnique
		end
	end
end
function modifier_generic:GetModifierMagicalResistanceDecrepifyUnique(keys)
	if self.kv.GetModifierMagicalResistanceDecrepifyUnique ~= nil then
		if type(self.kv.GetModifierMagicalResistanceDecrepifyUnique) == "function" then
			return self.kv.GetModifierMagicalResistanceDecrepifyUnique(keys)
		else
			return self.kv.GetModifierMagicalResistanceDecrepifyUnique
		end
	end
end
function modifier_generic:GetModifierBaseRegen(keys)
	if self.kv.GetModifierBaseRegen ~= nil then
		if type(self.kv.GetModifierBaseRegen) == "function" then
			return self.kv.GetModifierBaseRegen(keys)
		else
			return self.kv.GetModifierBaseRegen
		end
	end
end
function modifier_generic:GetModifierConstantManaRegen(keys)
	if self.kv.GetModifierConstantManaRegen ~= nil then
		if type(self.kv.GetModifierConstantManaRegen) == "function" then
			return self.kv.GetModifierConstantManaRegen(keys)
		else
			return self.kv.GetModifierConstantManaRegen
		end
	end
end
function modifier_generic:GetModifierConstantManaRegenUnique(keys)
	if self.kv.GetModifierConstantManaRegenUnique ~= nil then
		if type(self.kv.GetModifierConstantManaRegenUnique) == "function" then
			return self.kv.GetModifierConstantManaRegenUnique(keys)
		else
			return self.kv.GetModifierConstantManaRegenUnique
		end
	end
end
function modifier_generic:GetModifierPercentageManaRegen(keys)
	if self.kv.GetModifierPercentageManaRegen ~= nil then
		if type(self.kv.GetModifierPercentageManaRegen) == "function" then
			return self.kv.GetModifierPercentageManaRegen(keys)
		else
			return self.kv.GetModifierPercentageManaRegen
		end
	end
end
function modifier_generic:GetModifierTotalPercentageManaRegen(keys)
	if self.kv.GetModifierTotalPercentageManaRegen ~= nil then
		if type(self.kv.GetModifierTotalPercentageManaRegen) == "function" then
			return self.kv.GetModifierTotalPercentageManaRegen(keys)
		else
			return self.kv.GetModifierTotalPercentageManaRegen
		end
	end
end
function modifier_generic:GetModifierConstantHealthRegen(keys)
	if self.kv.GetModifierConstantHealthRegen ~= nil then
		if type(self.kv.GetModifierConstantHealthRegen) == "function" then
			return self.kv.GetModifierConstantHealthRegen(keys)
		else
			return self.kv.GetModifierConstantHealthRegen
		end
	end
end
function modifier_generic:GetModifierHealthRegenPercentage(keys)
	if self.kv.GetModifierHealthRegenPercentage ~= nil then
		if type(self.kv.GetModifierHealthRegenPercentage) == "function" then
			return self.kv.GetModifierHealthRegenPercentage(keys)
		else
			return self.kv.GetModifierHealthRegenPercentage
		end
	end
end
function modifier_generic:GetModifierHealthBonus(keys)
	if self.kv.GetModifierHealthBonus ~= nil then
		if type(self.kv.GetModifierHealthBonus) == "function" then
			return self.kv.GetModifierHealthBonus(keys)
		else
			return self.kv.GetModifierHealthBonus
		end
	end
end
function modifier_generic:GetModifierManaBonus(keys)
	if self.kv.GetModifierManaBonus ~= nil then
		if type(self.kv.GetModifierManaBonus) == "function" then
			return self.kv.GetModifierManaBonus(keys)
		else
			return self.kv.GetModifierManaBonus
		end
	end
end
function modifier_generic:GetModifierExtraStrengthBonus(keys)
	if self.kv.GetModifierExtraStrengthBonus ~= nil then
		if type(self.kv.GetModifierExtraStrengthBonus) == "function" then
			return self.kv.GetModifierExtraStrengthBonus(keys)
		else
			return self.kv.GetModifierExtraStrengthBonus
		end
	end
end
function modifier_generic:GetModifierExtraHealthBonus(keys)
	if self.kv.GetModifierExtraHealthBonus ~= nil then
		if type(self.kv.GetModifierExtraHealthBonus) == "function" then
			return self.kv.GetModifierExtraHealthBonus(keys)
		else
			return self.kv.GetModifierExtraHealthBonus
		end
	end
end
function modifier_generic:GetModifierExtraManaBonus(keys)
	if self.kv.GetModifierExtraManaBonus ~= nil then
		if type(self.kv.GetModifierExtraManaBonus) == "function" then
			return self.kv.GetModifierExtraManaBonus(keys)
		else
			return self.kv.GetModifierExtraManaBonus
		end
	end
end
function modifier_generic:GetModifierExtraHealthPercentage(keys)
	if self.kv.GetModifierExtraHealthPercentage ~= nil then
		if type(self.kv.GetModifierExtraHealthPercentage) == "function" then
			return self.kv.GetModifierExtraHealthPercentage(keys)
		else
			return self.kv.GetModifierExtraHealthPercentage
		end
	end
end
function modifier_generic:GetModifierBonusStats_Strength(keys)
	if self.kv.GetModifierBonusStats_Strength ~= nil then
		if type(self.kv.GetModifierBonusStats_Strength) == "function" then
			return self.kv.GetModifierBonusStats_Strength(keys)
		else
			return self.kv.GetModifierBonusStats_Strength
		end
	end
end
function modifier_generic:GetModifierBonusStats_Agility(keys)
	if self.kv.GetModifierBonusStats_Agility ~= nil then
		if type(self.kv.GetModifierBonusStats_Agility) == "function" then
			return self.kv.GetModifierBonusStats_Agility(keys)
		else
			return self.kv.GetModifierBonusStats_Agility
		end
	end
end
function modifier_generic:GetModifierBonusStats_Intellect(keys)
	if self.kv.GetModifierBonusStats_Intellect ~= nil then
		if type(self.kv.GetModifierBonusStats_Intellect) == "function" then
			return self.kv.GetModifierBonusStats_Intellect(keys)
		else
			return self.kv.GetModifierBonusStats_Intellect
		end
	end
end
function modifier_generic:GetModifierAttackRangeBonus(keys)
	if self.kv.GetModifierAttackRangeBonus ~= nil then
		if type(self.kv.GetModifierAttackRangeBonus) == "function" then
			return self.kv.GetModifierAttackRangeBonus(keys)
		else
			return self.kv.GetModifierAttackRangeBonus
		end
	end
end
function modifier_generic:GetModifierProjectileSpeedBonus(keys)
	if self.kv.GetModifierProjectileSpeedBonus ~= nil then
		if type(self.kv.GetModifierProjectileSpeedBonus) == "function" then
			return self.kv.GetModifierProjectileSpeedBonus(keys)
		else
			return self.kv.GetModifierProjectileSpeedBonus
		end
	end
end
function modifier_generic:GetModifierCastRangeBonus(keys)
	if self.kv.GetModifierCastRangeBonus ~= nil then
		if type(self.kv.GetModifierCastRangeBonus) == "function" then
			return self.kv.GetModifierCastRangeBonus(keys)
		else
			return self.kv.GetModifierCastRangeBonus
		end
	end
end
function modifier_generic:GetModifierConstantRespawnTime(keys)
	if self.kv.GetModifierConstantRespawnTime ~= nil then
		if type(self.kv.GetModifierConstantRespawnTime) == "function" then
			return self.kv.GetModifierConstantRespawnTime(keys)
		else
			return self.kv.GetModifierConstantRespawnTime
		end
	end
end
function modifier_generic:GetModifierPercentageRespawnTime(keys)
	if self.kv.GetModifierPercentageRespawnTime ~= nil then
		if type(self.kv.GetModifierPercentageRespawnTime) == "function" then
			return self.kv.GetModifierPercentageRespawnTime(keys)
		else
			return self.kv.GetModifierPercentageRespawnTime
		end
	end
end
function modifier_generic:GetModifierStackingRespawnTime(keys)
	if self.kv.GetModifierStackingRespawnTime ~= nil then
		if type(self.kv.GetModifierStackingRespawnTime) == "function" then
			return self.kv.GetModifierStackingRespawnTime(keys)
		else
			return self.kv.GetModifierStackingRespawnTime
		end
	end
end
function modifier_generic:GetModifierPercentageCooldown(keys)
	if self.kv.GetModifierPercentageCooldown ~= nil then
		if type(self.kv.GetModifierPercentageCooldown) == "function" then
			return self.kv.GetModifierPercentageCooldown(keys)
		else
			return self.kv.GetModifierPercentageCooldown
		end
	end
end
function modifier_generic:GetModifierPercentageCasttime(keys)
	if self.kv.GetModifierPercentageCasttime ~= nil then
		if type(self.kv.GetModifierPercentageCasttime) == "function" then
			return self.kv.GetModifierPercentageCasttime(keys)
		else
			return self.kv.GetModifierPercentageCasttime
		end
	end
end
function modifier_generic:GetModifierPercentageManacost(keys)
	if self.kv.GetModifierPercentageManacost ~= nil then
		if type(self.kv.GetModifierPercentageManacost) == "function" then
			return self.kv.GetModifierPercentageManacost(keys)
		else
			return self.kv.GetModifierPercentageManacost
		end
	end
end
function modifier_generic:GetModifierConstantDeathGoldCost(keys)
	if self.kv.GetModifierConstantDeathGoldCost ~= nil then
		if type(self.kv.GetModifierConstantDeathGoldCost) == "function" then
			return self.kv.GetModifierConstantDeathGoldCost(keys)
		else
			return self.kv.GetModifierConstantDeathGoldCost
		end
	end
end
function modifier_generic:GetModifierPreAttack_CriticalStrike(keys)
	if self.kv.GetModifierPreAttack_CriticalStrike ~= nil then
		if type(self.kv.GetModifierPreAttack_CriticalStrike) == "function" then
			return self.kv.GetModifierPreAttack_CriticalStrike(keys)
		else
			return self.kv.GetModifierPreAttack_CriticalStrike
		end
	end
end
function modifier_generic:GetModifierPhysical_ConstantBlock(keys)
	if self.kv.GetModifierPhysical_ConstantBlock ~= nil then
		if type(self.kv.GetModifierPhysical_ConstantBlock) == "function" then
			return self.kv.GetModifierPhysical_ConstantBlock(keys)
		else
			return self.kv.GetModifierPhysical_ConstantBlock
		end
	end
end
function modifier_generic:GetModifierPhysical_ConstantBlockUnavoidablePreArmor(keys)
	if self.kv.GetModifierPhysical_ConstantBlockUnavoidablePreArmor ~= nil then
		if type(self.kv.GetModifierPhysical_ConstantBlockUnavoidablePreArmor) == "function" then
			return self.kv.GetModifierPhysical_ConstantBlockUnavoidablePreArmor(keys)
		else
			return self.kv.GetModifierPhysical_ConstantBlockUnavoidablePreArmor
		end
	end
end
function modifier_generic:GetModifierTotal_ConstantBlock(keys)
	if self.kv.GetModifierTotal_ConstantBlock ~= nil then
		if type(self.kv.GetModifierTotal_ConstantBlock) == "function" then
			return self.kv.GetModifierTotal_ConstantBlock(keys)
		else
			return self.kv.GetModifierTotal_ConstantBlock
		end
	end
end
function modifier_generic:GetOverrideAnimation(keys)
	if self.kv.GetOverrideAnimation ~= nil then
		if type(self.kv.GetOverrideAnimation) == "function" then
			return self.kv.GetOverrideAnimation(keys)
		else
			return self.kv.GetOverrideAnimation
		end
	end
end
function modifier_generic:GetOverrideAnimationWeight(keys)
	if self.kv.GetOverrideAnimationWeight ~= nil then
		if type(self.kv.GetOverrideAnimationWeight) == "function" then
			return self.kv.GetOverrideAnimationWeight(keys)
		else
			return self.kv.GetOverrideAnimationWeight
		end
	end
end
function modifier_generic:GetOverrideAnimationRate(keys)
	if self.kv.GetOverrideAnimationRate ~= nil then
		if type(self.kv.GetOverrideAnimationRate) == "function" then
			return self.kv.GetOverrideAnimationRate(keys)
		else
			return self.kv.GetOverrideAnimationRate
		end
	end
end
function modifier_generic:GetAbsorbSpell(keys)
	if self.kv.GetAbsorbSpell ~= nil then
		if type(self.kv.GetAbsorbSpell) == "function" then
			return self.kv.GetAbsorbSpell(keys)
		else
			return self.kv.GetAbsorbSpell
		end
	end
end
function modifier_generic:GetReflectSpell(keys)
	if self.kv.GetReflectSpell ~= nil then
		if type(self.kv.GetReflectSpell) == "function" then
			return self.kv.GetReflectSpell(keys)
		else
			return self.kv.GetReflectSpell
		end
	end
end
function modifier_generic:GetDisableAutoAttack(keys)
	if self.kv.GetDisableAutoAttack ~= nil then
		if type(self.kv.GetDisableAutoAttack) == "function" then
			return self.kv.GetDisableAutoAttack(keys)
		else
			return self.kv.GetDisableAutoAttack
		end
	end
end
function modifier_generic:GetBonusDayVision(keys)
	if self.kv.GetBonusDayVision ~= nil then
		if type(self.kv.GetBonusDayVision) == "function" then
			return self.kv.GetBonusDayVision(keys)
		else
			return self.kv.GetBonusDayVision
		end
	end
end
function modifier_generic:GetBonusNightVision(keys)
	if self.kv.GetBonusNightVision ~= nil then
		if type(self.kv.GetBonusNightVision) == "function" then
			return self.kv.GetBonusNightVision(keys)
		else
			return self.kv.GetBonusNightVision
		end
	end
end
function modifier_generic:GetBonusNightVisionUnique(keys)
	if self.kv.GetBonusNightVisionUnique ~= nil then
		if type(self.kv.GetBonusNightVisionUnique) == "function" then
			return self.kv.GetBonusNightVisionUnique(keys)
		else
			return self.kv.GetBonusNightVisionUnique
		end
	end
end
function modifier_generic:GetBonusVisionPercentage(keys)
	if self.kv.GetBonusVisionPercentage ~= nil then
		if type(self.kv.GetBonusVisionPercentage) == "function" then
			return self.kv.GetBonusVisionPercentage(keys)
		else
			return self.kv.GetBonusVisionPercentage
		end
	end
end
function modifier_generic:GetFixedDayVision(keys)
	if self.kv.GetFixedDayVision ~= nil then
		if type(self.kv.GetFixedDayVision) == "function" then
			return self.kv.GetFixedDayVision(keys)
		else
			return self.kv.GetFixedDayVision
		end
	end
end
function modifier_generic:GetFixedNightVision(keys)
	if self.kv.GetFixedNightVision ~= nil then
		if type(self.kv.GetFixedNightVision) == "function" then
			return self.kv.GetFixedNightVision(keys)
		else
			return self.kv.GetFixedNightVision
		end
	end
end
function modifier_generic:GetMinHealth(keys)
	if self.kv.GetMinHealth ~= nil then
		if type(self.kv.GetMinHealth) == "function" then
			return self.kv.GetMinHealth(keys)
		else
			return self.kv.GetMinHealth
		end
	end
end
function modifier_generic:GetAbsoluteNoDamagePhysical(keys)
	if self.kv.GetAbsoluteNoDamagePhysical ~= nil then
		if type(self.kv.GetAbsoluteNoDamagePhysical) == "function" then
			return self.kv.GetAbsoluteNoDamagePhysical(keys)
		else
			return self.kv.GetAbsoluteNoDamagePhysical
		end
	end
end
function modifier_generic:GetAbsoluteNoDamageMagical(keys)
	if self.kv.GetAbsoluteNoDamageMagical ~= nil then
		if type(self.kv.GetAbsoluteNoDamageMagical) == "function" then
			return self.kv.GetAbsoluteNoDamageMagical(keys)
		else
			return self.kv.GetAbsoluteNoDamageMagical
		end
	end
end
function modifier_generic:GetAbsoluteNoDamagePure(keys)
	if self.kv.GetAbsoluteNoDamagePure ~= nil then
		if type(self.kv.GetAbsoluteNoDamagePure) == "function" then
			return self.kv.GetAbsoluteNoDamagePure(keys)
		else
			return self.kv.GetAbsoluteNoDamagePure
		end
	end
end
function modifier_generic:GetIsIllusion(keys)
	if self.kv.GetIsIllusion ~= nil then
		if type(self.kv.GetIsIllusion) == "function" then
			return self.kv.GetIsIllusion(keys)
		else
			return self.kv.GetIsIllusion
		end
	end
end
function modifier_generic:GetModifierIllusionLabel(keys)
	if self.kv.GetModifierIllusionLabel ~= nil then
		if type(self.kv.GetModifierIllusionLabel) == "function" then
			return self.kv.GetModifierIllusionLabel(keys)
		else
			return self.kv.GetModifierIllusionLabel
		end
	end
end
function modifier_generic:GetModifierSuperIllusion(keys)
	if self.kv.GetModifierSuperIllusion ~= nil then
		if type(self.kv.GetModifierSuperIllusion) == "function" then
			return self.kv.GetModifierSuperIllusion(keys)
		else
			return self.kv.GetModifierSuperIllusion
		end
	end
end
function modifier_generic:GetModifierTurnRate_Percentage(keys)
	if self.kv.GetModifierTurnRate_Percentage ~= nil then
		if type(self.kv.GetModifierTurnRate_Percentage) == "function" then
			return self.kv.GetModifierTurnRate_Percentage(keys)
		else
			return self.kv.GetModifierTurnRate_Percentage
		end
	end
end
function modifier_generic:GetDisableHealing(keys)
	if self.kv.GetDisableHealing ~= nil then
		if type(self.kv.GetDisableHealing) == "function" then
			return self.kv.GetDisableHealing(keys)
		else
			return self.kv.GetDisableHealing
		end
	end
end
function modifier_generic:GetOverrideAttackMagical(keys)
	if self.kv.GetOverrideAttackMagical ~= nil then
		if type(self.kv.GetOverrideAttackMagical) == "function" then
			return self.kv.GetOverrideAttackMagical(keys)
		else
			return self.kv.GetOverrideAttackMagical
		end
	end
end
function modifier_generic:GetModifierUnitStatsNeedsRefresh(keys)
	if self.kv.GetModifierUnitStatsNeedsRefresh ~= nil then
		if type(self.kv.GetModifierUnitStatsNeedsRefresh) == "function" then
			return self.kv.GetModifierUnitStatsNeedsRefresh(keys)
		else
			return self.kv.GetModifierUnitStatsNeedsRefresh
		end
	end
end
function modifier_generic:GetModifierBountyCreepMultiplier(keys)
	if self.kv.GetModifierBountyCreepMultiplier ~= nil then
		if type(self.kv.GetModifierBountyCreepMultiplier) == "function" then
			return self.kv.GetModifierBountyCreepMultiplier(keys)
		else
			return self.kv.GetModifierBountyCreepMultiplier
		end
	end
end
function modifier_generic:GetModifierBountyOtherMultiplier(keys)
	if self.kv.GetModifierBountyOtherMultiplier ~= nil then
		if type(self.kv.GetModifierBountyOtherMultiplier) == "function" then
			return self.kv.GetModifierBountyOtherMultiplier(keys)
		else
			return self.kv.GetModifierBountyOtherMultiplier
		end
	end
end
function modifier_generic:GetModifierModelChange(keys)
	if self.kv.GetModifierModelChange ~= nil then
		if type(self.kv.GetModifierModelChange) == "function" then
			return self.kv.GetModifierModelChange(keys)
		else
			return self.kv.GetModifierModelChange
		end
	end
end
function modifier_generic:GetModifierModelScale(keys)
	if self.kv.GetModifierModelScale ~= nil then
		if type(self.kv.GetModifierModelScale) == "function" then
			return self.kv.GetModifierModelScale(keys)
		else
			return self.kv.GetModifierModelScale
		end
	end
end
function modifier_generic:GetModifierScepter(keys)
	if self.kv.GetModifierScepter ~= nil then
		if type(self.kv.GetModifierScepter) == "function" then
			return self.kv.GetModifierScepter(keys)
		else
			return self.kv.GetModifierScepter
		end
	end
end
function modifier_generic:GetActivityTranslationModifiers(keys)
	if self.kv.GetActivityTranslationModifiers ~= nil then
		if type(self.kv.GetActivityTranslationModifiers) == "function" then
			return self.kv.GetActivityTranslationModifiers(keys)
		else
			return self.kv.GetActivityTranslationModifiers
		end
	end
end
function modifier_generic:GetAttackSound(keys)
	if self.kv.GetAttackSound ~= nil then
		if type(self.kv.GetAttackSound) == "function" then
			return self.kv.GetAttackSound(keys)
		else
			return self.kv.GetAttackSound
		end
	end
end
function modifier_generic:GetUnitLifetimeFraction(keys)
	if self.kv.GetUnitLifetimeFraction ~= nil then
		if type(self.kv.GetUnitLifetimeFraction) == "function" then
			return self.kv.GetUnitLifetimeFraction(keys)
		else
			return self.kv.GetUnitLifetimeFraction
		end
	end
end
function modifier_generic:GetModifierProvidesFOWVision(keys)
	if self.kv.GetModifierProvidesFOWVision ~= nil then
		if type(self.kv.GetModifierProvidesFOWVision) == "function" then
			return self.kv.GetModifierProvidesFOWVision(keys)
		else
			return self.kv.GetModifierProvidesFOWVision
		end
	end
end
function modifier_generic:GetModifierSpellsRequireHP(keys)
	if self.kv.GetModifierSpellsRequireHP ~= nil then
		if type(self.kv.GetModifierSpellsRequireHP) == "function" then
			return self.kv.GetModifierSpellsRequireHP(keys)
		else
			return self.kv.GetModifierSpellsRequireHP
		end
	end
end
function modifier_generic:GetForceDrawOnMinimap(keys)
	if self.kv.GetForceDrawOnMinimap ~= nil then
		if type(self.kv.GetForceDrawOnMinimap) == "function" then
			return self.kv.GetForceDrawOnMinimap(keys)
		else
			return self.kv.GetForceDrawOnMinimap
		end
	end
end
function modifier_generic:GetModifierDisableTurning(keys)
	if self.kv.GetModifierDisableTurning ~= nil then
		if type(self.kv.GetModifierDisableTurning) == "function" then
			return self.kv.GetModifierDisableTurning(keys)
		else
			return self.kv.GetModifierDisableTurning
		end
	end
end
function modifier_generic:GetModifierIgnoreCastAngle(keys)
	if self.kv.GetModifierIgnoreCastAngle ~= nil then
		if type(self.kv.GetModifierIgnoreCastAngle) == "function" then
			return self.kv.GetModifierIgnoreCastAngle(keys)
		else
			return self.kv.GetModifierIgnoreCastAngle
		end
	end
end
function modifier_generic:GetModifierChangeAbilityValue(keys)
	if self.kv.GetModifierChangeAbilityValue ~= nil then
		if type(self.kv.GetModifierChangeAbilityValue) == "function" then
			return self.kv.GetModifierChangeAbilityValue(keys)
		else
			return self.kv.GetModifierChangeAbilityValue
		end
	end
end
function modifier_generic:GetModifierAbilityLayout(keys)
	if self.kv.GetModifierAbilityLayout ~= nil then
		if type(self.kv.GetModifierAbilityLayout) == "function" then
			return self.kv.GetModifierAbilityLayout(keys)
		else
			return self.kv.GetModifierAbilityLayout
		end
	end
end
function modifier_generic:GetModifierTempestDouble(keys)
	if self.kv.GetModifierTempestDouble ~= nil then
		if type(self.kv.GetModifierTempestDouble) == "function" then
			return self.kv.GetModifierTempestDouble(keys)
		else
			return self.kv.GetModifierTempestDouble
		end
	end
end
function modifier_generic:ReincarnateTime(keys)
	if self.kv.ReincarnateTime ~= nil then
		if type(self.kv.ReincarnateTime) == "function" then
			return self.kv.ReincarnateTime(keys)
		else
			return self.kv.ReincarnateTime
		end
	end
end
function modifier_generic:PreserveParticlesOnModelChanged(keys)
	if self.kv.PreserveParticlesOnModelChanged ~= nil then
		if type(self.kv.PreserveParticlesOnModelChanged) == "function" then
			return self.kv.PreserveParticlesOnModelChanged(keys)
		else
			return self.kv.PreserveParticlesOnModelChanged
		end
	end
end

if IsServer() then
	function modifier_generic:OnDestroy(keys)
		if self.kv.OnDestroy then
			return self.kv.OnDestroy(keys)
		end
	end
	function modifier_generic:OnIntervalThink(keys)
		if self.kv.OnIntervalThink then
			return self.kv.OnIntervalThink(keys)
		end
	end
	function modifier_generic:OnRefresh(keys)
		if self.kv.OnRefresh then
			return self.kv.OnRefresh(keys)
		end
	end
	function modifier_generic:OnAttackRecord(keys)
		if self.kv.OnAttackRecord then
			return self.kv.OnAttackRecord(keys)
		end
	end
	function modifier_generic:OnAttackStart(keys)
		if self.kv.OnAttackStart then
			return self.kv.OnAttackStart(keys)
		end
	end
	function modifier_generic:OnAttack(keys)
		if self.kv.OnAttack then
			return self.kv.OnAttack(keys)
		end
	end
	function modifier_generic:OnAttackLanded(keys)
		if self.kv.OnAttackLanded then
			return self.kv.OnAttackLanded(keys)
		end
	end
	function modifier_generic:OnAttackFail(keys)
		if self.kv.OnAttackFail then
			return self.kv.OnAttackFail(keys)
		end
	end
	function modifier_generic:OnAttackAllied(keys)
		if self.kv.OnAttackAllied then
			return self.kv.OnAttackAllied(keys)
		end
	end
	function modifier_generic:OnProjectileDodge(keys)
		if self.kv.OnProjectileDodge then
			return self.kv.OnProjectileDodge(keys)
		end
	end
	function modifier_generic:OnOrder(keys)
		if self.kv.OnOrder then
			return self.kv.OnOrder(keys)
		end
	end
	function modifier_generic:OnUnitMoved(keys)
		if self.kv.OnUnitMoved then
			return self.kv.OnUnitMoved(keys)
		end
	end
	function modifier_generic:OnAbilityStart(keys)
		if self.kv.OnAbilityStart then
			return self.kv.OnAbilityStart(keys)
		end
	end
	function modifier_generic:OnAbilityExecuted(keys)
		if self.kv.OnAbilityExecuted then
			return self.kv.OnAbilityExecuted(keys)
		end
	end
	function modifier_generic:OnAbilityFullyCast(keys)
		if self.kv.OnAbilityFullyCast then
			return self.kv.OnAbilityFullyCast(keys)
		end
	end
	function modifier_generic:OnBreakInvisibility(keys)
		if self.kv.OnBreakInvisibility then
			return self.kv.OnBreakInvisibility(keys)
		end
	end
	function modifier_generic:OnAbilityEndChannel(keys)
		if self.kv.OnAbilityEndChannel then
			return self.kv.OnAbilityEndChannel(keys)
		end
	end
	function modifier_generic:OnTakeDamage(keys)
		if self.kv.OnTakeDamage then
			return self.kv.OnTakeDamage(keys)
		end
	end
	function modifier_generic:OnStateChanged(keys)
		if self.kv.OnStateChanged then
			return self.kv.OnStateChanged(keys)
		end
	end
	function modifier_generic:OnAttacked(keys)
		if self.kv.OnAttacked then
			return self.kv.OnAttacked(keys)
		end
	end
	function modifier_generic:OnDeath(keys)
		if self.kv.OnDeath then
			return self.kv.OnDeath(keys)
		end
	end
	function modifier_generic:OnRespawn(keys)
		if self.kv.OnRespawn then
			return self.kv.OnRespawn(keys)
		end
	end
	function modifier_generic:OnSpentMana(keys)
		if self.kv.OnSpentMana then
			return self.kv.OnSpentMana(keys)
		end
	end
	function modifier_generic:OnTeleporting(keys)
		if self.kv.OnTeleporting then
			return self.kv.OnTeleporting(keys)
		end
	end
	function modifier_generic:OnTeleported(keys)
		if self.kv.OnTeleported then
			return self.kv.OnTeleported(keys)
		end
	end
	function modifier_generic:OnSetLocation(keys)
		if self.kv.OnSetLocation then
			return self.kv.OnSetLocation(keys)
		end
	end
	function modifier_generic:OnHealthGained(keys)
		if self.kv.OnHealthGained then
			return self.kv.OnHealthGained(keys)
		end
	end
	function modifier_generic:OnManaGained(keys)
		if self.kv.OnManaGained then
			return self.kv.OnManaGained(keys)
		end
	end
	function modifier_generic:OnTakeDamageKillCredit(keys)
		if self.kv.OnTakeDamageKillCredit then
			return self.kv.OnTakeDamageKillCredit(keys)
		end
	end
	function modifier_generic:OnHeroKilled(keys)
		if self.kv.OnHeroKilled then
			return self.kv.OnHeroKilled(keys)
		end
	end
	function modifier_generic:OnHealReceived(keys)
		if self.kv.OnHealReceived then
			return self.kv.OnHealReceived(keys)
		end
	end
	function modifier_generic:OnBuildingKilled(keys)
		if self.kv.OnBuildingKilled then
			return self.kv.OnBuildingKilled(keys)
		end
	end
	function modifier_generic:OnModelChanged(keys)
		if self.kv.OnModelChanged then
			return self.kv.OnModelChanged(keys)
		end
	end
	function modifier_generic:OnTooltip(keys)
		if self.kv.OnTooltip then
			return self.kv.OnTooltip(keys)
		end
	end
	function modifier_generic:OnDominated(keys)
		if self.kv.OnDominated then
			return self.kv.OnDominated(keys)
		end
	end
end