function Refresh(keys)
	local caster = keys.caster
	local ability = keys.ability
	if not caster:HasModifier("modifier_arc_warden_tempest_double") then
		RefreshAbilities(caster, REFRESH_LIST_IGNORE_REFRESHER)
		RefreshItems(caster, REFRESH_LIST_IGNORE_REFRESHER)
		caster:EmitSound("DOTA_Item.Refresher.Activate")
		ParticleManager:SetParticleControlEnt(ParticleManager:CreateParticle("particles/items2_fx/refresher.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster), 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		ability:StartCooldown(math.min(math.max(table.highest(GetAllAbilitiesCooldowns(caster)), ability:GetSpecialValueFor("cooldown_min")), ability:GetSpecialValueFor("cooldown_max")))
	end
end