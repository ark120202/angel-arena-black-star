function Refresh(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:IsTempestDouble() then
		RefreshAbilities(caster, REFRESH_LIST_IGNORE_REFRESHER)
		RefreshItems(caster, REFRESH_LIST_IGNORE_REFRESHER)
		caster:EmitSound("DOTA_Item.Refresher.Activate")
		ParticleManager:SetParticleControlEnt(ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster), 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ability:StartCooldown(math.min(math.max(table.highest(GetAllAbilitiesCooldowns(caster)), ability:GetSpecialValueFor("cooldown_min")), ability:GetSpecialValueFor("cooldown_max")))
	end
end

function OnDealDamage(keys)
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	if RollPercentage(ability:GetLevelSpecialValueFor("bash_chance", ability:GetLevel() - 1)) and not caster:HasModifier("modifier_item_refresher_core_bash_cooldown") then
		target:AddNewModifier(caster, ability, "modifier_stunned", {duration = ability:GetLevelSpecialValueFor("bash_duration", ability:GetLevel() - 1)})
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_refresher_core_bash_cooldown", {})
	end
end