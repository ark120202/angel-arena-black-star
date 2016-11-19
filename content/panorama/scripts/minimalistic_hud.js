"use strict";
var PlayerTables = GameUI.CustomUIConfig().PlayerTables;
var m_AbilityPanels = [];
var m_BuffPanels = [];
var CustomHudEnabled = false;
var m_BuffPanelsClickPurgable = [];

function OnLevelUpClicked() {
	if (Game.IsInAbilityLearnMode()) {
		Game.EndAbilityLearnMode();
	} else {
		Game.EnterAbilityLearnMode();
	}
}

function UpdatePanels() {
	var unit = Players.GetLocalPlayerPortraitUnit()

	var nBuffs = Entities.GetNumBuffs(unit);
	var nUsedPanels = 0;
	var nUsedPanelsClickPurgable = 0;
	for (var i = 0; i < nBuffs; ++i) {
		var buffSerial = Entities.GetBuff(unit, i);
		if (buffSerial != -1) {
			if (!Buffs.IsHidden(unit, buffSerial)) {
				if (CustomHudEnabled) {
					if (nUsedPanels >= m_BuffPanels.length) {
						var buffPanel = CreateSnippet_Buff($.CreatePanel("Panel", $("#BuffsPanel"), ""))
						m_BuffPanels.push(buffPanel);
					}
					var buffPanel = m_BuffPanels[nUsedPanels];
					buffPanel.SetBuff(buffSerial, unit);
					nUsedPanels++;
				}
			} else if (Buffs.GetName(unit, buffSerial) == "modifier_rubick_personality_steal") {
				if (nUsedPanelsClickPurgable >= m_BuffPanelsClickPurgable.length) {
					var buffPanel = CreateSnippet_Buff($.CreatePanel("Panel", $("#ClickPurgableModifiersOverlay"), ""))
					m_BuffPanelsClickPurgable.push(buffPanel);
				}
				var buffPanel = m_BuffPanelsClickPurgable[nUsedPanelsClickPurgable];
				buffPanel.SetBuff(buffSerial, unit);
				nUsedPanelsClickPurgable++;
			}
		}
	}
	for (var i = nUsedPanelsClickPurgable; i < m_BuffPanelsClickPurgable.length; ++i) {
		var buffPanel = m_BuffPanelsClickPurgable[i];
		buffPanel.SetBuff(-1, -1);
	}

	if (CustomHudEnabled) {
		for (var i = nUsedPanels; i < m_BuffPanels.length; ++i) {
			var buffPanel = m_BuffPanels[i];
			buffPanel.SetBuff(-1, -1);
		}
		$("#HPBar_LabelConst").text = Entities.GetHealth(unit) + "/" + Entities.GetMaxHealth(unit)
		$("#HPBar_LabelRegen").text = " + " + Entities.GetHealthThinkRegen(unit).toFixed(1)
		$("#HPBar_Progress").value = Entities.GetHealthPercent(unit)
		$("#ManaBar_LabelConst").text = Entities.GetMana(unit) + "/" + Entities.GetMaxMana(unit)
		$("#ManaBar_LabelRegen").text = " + " + Entities.GetManaThinkRegen(unit).toFixed(1)
		var XpTable = PlayerTables.GetTableValue("arena", "gamemode_settings")["xp_table"]
		var xpOverflow = 0
		if (XpTable != null && XpTable[Entities.GetLevel(unit)] != null)
			xpOverflow = XpTable[Entities.GetLevel(unit)]
		if (Entities.GetNeededXPToLevel(unit) > 0) {
			var current = Entities.GetCurrentXP(unit) - xpOverflow
			var need = Entities.GetNeededXPToLevel(unit) - xpOverflow
			$("#HeroNextLevelLabel").text = current + "/" + need
			$("#HeroNextLevel").value = current / need * 100
		} else {
			$("#HeroNextLevelLabel").text = ""
			$("#HeroNextLevel").value = $("#HeroNextLevel").max
		}
		if (Entities.GetMana(unit) >= Entities.GetMaxMana(unit))
			$("#ManaBar_Progress").value = $("#ManaBar_Progress").max
		else
			$("#ManaBar_Progress").value = (Entities.GetMana(unit) / Entities.GetMaxMana(unit)) * 100

		$("#DotaAttributeValue_damage").text = (Entities.GetDamageMin(unit) + ((Entities.GetDamageMax(unit) - Entities.GetDamageMin(unit)) / 2)).toFixed(0)
		if (Entities.GetDamageBonus(unit) > 0) {
			$("#DotaAttributeValue_damage_bonus").style.visibility = "visible"
			$("#DotaAttributeValue_damage_bonus").text = Entities.GetDamageBonus(unit)
			$("#DotaAttributeValue_damage").text = $("#DotaAttributeValue_damage").text + " + "
		} else {
			$("#DotaAttributeValue_damage_bonus").style.visibility = "collapse"
		}

		$("#DotaAttributeValue_movespeed").text = Entities.GetMoveSpeedModifier(unit, Entities.GetBaseMoveSpeed(unit)).toFixed(0)
		$("#DotaAttributeValue_armor").text = Entities.GetArmorForDamageType(unit, DAMAGE_TYPES.DAMAGE_TYPE_PHYSICAL).toFixed(0) + " (" + Math.floor(Entities.GetArmorReductionForDamageType(unit, DAMAGE_TYPES.DAMAGE_TYPE_PHYSICAL) * 100) + "%)"
		$("#DotaAttributeValue_magic_resist").text = (Entities.GetArmorReductionForDamageType(unit, DAMAGE_TYPES.DAMAGE_TYPE_MAGICAL) * 100).toFixed(0) + "%"
		$("#DotaAttributeValue_attackspeed").text = Entities.GetSecondsPerAttack(unit).toFixed(2) + " (" + (Entities.GetIncreasedAttackSpeed(unit) * 100).toFixed(0) + ")"
		$("#DotaAttributeValue_range").text = Entities.GetAttackRange(unit)

		$.GetContextPanel().SetHasClass("HeroDead", !Entities.IsAlive(Players.GetLocalPlayerPortraitUnit()))

		var attribute_bonus_arena = Entities.GetAbilityByName(unit, "attribute_bonus_arena")
		$("#AttributePanelStackAttributes").hittest = Entities.GetAbilityPoints(unit) > 0 && (Game.IsInAbilityLearnMode() || GameUI.IsControlDown())
		$("#AttributePanelStackAttributes").SetHasClass("LearnableAttributes", Entities.GetAbilityPoints(unit) > 0)

		var courier = FindCourier(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()))
		if (courier != null) {
			var courier_burst = Entities.GetAbilityByName(courier, "courier_burst")
			var in_cooldown = !Abilities.IsCooldownReady(courier_burst)
			$("#CourierBurstCooldownPanel").SetHasClass("in_cooldown", in_cooldown);
			if (in_cooldown)
				$("#CourierBurstCooldownLabel").text = Abilities.GetCooldownTimeRemaining(courier_burst).toFixed(0)
		}
		$.GetContextPanel().SetHasClass("is_enemy", Entities.IsEnemy(unit))
	}

	if (Game.IsInAbilityLearnMode()) {
		if (Entities.GetAbilityPoints(unit) <= 0) {
			Game.EndAbilityLearnMode()
			UpdateAbilities()
		}
	}
	$("#GoldLabel").text = ""
	goldCheck:
		if (Players.GetTeam(Game.GetLocalPlayerID()) == Entities.GetTeamNumber(unit)) {
			var goldTable = PlayerTables.GetTableValue("arena", "gold")
			for (var i = 0; i < 23; i++) {
				if (Players.GetPlayerHeroEntityIndex(i) == unit) {
					if (goldTable && goldTable[i]) {
						$("#GoldLabel").text = goldTable[i]
						break goldCheck
					}
				}
			}
		}


}

function UpgradeAttributeBonus() {
	var unit = Players.GetLocalPlayerPortraitUnit()
	var attribute_bonus_arena = Entities.GetAbilityByName(unit, "attribute_bonus_arena")
	if (Entities.IsControllableByPlayer(unit, Game.GetLocalPlayerID()) && (Game.IsInAbilityLearnMode() || GameUI.IsControlDown())) {
		Abilities.AttemptToUpgrade(attribute_bonus_arena);
	}
}

function AutoUpdatePanels() {
	UpdatePanels()
	$.Schedule(0.1, AutoUpdatePanels)
}

function UpdateAbilities() {
	var unit = Players.GetLocalPlayerPortraitUnit()
	$.GetContextPanel().SetHasClass("could_level_up", (Entities.IsControllableByPlayer(unit, Game.GetLocalPlayerID()) && Entities.GetAbilityPoints(unit) > 0));
	$("#LevelUpButtonPoints").text = "+" + Entities.GetAbilityPoints(unit)

	var nUsedPanels = 0;
	for (var i = 0; i < Entities.GetAbilityCount(unit); ++i) {
		var ability = Entities.GetAbility(unit, i);
		if (ability != -1 && Abilities.IsDisplayedAbility(ability)) {
			if (nUsedPanels >= m_AbilityPanels.length) {
				var abilityPanel = CreateSnippet_Ability($.CreatePanel("Panel", $("#AbilitiesPanelInner"), ""));
				m_AbilityPanels.push(abilityPanel);
			}
			var abilityPanel = m_AbilityPanels[nUsedPanels];
			abilityPanel.SetAbility(ability, unit);
			nUsedPanels++;
		}
	}

	for (var i = nUsedPanels; i < m_AbilityPanels.length; ++i) {
		var abilityPanel = m_AbilityPanels[i];
		abilityPanel.SetAbility(-1, -1, false);
	}
}

function CreateSnippet_Ability(panel) {
	panel.BLoadLayoutSnippet("Ability")
	panel.SetAbility = function(ability, queryUnit) {
		panel.ability = ability
		panel.abilityName = Abilities.GetAbilityName(ability)
		panel.queryUnit = queryUnit
		panel.SetHasClass("no_ability", (ability == -1))
		panel.FindChildTraverse("AbilityImage").abilityname = panel.abilityName
		panel.FindChildTraverse("AbilityImage").contextEntityIndex = ability

		var abilityLevelContainer = panel.FindChildTraverse("AbilityLevelContainer");
		abilityLevelContainer.RemoveAndDeleteChildren();
		if (!Entities.IsEnemy(queryUnit)) {
			var currentLevel = Abilities.GetLevel(panel.ability);
			for (var lvl = 0; lvl < Abilities.GetMaxLevel(panel.ability); lvl++) {
				var levelPanel = $.CreatePanel("Panel", abilityLevelContainer, "");
				levelPanel.hittest = false
				levelPanel.AddClass("LevelPanel");
				levelPanel.SetHasClass("active_level", (lvl < currentLevel));
				levelPanel.SetHasClass("next_level", (lvl == currentLevel));
			}
		}
		panel.Update()
	}

	panel.RemoveAbility = function() {
		panel.Update = null
		panel.DeleteAsync(0)
	}
	panel.Update = function() {
		if (panel.ability != null && panel.ability > -1) {
			var noLevel = (0 == Abilities.GetLevel(panel.ability));
			var manaCost = Abilities.GetManaCost(panel.ability);
			panel.SetHasClass("no_level", noLevel || Entities.IsEnemy(panel.queryUnit));
			panel.SetHasClass("not_activated", !Abilities.IsActivated(panel.ability) && !Entities.IsEnemy(panel.queryUnit));
			panel.SetHasClass("is_passive", Abilities.IsPassive(panel.ability));
			panel.SetHasClass("is_passive_disabled", Abilities.IsPassive(panel.ability) && !Entities.IsEnemy(panel.queryUnit) && Entities.PassivesDisabled(panel.queryUnit));
			panel.SetHasClass("no_mana_cost", (0 == manaCost) || Entities.IsEnemy(panel.queryUnit));
			panel.SetHasClass("insufficient_mana", (manaCost > Entities.GetMana(panel.queryUnit)) && !Entities.IsEnemy(panel.queryUnit));
			panel.SetHasClass("auto_cast_enabled", Abilities.GetAutoCastState(panel.ability) && !Entities.IsEnemy(panel.queryUnit));
			panel.SetHasClass("toggle_enabled", Abilities.GetToggleState(panel.ability) && !Entities.IsEnemy(panel.queryUnit));
			panel.SetHasClass("is_active", (panel.ability == Abilities.GetLocalPlayerActiveAbility() || Abilities.GetChannelStartTime(panel.ability) > 0) || Abilities.IsInAbilityPhase(panel.ability)) && !Entities.IsEnemy(panel.queryUnit);
			panel.FindChildTraverse("ManaCost").text = manaCost
			panel.FindChildTraverse("HotkeyText").text = Abilities.GetKeybind(panel.ability, panel.queryUnit);
			panel.FindChildTraverse("AbilityButton").enabled = (!Abilities.IsPassive(panel.ability) && !noLevel || Game.IsInAbilityLearnMode() || GameUI.IsControlDown())
			if (!Entities.IsEnemy(panel.queryUnit)) {
				if (Abilities.IsCooldownReady(panel.ability)) {
					panel.SetHasClass("cooldown_ready", true);
					panel.SetHasClass("in_cooldown", false);
				} else {
					var cooldownLength = Abilities.GetCooldownLength(panel.ability);
					if (cooldownLength > 0) {
						panel.SetHasClass("cooldown_ready", false);
						panel.SetHasClass("in_cooldown", true);
						var cooldownRemaining = Abilities.GetCooldownTimeRemaining(panel.ability);
						var cooldownPercent = Math.ceil(100 * cooldownRemaining / cooldownLength);
						panel.FindChildTraverse("CooldownTimer").text = Math.ceil(cooldownRemaining);
						panel.FindChildTraverse("CooldownOverlay").style.width = cooldownPercent + "%";
					}
				}
			} else {
				panel.SetHasClass("cooldown_ready", true);
				panel.SetHasClass("in_cooldown", false);
			}

			var canUpgrade = (Abilities.CanAbilityBeUpgraded(panel.ability) == AbilityLearnResult_t.ABILITY_CAN_BE_UPGRADED)
			panel.SetHasClass("learnable_ability", Game.IsInAbilityLearnMode() && canUpgrade && GameUI.CustomUIConfig().DOTA_ACTIVE_GAMEMODE_TYPE != DOTA_GAMEMODE_TYPE_ABILITY_SHOP)
		}
	}
	panel.AutoUpdate = function() {
		if (panel.Update == null)
			return
		panel.Update()
		$.Schedule(0.2, panel.AutoUpdate)
	}
	panel.AutoUpdate()

	var ActivateAbility = function() {
		if (Game.IsInAbilityLearnMode() || GameUI.IsControlDown()) {
			Abilities.AttemptToUpgrade(panel.ability);
			if (Entities.GetAbilityPoints(panel.queryUnit) <= 0) {
				Game.EndAbilityLearnMode()
				UpdateAbilities()
			}
		} else {
			Abilities.ExecuteAbility(panel.ability, panel.queryUnit, false);
		}
	}

	panel.FindChildTraverse("AbilityButton").SetPanelEvent("onactivate", ActivateAbility)
	panel.FindChildTraverse("AbilityButton").SetPanelEvent("ondblclick", ActivateAbility)
	panel.FindChildTraverse("AbilityButton").SetPanelEvent("onmouseover", function() {
		$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", panel, panel.abilityName, panel.queryUnit)
	})
	panel.FindChildTraverse("AbilityButton").SetPanelEvent("onmouseout", function() {
		$.DispatchEvent("DOTAHideAbilityTooltip", panel)
	})
	panel.FindChildTraverse("AbilityButton").SetPanelEvent("oncontextmenu", function() {
		if (Game.IsInAbilityLearnMode())
			return;

		if (Abilities.IsAutocast(panel.ability)) {
			Game.PrepareUnitOrders({
				OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO,
				AbilityIndex: panel.ability
			})
		}
	})
	return panel
}

function CreateSnippet_Buff(panel) {
	panel.BLoadLayoutSnippet("Buff")
	panel.SetBuff = function(BuffSerial, queryUnit) {
		var noBuff = (BuffSerial == -1);
		panel.SetHasClass("no_buff", noBuff);
		if (!noBuff) {
			panel.BuffSerial = BuffSerial
			panel.queryUnit = queryUnit
			var nNumStacks = Buffs.GetStackCount(queryUnit, BuffSerial)
			panel.SetHasClass("has_stacks", nNumStacks > 0)

			panel.FindChildTraverse("StackCount").text = nNumStacks

			var duration = Number(Buffs.GetDuration(queryUnit, BuffSerial))
			if (duration > 0) {
				var pct = (1 - (Number(Buffs.GetElapsedTime(queryUnit, BuffSerial)) / duration)) * 100
				if (pct >= -10)
					panel.FindChildTraverse("BuffDuration").value = pct
				else
					panel.FindChildTraverse("BuffDuration").value = 100
			} else
				panel.FindChildTraverse("BuffDuration").value = 100
			panel.SetHasClass("is_debuff", Buffs.IsDebuff(queryUnit, BuffSerial))
			var texture = Buffs.GetTexture(queryUnit, BuffSerial)
			if (texture.length <= 0) {
				panel.FindChildTraverse("BuffImage").SetImage("raw://resource/flash3/images/spellicons/empty.png")
				panel.FindChildTraverse("BuffImageItem").SetImage("")
			} else if (texture.indexOf("item_") == -1) {
				panel.FindChildTraverse("BuffImageItem").SetImage("")
				panel.FindChildTraverse("BuffImage").SetImage(TransformTextureToPath(texture))
			} else {
				panel.FindChildTraverse("BuffImage").SetImage("")
				panel.FindChildTraverse("BuffImageItem").SetImage(TransformTextureToPath(texture))
			}
		}
	}
	panel.FindChildTraverse("BuffFrame").SetPanelEvent("onactivate", function() {
		//var alertBuff = GameUI.IsAltDown();
		if (panel.BuffSerial > -1 && Entities.IsControllableByPlayer(panel.queryUnit, Game.GetLocalPlayerID())) {
			Players.BuffClicked(panel.queryUnit, panel.BuffSerial, false);
			GameEvents.SendCustomGameEventToServer("modifier_clicked_purge", {
				unit: panel.queryUnit,
				modifier: Buffs.GetName(panel.queryUnit, panel.BuffSerial)
			});
		}
	})
	panel.FindChildTraverse("BuffFrame").SetPanelEvent("onmouseover", function() {
		if (panel.BuffSerial > -1)
			$.DispatchEvent("DOTAShowBuffTooltip", panel, panel.queryUnit, panel.BuffSerial, Entities.IsEnemy(panel.queryUnit));

	})
	panel.FindChildTraverse("BuffFrame").SetPanelEvent("onmouseout", function() {
		$.DispatchEvent("DOTAHideBuffTooltip", panel);
	})
	return panel
}

function GoldClicked() {
	if (GameUI.IsAltDown()) {
		SendAlert("gold")
	}
}

function SelectCourier() {
	var courier = FindCourier(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()))
	if (courier) {
		if (Players.GetLocalPlayerPortraitUnit() == courier) {
			GameUI.SetCameraTarget(courier)
			$.Schedule(0.03, function() {
				GameUI.SetCameraTarget(-1)
			})
		} else
			GameUI.SelectUnit(courier, false)
	}
}

function SetCourierTartget(playerId) {
	if (typeof playerId == "number") {
		$("#CourierDeadOverlay").RemoveClass("DeadCourier")
		if (playerId > -1) {
			$("#CourierStatusTarget").SetImage(TransformTextureToPath(GetHeroName(Players.GetPlayerHeroEntityIndex(playerId))))
		} else {
			$("#CourierStatusTarget").SetImage("file://{resources}/images/custom_game/hud/courier_empty.png")
		}
	} else if (playerId.status != null && playerId.value != null) {
		$("#CourierDeadOverlay").AddClass("DeadCourier")
		$("#CourierDeadTime").text = playerId.value
	}

}

function CourierBurst() {
	GameEvents.SendCustomGameEventToServer("hud_courier_burst", {
		playerId: Game.GetLocalPlayerID()
	})
}

function CourierTakeAndTransferItems() {
	var courier = FindCourier(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()))
	var selected = Players.GetSelectedEntities(Game.GetLocalPlayerID())
	GameUI.SelectUnit(courier, false)
	Abilities.ExecuteAbility(Entities.GetAbilityByName(courier, "courier_take_stash_and_transfer_items"), courier, false);
	GameUI.SelectUnit(-1, false)
	$.Each(selected, function(v) {
		GameUI.SelectUnit(v, true)
	})
}

function SelectPortraitUnit() {
	GameUI.SetCameraTarget(Players.GetLocalPlayerPortraitUnit())
	$.Schedule(0.03, function() {
		GameUI.SetCameraTarget(-1)
	})
}

function SetMinimalisticUIEnabled(value) {
	CustomHudEnabled = value
	value = !value
	GetDotaHud().SetHasClass("MinimalisticHudDisabled", value)
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, value)
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL, value)
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_COURIER, value)
	if (CustomHudEnabled) {
		UpdateSelection()
	}
}

function OnKill() {
	$("#KDA_Value_KDAHL").text = Players.GetKills(Game.GetLocalPlayerID()) + "/" + Players.GetDeaths(Game.GetLocalPlayerID()) + "/" + Players.GetAssists(Game.GetLocalPlayerID()) + "/" + Players.GetLastHits(Game.GetLocalPlayerID())
}

function UpdateStats() {
	var unit = Players.GetLocalPlayerPortraitUnit()
	var heroName = GetHeroName(unit)
	$("#DefaultInterfaceHeroName").text = $.Localize(heroName)
	if (CustomHudEnabled) {
		var ServersideAttributes = PlayerTables.GetTableValue("entity_attributes", unit)
		if (ServersideAttributes != null) {
			$("#AttributePanelStackAttributes").style.opacity = 1
			$("#DotaAttributeValue_spell_amplify").GetParent().style.opacity = 1
			$("#DotaAttributeValue_1").text = ServersideAttributes.str.toFixed(0)
			$("#DotaAttributeValue_2").text = ServersideAttributes.agi.toFixed(0)
			$("#DotaAttributeValue_3").text = ServersideAttributes.int.toFixed(0)
			$("#DotaAttributeValue_1_gain").text = " +(" + ServersideAttributes.str_gain.toFixed(1) + ")"
			$("#DotaAttributeValue_2_gain").text = " +(" + ServersideAttributes.agi_gain.toFixed(1) + ")"
			$("#DotaAttributeValue_3_gain").text = " +(" + ServersideAttributes.int_gain.toFixed(1) + ")"
			for (var i = 1; i <= 3; i++) {
				$("#DotaAttributePic_" + i).SetHasClass("PrimaryAttribute", i - 1 == ServersideAttributes.attribute_primary)
			}
			$("#DotaAttributeValue_spell_amplify").text = ServersideAttributes.spell_amplify.toFixed(2) + "%"
		} else {
			$("#AttributePanelStackAttributes").style.opacity = 0
			$("#DotaAttributeValue_spell_amplify").GetParent().style.opacity = 0
		}
		$("#HeroAvatarImage").SetImage(TransformTextureToPath(heroName))
		$("#HeroName").text = $.Localize(heroName)
	}
}

function UpdateLevels() {
	if (CustomHudEnabled)
		$("#HeroLevelLabel").text = Entities.GetLevel(Players.GetLocalPlayerPortraitUnit())
}

function UpdateSelection() {
	$.Schedule(0.03, function() {
		var unit = Players.GetLocalPlayerPortraitUnit()
		UpdateAbilities()
		UpdateStats()
		UpdateLevels()
		if (CustomHudEnabled) {
			var SelectedEntities = Players.GetSelectedEntities(Game.GetLocalPlayerID())
			if (SelectedEntities.length > 1) {
				$("#SelectedEntitiesPanel").style.visibility = "visible"
				$("#AttributesPanelStacks").style.opacity = 0
				var IgnoreChildren = []
				$.Each($("#SelectedEntitiesPanel").Children(), function(child) {
					if (child.unit != null) {
						if (SelectedEntities.indexOf(child.unit) == -1) {
							child.DeleteAsync(0)
						} else {
							child.SetHasClass("PortraitSelectedUnit", Players.GetLocalPlayerPortraitUnit() == child.unit)
							IgnoreChildren.push(child.unit)
						}
					}
				})
				SelectedEntities.sort()
				for (var key in SelectedEntities) {
					if (IgnoreChildren.indexOf(SelectedEntities[key]) == -1) {
						var panel = $.CreatePanel("Image", $("#SelectedEntitiesPanel"), "")
						panel.AddClass("SelectedEntitiesUnit")
						panel.SetImage(TransformTextureToPath(GetHeroName(SelectedEntities[key]), "portrait", Entities.GetTeamNumber(SelectedEntities[key])))
						panel.unit = SelectedEntities[key]
						panel.SetPanelEvent("onactivate", function() {
							GameUI.SelectUnit(panel.unit, false)
						})
						if (Entities.IsIllusion(SelectedEntities[key]))
							panel.style.washColor = "rgba(95,215,255, 220)";
						if (!Entities.IsAlive(SelectedEntities[key]))
							panel.style.washColor = "rgba(60,60,60, 220)";
						if (Entities.GetUnitName(SelectedEntities[key]).lastIndexOf("npc_dota_hero_", 0) != 0) {
							$.Msg("Not handled unit portrait " + Entities.GetUnitName(SelectedEntities[key]))
								//panel.SetImage("") //TODO
						}
					}
				}
			} else {
				$("#SelectedEntitiesPanel").style.visibility = "collapse"
				$("#AttributesPanelStacks").style.opacity = 1
			}
		}
	});
}

(function() {
	GameUI.SetRenderTopInsetOverride(0)
	GameUI.SetRenderBottomInsetOverride(0)

	GameEvents.Subscribe("dota_ability_changed", UpdateAbilities)
	GameEvents.Subscribe("dota_portrait_ability_layout_changed", UpdateAbilities)
	GameEvents.Subscribe("dota_hero_ability_points_changed", UpdateAbilities)
	GameEvents.Subscribe("entity_killed", OnKill)
	PlayerTables.SubscribeNetTableListener("entity_attributes", UpdateStats)
	GameEvents.Subscribe("dota_player_gained_level", UpdateLevels)
	GameEvents.Subscribe("dota_player_update_hero_selection", UpdateSelection)
	GameEvents.Subscribe("dota_player_update_selected_unit", UpdateSelection)
	GameEvents.Subscribe("dota_player_update_query_unit", UpdateSelection)
	GameEvents.Subscribe("dota_player_update_killcam_unit", UpdateSelection)
	UpdateLevels()
	OnKill()
	UpdateSelection()
	DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
		if (changesObject["courier_owner" + Players.GetTeam(Game.GetLocalPlayerID())] != null)
			SetCourierTartget(changesObject["courier_owner" + Players.GetTeam(Game.GetLocalPlayerID())])
		if (changesObject["gamemode_settings"] != null && changesObject["gamemode_settings"]["gamemode_type"] != null) {
			$("#PlayerControls_1x1").visible = changesObject["gamemode_settings"]["gamemode"] != DOTA_GAMEMODE_HOLDOUT_5
		}
	})
	SetMinimalisticUIEnabled(CustomHudEnabled)

	DynamicSubscribePTListener("arena", function(tableName, changesObject, deletionsObject) {
		if (changesObject["gamemode_settings"] != null && changesObject["gamemode_settings"]["gamemode_type"] != null) {
			GameUI.CustomUIConfig().DOTA_ACTIVE_GAMEMODE = changesObject["gamemode_settings"]["gamemode"]
			GameUI.CustomUIConfig().DOTA_ACTIVE_GAMEMODE_TYPE = changesObject["gamemode_settings"]["gamemode_type"]
		}
	})
	UpdateAbilities()
	AutoUpdatePanels()
})()