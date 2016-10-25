function SpendChargeRight(keys)
	SpendCharge(keys.ability, 1)
end

function SetMaxLevel(keys)
	local ability = keys.ability
	ability:SetLevel(ability:GetMaxLevel())
end

function HideCaster(keys)
	keys.caster:AddNoDraw()
end

function ShowCaster(keys)
	keys.caster:RemoveNoDraw()
end

function HideTarget(keys)
	local target = keys.target or keys.caster
	target:AddNoDraw()
end

function ShowTarget(keys)
	local target = keys.target or keys.caster
	target:RemoveNoDraw()
end

function SetFirstLevel(keys)
	keys.ability:SetLevel(1)
end

function DropItem(keys)
	local caster = keys.caster
	if not caster:IsIllusion() and not caster:HasModifier("modifier_arc_warden_tempest_double") then
		caster:DropItemAtPositionImmediate(keys.ability, caster:GetAbsOrigin())
	end
end

function StopEndableSound(keys)
	local target = keys.target or keys.caster
	if keys.modifier then
		local canDestroy = true
		for i in string.gmatch(keys.modifier, "%S+") do
			if target:HasModifier(i) then
				canDestroy = false
			end
		end
		if canDestroy then
			keys.target:StopSound(keys.sound)
		end
	else
		keys.target:StopSound(keys.sound)
	end
end

function MeepoCleaner(keys)
	if keys.modifier and keys.caster.OwnerMeepo then
		keys.caster:RemoveModifierByName(keys.modifier)
	end
end

function SwapToItem(keys)
	local caster = keys.caster
	local ability = keys.ability
	local itemName = keys.itemName
	if itemName then
		local newItem = CreateItem(itemName, caster, caster)
		newItem:SetPurchaseTime(ability:GetPurchaseTime())
		newItem:SetPurchaser(ability:GetPurchaser())
		newItem:SetOwner(ability:GetOwner())
		swap_to_item(caster, ability, newItem)
	end
end

function IllusionModifierCleaner(keys)
	Timers:CreateTimer(0.03, function()
		if keys.modifier and keys.caster:IsIllusion() then
			keys.caster:RemoveModifierByName(keys.modifier)
		end
	end)
end

function ReplaceAbilityWith(keys)
	local caster = keys.caster
	local ability = keys.ability
	if keys.new then
		ReplaceAbilities(caster, ability:GetAbilityName(), keys.new, true, false)
	end
end

function LinkedAbilitiesSync(keys)
	local caster = keys.caster
	local ability = keys.ability
	local linked_ability = caster:FindAbilityByName(keys.linked_ability)
	if linked_ability then
		if linked_ability:GetLevel() > ability:GetLevel() then
			ability:SetLevel(linked_ability:GetLevel())
		elseif linked_ability:GetLevel() < ability:GetLevel() then
			linked_ability:SetLevel(ability:GetLevel())
		end
	end
end

function KillTarget(keys)
	if keys.target:IsAlive() then
		TrueKill(keys.caster, keys.ability, keys.target)
	end
end

function UpgradeChargeBasedAbility(keys)
	local caster = keys.caster
	local ability = keys.ability
	local max_charges = keys.max_charges
	if keys.max_charges_scepter and caster:HasScepter() then
		max_charges = keys.max_charges_scepter
	end
	local modifiers = caster:FindAllModifiersByName("modifier_charges")
	if #modifiers == 0 then
		caster:AddNewModifier(caster, ability, "modifier_charges", {
			max_count = max_charges,
			start_count = max_charges,
			replenish_time = keys.charge_replenish_time
		})
	else
		for _,v in ipairs(modifiers) do
			if v:GetAbility() == ability then
				v.kv.replenish_time = keys.charge_replenish_time
				v:SetMaxStackCount(max_charges)
			end
		end
	end
end