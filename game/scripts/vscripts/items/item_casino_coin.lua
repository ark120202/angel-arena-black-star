function CasinoCoinSlotMachine(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local playerID = caster:GetPlayerID()
	local Random = {RandomInt(0, 7), RandomInt(0, 7), RandomInt(0, 7)}
	if target:GetUnitName() == "npc_dota_casino_slotmachine" then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_slotmachine_in_work", {})
		Timers:CreateTimer(1, function()
			Notifications:Bottom(playerID, {text="#casino_slotmachine_roll_start", style={color="limegreen"}, duration=10})
			PlayMulticastSound(target)
			local i = 0
			Timers:CreateTimer(2, function()
				i = i + 1
				PlayMulticastSound(target, i)
				local color = CASINO_COLORTABLE[Random[i] + 1]
				local num = Random[i] .. "" -- Без этого "No Text provided"
				Notifications:Bottom(playerID, {text=num, style={color=color}, continue=true})
				if i < 3 then
					return 2
				else
					local won = false
					if Random[1] == 3 and Random[2] == 2 and Random[3] == 2 then
						Notifications:Top(playerID, {text="#casino_slotmachine_roll_result_streak322", style={color="red"}, duration = 10})
						local addgold = GetFilteredGold(15000)
						local g1,g2 = CreateGoldNotificationSettings(addgold)
						Notifications:Top(playerID, g1)
						Notifications:Top(playerID, g2)
						local enemies = GetEnemiesIds(caster:GetTeamNumber())
						for _,id in ipairs(enemies) do
							Gold:ModifyGold(id, addgold)
							Notifications:Top(id, {text="#casino_slotmachine_roll_result_streak322_enemies_p1", style={color="red"}, duration = 10})
							local g1,g2 = CreateGoldNotificationSettings(addgold)
							Notifications:Top(id, g1)
							Notifications:Top(id, g2)
							Notifications:Top(id, {text="#casino_slotmachine_roll_result_streak322_enemies_p2", style={color="red"}, duration = 10})
							Notifications:Top(id, CreateHeroNameNotificationSettings(caster, caster:GetTeamNumber(), 10))
							Notifications:Top(id, {text="#casino_slotmachine_roll_result_streak322_enemies_p3", style={color="red"}, duration = 10})
						end
					else
						for i = 0, 7 do
							if table.allEqual(Random, i) then
								if i == 0 then --000
									Notifications:Top(playerID, {text="#casino_slotmachine_roll_result_streak000", style={color=color}, duration = 10})
									Gold:ClearGold(playerID)
									for n = 0,5 do
										local item = caster:GetItemInSlot(n)
										if item then
											item:RemoveSelf()
										end
									end
								elseif i == 7 then --777
									Notifications:Top(playerID, {text="#casino_slotmachine_roll_result_streak777", style={color=color}, duration = 10})
									Gold:ModifyGold(caster, GetFilteredGold(250000))
									Gold:ModifyGold(caster, GetFilteredGold(250000))
								else --***
									Notifications:Top(playerID, {text="#casino_slotmachine_roll_result_streakxxx", style={color=color}, duration = 10})
									local g1,g2 = CreateGoldNotificationSettings(GetFilteredGold(i*11111))
									Notifications:Top(playerID, g1)
									Notifications:Top(playerID, g2)
									Gold:ModifyGold(caster, GetFilteredGold(i*11111))
								end
								won = true
								break
							elseif table.allEqualExpectOne(Random, i) then
								if i == 0 then --00*
									Notifications:Top(playerID, {text="#casino_slotmachine_roll_result_streak00", style={color=color}, duration = 10})
									local g1,g2 = CreateGoldNotificationSettings(GetFilteredGold(10000))
									Notifications:Top(playerID, g1)
									Notifications:Top(playerID, g2)
									Gold:ModifyGold(caster, GetFilteredGold(-10000))
								else --xx*
									Notifications:Top(playerID, {text="#casino_slotmachine_roll_result_streakxx", style={color=color}, duration = 10})
									local g1,g2 = CreateGoldNotificationSettings(GetFilteredGold(i*1000))
									Notifications:Top(playerID, g1)
									Notifications:Top(playerID, g2)
									Gold:ModifyGold(caster, GetFilteredGold(i*1000))
								end
								won = true
								break
							end
						end
						if not won then
							Notifications:Top(playerID, {text="#casino_slotmachine_roll_result_streak_no", duration = 10})
						end
						target:RemoveModifierByNameAndCaster("modifier_slotmachine_in_work", caster)
					end
				end
			end)
		end)
	elseif target:GetUnitName() == "npc_dota_casino_lina" and ability:GetCurrentCharges() >= 2 then
		ability:SetCurrentCharges(ability:GetCurrentCharges() - 1)
		target.Inactive = true
		target:DestroyAllSpeechBubbles()
		target.HasSpeechBubble = false
		ability:ApplyDataDrivenModifier(caster, target, "modifier_slotmachine_in_work", {})
		StartAnimation(target, {duration=2.5, activity=ACT_DOTA_RUN})
		Timers:CreateTimer(2.5, function()
			for _,v in ipairs(CosmeticLib:GetAvailableSlotForHero("npc_dota_hero_lina")) do
				if v ~= "head" then
					CosmeticLib:RemoveFromSlot( target, v )
				end
			end
			--StartAnimation(target, {duration=2.5, activity=ACT_DOTA_RUN})
			local lap1 = 0
			Timers:CreateTimer(2.5, function()
				Timers:CreateTimer(0, function()
					lap1 = lap1 + 1
					if lap1 <= 4 then
						StartAnimation(target, {duration=1.7, activity=ACT_DOTA_ATTACK})
						return 1.7
					else
						local lap2 = 0
						Timers:CreateTimer(0, function()
							lap2 = lap2 + 1
							if lap2 <= 6 then
								StartAnimation(target, {duration=1.1, activity=ACT_DOTA_CAST_ABILITY_1})
								return 1.1
							else
								Timers:CreateTimer(0, function()
									StartAnimation(target, {duration=7, activity=ACT_DOTA_FLAIL})
									Timers:CreateTimer(7, function()
										target:RemoveModifierByNameAndCaster("modifier_slotmachine_in_work", caster)
										CosmeticLib:EquipSet( target, "npc_dota_hero_lina", 20769 )
										target.Inactive = false
										target:GetAbilityByIndex(0):ApplyDataDrivenModifier(target, caster, "modifier_casino_bitch_lina_effect", {duration=300})
										local heroes = FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, target:GetAbilityByIndex(0):GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
										if #heroes > 0 and not caster.Inactive then
											BShowBubble(target)
										end
									end)
								end)
							end
						end)
					end
				end)
			end)
		end)
	else
		ability:RefundManaCost()
		ability:EndCooldown()
		ability:SetCurrentCharges(ability:GetCurrentCharges() + 1)
	end
end

function PlayMulticastSound(unit, index)
	local i = index
	if not i then
		i = RandomInt(1, 3)
	end
	local sound = "Hero_OgreMagi.Fireblast.x" .. i
	EmitSoundOn(sound, unit)
end