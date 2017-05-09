modifier_item_demon_king_bar_curse = class({})

function modifier_item_demon_king_bar_curse:GetEffectName()
	return "particles/arena/items_fx/demon_king_bar_curse_mark.vpcf"
end

function modifier_item_demon_king_bar_curse:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

if IsServer() then
	function modifier_item_demon_king_bar_curse:DeclareFunctions()
		return {MODIFIER_PROPERTY_TOOLTIP}
	end

	function modifier_item_demon_king_bar_curse:OnCreated()
		self:StartIntervalThink(0.5)
		self:OnIntervalThink()
	end

	function modifier_item_demon_king_bar_curse:OnIntervalThink()
		local parent = self:GetParent()
		ApplyDamage({
			attacker = parent,
			victim = parent,
			damage = self:OnTooltip() * 0.5,
			damage_type = ability:GetAbilityDamageType(),
			damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
			ability = ability,
		})
		if not parent:IsAlive() then
			target:EmitSound("Hero_VengefulSpirit.MagicMissileImpact")
		end
	end

	function modifier_item_demon_king_bar_curse:OnTooltip()
		return 2 ^ math.ceil(self:GetDuration())
	end
end