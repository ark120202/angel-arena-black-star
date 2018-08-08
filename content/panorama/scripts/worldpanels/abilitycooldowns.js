function AbilitiesCooldownCheck() {
	var wp = $.GetContextPanel().WorldPanel;
	var offScreen = $.GetContextPanel().OffScreen;
	if (!offScreen && wp) {
		var ent = wp.entity;
		if (ent) {
			if (!Entities.IsAlive(ent)) {
				$.GetContextPanel().style.opacity = "0";
				$.Schedule(1 / 30, AbilitiesCooldownCheck);
				return;
			}

			$.GetContextPanel().style.opacity = "1";
			var EntityAbilities = [];
			var EntityAbilitiesNames = [];
			for (var i = 0; i < Entities.GetAbilityCount(ent); i++) {
				var ability = Entities.GetAbility(ent, i);

				if (ability !== -1 && !_.startsWith(Abilities.GetAbilityName(ability), "special_bonus_") && !Abilities.IsHidden(ability)) {
					EntityAbilities.push(ability);
					EntityAbilitiesNames.push(Abilities.GetAbilityName(ability));
				}
			}
			var AbilityBox = $("#AbilityBox");
			if (!_.isEqual(EntityAbilitiesNames, AbilityBox.EntityAbilitiesNames) || AbilityBox.GetChildCount() <= 0) {
				AbilityBox.RemoveAndDeleteChildren();
				for (k in EntityAbilities) {
					var ability = EntityAbilities[k];
					var abilityPanel = $.CreatePanel('Panel', AbilityBox, "");
					abilityPanel.abilityId = ability;
					abilityPanel.AddClass("AbilityCdBox");
					var abilityImage = $.CreatePanel('DOTAAbilityImage', abilityPanel, "");
					abilityImage.abilityname = Abilities.GetAbilityName(ability);
					abilityImage.AddClass("AbilityCdImage");

					var cooldownPanel = $.CreatePanel('Panel', abilityPanel, "");
					cooldownPanel.AddClass("Cooldown");
					var cooldownOverlayPanel = $.CreatePanel('Panel', cooldownPanel, "AbilityCooldownOverlay");
					cooldownOverlayPanel.AddClass("CooldownOverlay");
					var cooldownTimer = $.CreatePanel('Label', cooldownPanel, "AbilityCooldownTimer");
					cooldownTimer.AddClass("CooldownTimer");
					var cooldownLevel = $.CreatePanel('Label', cooldownPanel, "AbilityLevel");
					cooldownLevel.AddClass("AbilityLevel");
					var abilityManacostPanel = $.CreatePanel('Panel', cooldownPanel, "AbilityManacostPanel");
					abilityManacostPanel.AddClass("ManacostPanel");
					/*
					var ItemShowTooltip = (function(_abilityName, _panel) {
						return function() {
							$.DispatchEvent( "DOTAShowAbilityTooltip", _panel, _abilityName );
						}
					}) (Abilities.GetAbilityName(ability), abilityPanel)
					var ItemHideTooltip = (function(_panel) {
						return function() {
							$.DispatchEvent( "DOTAHideAbilityTooltip", _panel );
						}
					}) (abilityPanel)
					abilityPanel.SetPanelEvent( 'onmouseover', ItemShowTooltip)
					abilityPanel.SetPanelEvent( 'onmouseout', ItemHideTooltip)*/
				}
				$("#HealthBar").RemoveAndDeleteChildren();
				if ($.GetContextPanel().Data.hasHealthBar) {
					$("#HealthBar").WorldPanel = wp;
					$("#HealthBar").BLoadLayout("file://{resources}/layout/custom_game/worldpanels/healthbar.xml", true, true);
				}
			}
			AbilityBox.EntityAbilities = EntityAbilities;
			AbilityBox.EntityAbilitiesNames = EntityAbilitiesNames;
			for (var i = 0; i < AbilityBox.GetChildCount(); i++) {
				var abilityPanel = AbilityBox.GetChild(i);
				abilityPanel.GetChild(1).FindChild("AbilityLevel").text = Abilities.GetLevel(abilityPanel.abilityId);

				if (abilityPanel.GetChild(1).FindChild("AbilityManacostPanel").visible != !Abilities.IsOwnersManaEnough(abilityPanel.abilityId)) {
					abilityPanel.GetChild(1).FindChild("AbilityManacostPanel").visible = !Abilities.IsOwnersManaEnough(abilityPanel.abilityId);
				}

				if (abilityPanel.abilityId > -1 && !Abilities.IsCooldownReady(abilityPanel.abilityId)) {
					var cooldownLength = Abilities.GetCooldownLength(abilityPanel.abilityId);
					var cooldownRemaining = Abilities.GetCooldownTimeRemaining(abilityPanel.abilityId);
					var cooldownPercent = Math.ceil(100 * cooldownRemaining / cooldownLength);
					abilityPanel.GetChild(1).FindChild("AbilityCooldownTimer").text = Math.ceil(cooldownRemaining);
					abilityPanel.GetChild(1).FindChild("AbilityCooldownOverlay").style.width = cooldownPercent + "%";
				} else {
					abilityPanel.GetChild(1).FindChild("AbilityCooldownTimer").text = "";
					abilityPanel.GetChild(1).FindChild("AbilityCooldownOverlay").style.width = "0%";
				}
			}

		}
	}

	$.Schedule(0.2, AbilitiesCooldownCheck);
}

(function() {
	AbilitiesCooldownCheck();
})();
