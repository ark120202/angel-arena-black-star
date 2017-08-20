function GoToThePocket(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target

	if target ~= caster and target:UnitHasSlotForItem("item_pocket_riki", false) and target:IsMainHero() then
		local item = CreateItem("item_pocket_riki", target, target)
		item.RikiContainer = caster
		target:AddItem(item)
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_pocket_riki_hide", {})
		caster:SetAbsOrigin(target:GetAbsOrigin())
		caster.PocketHostEntity = target
		caster.PocketItem = item
	else
		ability:RefundManaCost()
		ability:EndCooldown()
	end
end

function MoveUnit(keys)
	keys.caster:SetAbsOrigin(keys.caster.PocketHostEntity:GetAbsOrigin())
end

function HideUnit(keys)
	local caster = keys.caster
	caster:AddNoDraw()
	for i = 0, caster:GetAbilityCount()-1 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and ability:GetAbilityName() ~= "riki_smoke_screen" then
			ability:SetActivated(false)
		end
	end
end

function ShowUnit(keys)
	local caster = keys.caster
	local ability = keys.ability
	caster:RemoveNoDraw()
	for i = 0, caster:GetAbilityCount()-1 do
		local ability = caster:GetAbilityByIndex(i)
		if ability and ability:GetAbilityName() ~= "riki_smoke_screen" then
			ability:SetActivated(true)
		end
	end
	caster.PocketHostEntity = nil
	caster.PocketItem = nil
end
