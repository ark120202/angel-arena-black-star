require("items/item_refresher")

function OnDealDamage(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	if RollPercentage(ability:GetLevelSpecialValueFor("bash_chance", ability:GetLevel() - 1)) and not caster:HasModifier("modifier_item_refresher_core_bash_cooldown") then
		target:AddNewModifier(caster, ability, "modifier_stunned", {duration = ability:GetLevelSpecialValueFor("bash_duration", ability:GetLevel() - 1)})
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_refresher_core_bash_cooldown", {})
	end
end
