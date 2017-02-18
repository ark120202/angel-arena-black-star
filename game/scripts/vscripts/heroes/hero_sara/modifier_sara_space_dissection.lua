modifier_sara_space_dissection = class({})

function modifier_sara_space_dissection:IsHidden()
	return true
end

function modifier_sara_space_dissection:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

if IsServer() then
	function modifier_sara_space_dissection:OnAttackLanded(keys)
		local parent = self:GetParent()
		if keys.attacker == parent and parent.GetEnergy then
			local ability = self:GetAbility()
			local unit = keys.target
			if PreformAbilityPrecastActions(parent, ability) then
				if (unit:IsConsideredHero() or unit:IsBoss()) and not unit:IsIllusion() then
					local energy = parent:GetEnergy()
					local cost = parent:GetMaxEnergy() * ability:GetSpecialValueFor("energy_pct") * 0.01
					if energy >= cost then
						local duration = ability:GetSpecialValueFor("disarmor_duration")
						local modifier = unit:AddNewModifier(parent, ability, "modifier_sara_space_dissection_armor_reduction", {duration = duration})
						local stacks = math.round(energy * ability:GetSpecialValueFor("energy_to_disarmor_pct") * 0.01)
						modifier:SetStackCount(modifier:GetStackCount() + stacks)
						if not parent:HasScepter() then
							Timers:CreateTimer(duration, function()
								if modifier and not modifier:IsNull() then
									modifier:SetStackCount(modifier:GetStackCount() - stacks)
									--[[if modifier:GetStackCount() <= 0 then
										modifier:Destroy()
									end]]
								end
							end)
						end
						parent:ModifyEnergy(cost)
					end
				elseif unit:IsRealCreep() then
					unit.SpaceDissectionMultiplier = ability:GetSpecialValueFor("creep_energy_multiplier")
					if not parent:HasScepter() then
						unit:SetDeathXP(0)
						unit:SetMinimumGoldBounty(0)
						unit:SetMaximumGoldBounty(0)
					end
					unit:Kill(ability, parent)
				end
			end
		end
	end
end

modifier_sara_space_dissection_armor_reduction = class({})

function modifier_sara_space_dissection_armor_reduction:IsPurgable()
	return false
end

function modifier_sara_space_dissection_armor_reduction:DeclareFunctions()
	return {MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS}
end

function modifier_sara_space_dissection_armor_reduction:GetModifierPhysicalArmorBonus()
	return -self:GetStackCount()
end