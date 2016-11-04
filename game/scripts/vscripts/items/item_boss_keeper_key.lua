function OnEquip(keys)
	local caster = keys.caster
	Timers:CreateTimer(function()
		if caster:IsRealHero() then
			local ability = keys.ability
			if not ability.notified then
				Notifications:TopToAll({hero=caster:GetName(), duration=7.0})
				Notifications:TopToAll(CreateHeroNameNotificationSettings(caster, 7.0))
				Notifications:TopToAll({text= "#item_boss_keeper_key_equip_notify_p1", duration=7.0, continue=true}) --info
				Notifications:TopToAll(CreateItemNotificationSettings(ability:GetName()))
				Notifications:TopToAll({text= "#item_boss_keeper_key_equip_notify_p2", duration=7.0, continue=true})
				ability.notified = true
			else
				Notifications:TopToAll({hero=caster:GetName(), duration=7.0})
				Notifications:TopToAll(CreateHeroNameNotificationSettings(caster, 7.0))
				Notifications:TopToAll({text= "#item_boss_keeper_key_equip_notify_p3", duration=7.0, continue=true})
				Notifications:TopToAll(CreateItemNotificationSettings(ability:GetName()))
				Notifications:TopToAll({text= "#item_boss_keeper_key_equip_notify_p4", duration=7.0, continue=true})
				Notifications:TopToAll({hero=ability.Owner:GetName(), duration=7.0, continue=true})
				Notifications:TopToAll(CreateHeroNameNotificationSettings(ability.Owner, 7.0))
			end
			ability.Owner = caster
		end
	end)
end

function OnSpellStart(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	ability.elapsed = 0
	if target:GetName() == "npc_dota_boss_keeper" and not target:HasModifier("modifier_boss_keeper_opened") then
		ability.RealTarget = target
		Timers:CreateTimer(0, function()
			ability.elapsed = ability.elapsed + 0.1
			if not ability:IsNull() then
				return 0.1
			end
		end)
	else
		ability:RefundManaCost()
		ability:EndCooldown()
		ability.FakeCast = true
		ability:Interrupt()
	end
end

function OnChannelInterrupted(keys)
	local ability = keys.ability
	local caster = keys.caster
	if ability.FakeCast then
		ability.FakeCast = nil
	else
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_boss_keeper_key_broken", {duration = ability:GetSpecialValueFor("cast_duration") - ability.elapsed})
		caster:RemoveItem(ability)
	end
end

function OnChannelSucceeded(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = ability.RealTarget
	caster:RemoveItem(ability)
	local abs = target:GetAbsOrigin()
	target:GetAbilityByIndex(0):ApplyDataDrivenModifier(target, target, "modifier_boss_keeper_opened", {})
	Timers:CreateTimer(0.2, function()
		caster:Stop()
		PlayerResource:SetCameraTarget(caster:GetPlayerOwnerID(), caster)
		FindClearSpaceForUnit(caster, Entities:FindByName(nil, "target_mark_bosses_thome_team" .. caster:GetTeamNumber()):GetAbsOrigin(), true)
		Timers:CreateTimer(0.1, function()
			PlayerResource:SetCameraTarget(caster:GetPlayerOwnerID(), nil)
			caster:Stop()
		end)
	end)
	Timers:CreateTimer(1, function()
		ScreenShake(target:GetAbsOrigin(), 5, 5, 0.0125, 400, 1, true)
		target:SetAbsOrigin(target:GetAbsOrigin()-Vector(0, 0, 1))
		local length = (abs - target:GetAbsOrigin()):Length()
		if length >= 256 then
			Bosses:OpenPortals(caster:GetTeamNumber())
			Bosses.KeyDroppableFromCreeps = false
			Notifications:TopToAll({text="#bosses_keeper_activated_p1", duration=9})
			Notifications:TopToAll(CreateTeamNotificationSettings(caster:GetTeamNumber(), 9, true))
		else
			return 0.0125
		end
	end)
end

function OnIntervalThink(keys)
	local ability = keys.ability
	local caster = keys.caster
	local target = ability.RealTarget
	EmitSoundOn("Item.MoonShard.Consume", target)
	Timers:CreateTimer(0.5, function()
		EmitSoundOn("DOTA_Item.AbyssalBlade.Activate", target)
		ParticleManager:CreateParticle("particles/items_fx/abyssal_blade.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
	end)
end