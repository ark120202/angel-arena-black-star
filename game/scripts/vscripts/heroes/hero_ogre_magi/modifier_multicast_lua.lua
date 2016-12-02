modifier_multicast_lua = class({})

function modifier_multicast_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
	}
    return funcs
end

function modifier_multicast_lua:OnAbilityExecuted(keys)
	if IsServer() and self:GetParent() == keys.unit then
		local ability_cast = keys.ability
		local caster = self:GetParent()
		local target = keys.target or caster:GetCursorPosition()
		local ability = self:GetAbility()
		local ogre_abilities = {
			"ogre_magi_bloodlust",
			"ogre_magi_fireblast",
			"ogre_magi_ignite",
			"ogre_magi_unrefined_fireblast"
		}
		if ability_cast and not ability_cast:IsItem() and not ability_cast:IsToggle() then
			if table.contains(ogre_abilities, ability_cast:GetName()) then
				local mc = caster:AddAbility("ogre_magi_multicast")
				mc:SetHidden(true)
				mc:SetLevel(ability:GetLevel())
				Timers:CreateTimer(0.01, function()
					caster:RemoveAbility("ogre_magi_multicast")
				end)
			else
				local multicast
				local pct_4 = ability:GetSpecialValueFor("multicast_4_times")
				local pct_3 = ability:GetSpecialValueFor("multicast_3_times")
				local pct_2 = ability:GetSpecialValueFor("multicast_2_times")
				if IsUltimateAbility(ability_cast) then
					pct_4 = pct_4 / 2
					pct_3 = pct_3 / 2
					pct_2 = pct_2 / 2
				end
				if RollPercentage(pct_4) then
					multicast = 4
				elseif RollPercentage(pct_3) then
					multicast = 3
				elseif RollPercentage(pct_2) then	
					multicast = 2
				end
				if ability_cast ~= nil and multicast then
					PreformMulticast(caster, ability_cast, multicast, ability:GetSpecialValueFor( "multicast_delay"), target)
				end	
			end
		end
	end
end

function modifier_multicast_lua:GetEffectName()
	return "particles/arena/units/heroes/hero_ogre_magi/multicast_aghanims_buff.vpcf"
end

function modifier_multicast_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end