function RefreshAbility(keys)
	local caster = keys.caster
	local event_ability = keys.event_ability
	if event_ability and not event_ability:IsItem() and not IsUltimateAbility(event_ability) then
		Timers:CreateTimer(function()
			event_ability:EndCooldown()
			caster:EmitSound("DOTA_Item.Refresher.Activate")
			ParticleManager:SetParticleControlEnt(ParticleManager:CreateParticle("particles/arena/items_fx/coffee_bean_refresh.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster), 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
		end)
		caster:RemoveModifierByName("modifier_item_coffee_bean")
	end
end