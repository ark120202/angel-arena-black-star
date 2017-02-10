modifier_arena_rune_spikes = class({})
function modifier_arena_rune_spikes:GetTexture()
	return "arena/arena_rune_spikes"
end
function modifier_arena_rune_spikes:GetEffectName()
	return "particles/items_fx/blademail.vpcf"
end
function modifier_arena_rune_spikes:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
function modifier_arena_rune_spikes:GetStatusEffectName()
	return "particles/status_fx/status_effect_blademail.vpcf"
end
function modifier_arena_rune_spikes:StatusEffectPriority()
	return 10
end
function modifier_arena_rune_spikes:DeclareFunctions()
	return {MODIFIER_EVENT_ON_TAKEDAMAGE, MODIFIER_PROPERTY_TOOLTIP}
end
if IsServer() then
	function modifier_arena_rune_spikes:OnTakeDamage(keys)
		local unit = self:GetParent()
		local inflictor = keys.inflictor
		if unit == keys.unit and unit:IsAlive() and (not IsValidEntity(inflictor) or not NOT_DAMAGE_REFRLECTABLE_ABILITIES[inflictor:GetAbilityName()]) then
			local ability = self:GetAbility()
			ApplyDamage({
				victim = keys.attacker,
				attacker = self:GetCaster(),
				damage = keys.original_damage * self:GetStackCount() * 0.01,
				damage_type = keys.damage_type,
				damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
				ability = ability
			})
		end
	end
else
	function modifier_arena_rune_spikes:OnTooltip()
		return self:GetStackCount()
	end
end