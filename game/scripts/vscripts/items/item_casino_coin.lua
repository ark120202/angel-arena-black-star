function CasinoCoinSlotMachine(keys)
	local caster = keys.caster
	local ability = keys.ability
	local target = keys.target
	local playerId = caster:GetPlayerID()
	local Random = {RandomInt(0, 7), RandomInt(0, 7), RandomInt(0, 7)}
	if target:GetUnitName() == "npc_dota_casino_slotmachine" then
		ability:ApplyDataDrivenModifier(caster, target, "modifier_slotmachine_in_work", {})
		Timers:CreateTimer(1, function()
			Notifications:Bottom(playerId, {text="#casino_slotmachine_roll_start", style={color="limegreen"}, duration=10})
			PlayMulticastSound(target)
			local i = 0
			Timers:CreateTimer(2, function()
				i = i + 1
				PlayMulticastSound(target, i)
				local color = CASINO_COLORTABLE[Random[i] + 1]
				local num = Random[i] .. "" -- Без этого "No Text provided"
				Notifications:Bottom(playerId, {text=num, style={color=color}, continue=true})
				if i < 3 then
					return 2
				else
					local won = false
					if Random[1] == 3 and Random[2] == 2 and Random[3] == 2 then
						Notifications:Top(playerId, {text="#casino_slotmachine_roll_result_streak322", style={color="red"}, duration = 10})
						local addgold = 15000
						local g1,g2 = CreateGoldNotificationSettings(addgold)
						Notifications:Top(playerId, g1)
						Notifications:Top(playerId, g2)
						local enemies = GetEnemiesIds(caster:GetTeamNumber())
						for _,id in ipairs(enemies) do
							Gold:ModifyGold(id, addgold)
							Notifications:Top(id, {text="#casino_slotmachine_roll_result_streak322_enemies_p1", style={color="red"}, duration = 10})
							local g1,g2 = CreateGoldNotificationSettings(addgold)
							Notifications:Top(id, g1)
							Notifications:Top(id, g2)
							Notifications:Top(id, {text="#casino_slotmachine_roll_result_streak322_enemies_p2", style={color="red"}, duration = 10})
							Notifications:Top(id, CreateHeroNameNotificationSettings(caster, caster:GetTeamNumber(), 10))
							Notifications:Top(id, {text=PlayerResource:GetPlayerName(playerId), continue=true, style={color=ColorTableToCss(PLAYER_DATA[playerId].Color or {0, 0, 0})}})
							Notifications:Top(id, {text="#casino_slotmachine_roll_result_streak322_enemies_p3", style={color="red"}, duration = 10})
						end
					else
						for i = 0, 7 do
							if table.allEqual(Random, i) then
								if i == 0 then --000
									Notifications:Top(playerId, {text="#casino_slotmachine_roll_result_streak000", style={color=color}, duration = 10})
									Gold:ClearGold(playerId)
									for n = 0,5 do
										local item = caster:GetItemInSlot(n)
										if item then
											item:RemoveSelf()
										end
									end
								elseif i == 7 then --777
									Notifications:Top(playerId, {text="#casino_slotmachine_roll_result_streak777", style={color=color}, duration = 10})
									Gold:ModifyGold(caster, 250000)
									Gold:ModifyGold(caster, 250000)
								else --***
									Notifications:Top(playerId, {text="#casino_slotmachine_roll_result_streakxxx", style={color=color}, duration = 10})
									local g1,g2 = CreateGoldNotificationSettings(i*11111)
									Notifications:Top(playerId, g1)
									Notifications:Top(playerId, g2)
									Gold:ModifyGold(caster, i*11111)
								end
								won = true
								break
							elseif table.allEqualExpectOne(Random, i) then
								if i == 0 then --00*
									Notifications:Top(playerId, {text="#casino_slotmachine_roll_result_streak00", style={color=color}, duration = 10})
									local g1,g2 = CreateGoldNotificationSettings(10000)
									Notifications:Top(playerId, g1)
									Notifications:Top(playerId, g2)
									Gold:ModifyGold(caster, -10000)
								else --xx*
									Notifications:Top(playerId, {text="#casino_slotmachine_roll_result_streakxx", style={color=color}, duration = 10})
									local g1,g2 = CreateGoldNotificationSettings(i*1000)
									Notifications:Top(playerId, g1)
									Notifications:Top(playerId, g2)
									Gold:ModifyGold(caster, i*1000)
								end
								won = true
								break
							end
						end
						if not won then
							Notifications:Top(playerId, {text="#casino_slotmachine_roll_result_streak_no", duration = 10})
						end
						target:RemoveModifierByNameAndCaster("modifier_slotmachine_in_work", caster)
					end
				end
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
