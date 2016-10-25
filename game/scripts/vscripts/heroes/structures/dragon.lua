function ShowBubble(keys)
	local caster = keys.caster
	if not caster.HasSpeechBubble and not caster.Inactive then
		caster:AddSpeechBubble(1, "#dragon_bubble_text", 9999999, 0, 0)
		caster.HasSpeechBubble = true
	end
end

function DestroyBubble(keys)
	local caster = keys.caster
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, keys.ability:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	if #heroes < 1 and not caster.Inactive then
		caster:DestroyAllSpeechBubbles()
		caster.HasSpeechBubble = false
	end
end

function InitTimers(keys)
	local ability = keys.ability
	local caster = keys.caster
	Timers:CreateTimer(1.0, function()
		local heroes = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, ability:GetSpecialValueFor("radius_of_cast"), DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
		for _,target in ipairs(heroes) do
			if not caster.Inactive and target:IsRealHero() then
				if target:GetModifierStackCount("modifier_dragon_burnriver_gold_effect", caster) >= 10 then
					if target:GetGold() >= THINGS_SETTINGS.GoldCost then
						target:SpendGold(THINGS_SETTINGS.GoldCost, 0)
						local abs1 = caster:GetAbsOrigin()
						caster.Inactive = true
						caster:DestroyAllSpeechBubbles()
						Timers:CreateTimer(1, function()
							ScreenShake(caster:GetAbsOrigin(), 5, 5, 0.0125, 400, 1, true)
							caster:SetAbsOrigin(caster:GetAbsOrigin()-Vector(0, 0, 1))
							local length = (abs1 - caster:GetAbsOrigin()):Length()
							if length >= 128 then
								pcall(BurnRiver)
								Notifications:TopToAll({text="#dragon_burned_river", duration=9, style={color="OrangeRed"}})
								Timers:CreateTimer(THINGS_SETTINGS.BurnRiverTime, function()
									UnburnRiver()
									local abs2 = caster:GetAbsOrigin()
									Timers:CreateTimer(THINGS_SETTINGS.BurnCooldown + 1, function()
										local length = (abs2 - caster:GetAbsOrigin()):Length()
										if length >= 128 then
											caster.Inactive = false
										else
											return 0.0125
										end
									end)
								end)
							else
								return 0.0125
							end
						end)
					end
				elseif target:GetGold() >= THINGS_SETTINGS.GoldCost then
					ModifyStacks(ability, caster, target, "modifier_dragon_burnriver_gold_effect", 1, true)
				end
			end
		end
		if caster:IsAlive() then
			return 1.0
		end
	end)
end

function BurnRiver()
	_G.IS_RIVER_BURNED = true
	if not THINGS_SETTINGS.PfxContainer then THINGS_SETTINGS.PfxContainer = {} end
	for _,v in ipairs(Heroes_In_BurnedRiver_Zone) do
		v:Kill(nil, nil)
	end
	for i = 1, 35 - 1 do
		if i ~= 20 then
			local startPos = Entities:FindByName(nil, "target_mark_dragon_p" .. i):GetAbsOrigin()
			local endPos = Entities:FindByName(nil, "target_mark_dragon_p" .. i + 1):GetAbsOrigin()
			local particleName = "particles/units/heroes/hero_jakiro/jakiro_macropyre.vpcf"
			local pfx = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN, GLOBAL_VISIBLE_ENTITY)
			ParticleManager:SetParticleControl( pfx, 0, startPos )
			ParticleManager:SetParticleControl( pfx, 1, endPos )
			ParticleManager:SetParticleControl( pfx, 2, Vector( THINGS_SETTINGS.BurnRiverTime, 0, 0 ) )
			ParticleManager:SetParticleControl( pfx, 3, startPos )
			table.insert(THINGS_SETTINGS.PfxContainer, pfx)
		end
	end
end

function UnburnRiver()
	_G.IS_RIVER_BURNED = false
	if THINGS_SETTINGS.PfxContainer then
		for _,v in ipairs(THINGS_SETTINGS.PfxContainer) do
			ParticleManager:DestroyParticle(v, false)
		end
	end
end