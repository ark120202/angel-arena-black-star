local ignoredAbilities = {
	zuus_cloud = true,
	monkey_king_boundless_strike = true,
	dazzle_shallow_grave = true,
	saitama_push_ups = true,
	saitama_squats = true,
	saitama_sit_ups = true,
}

function RefreshAbility(keys)
	local caster = keys.caster
	local event_ability = keys.event_ability
	if event_ability and
		not event_ability:IsItem() and
		not IsUltimateAbility(event_ability) and
		not ignoredAbilities[event_ability:GetAbilityName()] then
		caster:RemoveModifierByName("modifier_item_coffee_bean")
		Timers:NextTick(function()
			event_ability:EndCooldown()
			caster:EmitSound("DOTA_Item.Refresher.Activate")
			ParticleManager:SetParticleControlEnt(ParticleManager:CreateParticle("particles/arena/items_fx/coffee_bean_refresh.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster), 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		end)
	end
end
