var CurrentUnit = -1;

function TogglePanelVisible(state) {
	if (typeof state === "boolean")
		$.GetContextPanel().SetHasClass("PanelOpened", state);
	else
		$.GetContextPanel().ToggleClass("PanelOpened");
	Update();
}

function AutoUpdate() {
	$.Schedule(0.2, AutoUpdate);
	Update();
}

function Update() {
	if ($.GetContextPanel().BHasClass("PanelOpened")) {
		var unit = Players.GetLocalPlayerPortraitUnit();
		if (!Entities.IsRealHero(unit))
			unit = Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID());
		if (CurrentUnit != unit) {
			var heroPid = Entities.GetHeroPlayerOwner(unit);
			if (heroPid > -1) {
				SetCurrentWearablePanelOwner(unit, heroPid);
				var heroOwner = Game.GetLocalPlayerID();
				var heroname = GetHeroName(unit);
				$.Msg("Try to get equipped wearables for " + heroname + " with pid of " + heroPid);
				GameEvents.SendCustomGameEventToServer("dynamic_wearables_get_equipped", {});
				if (heroPid == Game.GetLocalPlayerID()) {
					$.Msg("Owner is local player, get avaliable wearables");
					GameEvents.SendCustomGameEventToServer("dynamic_wearables_get_avaliable", {});
				}
			}
		}
	}
}

function SetCurrentWearablePanelOwner(unit, heroPid) {
	CurrentUnit = unit;
	$("#WearablesHeroPreview").BCreateChildren("");
	if (heroPid == Game.GetLocalPlayerID()) {

	}
}

function SetAvaliableWearables(data) {
	$.Msg(data);
	for (var slot in data) {
		var WearablesInSlot = data[slot];
		$.Each(WearablesInSlot, function(wearable) {
			$.Msg(slot, "       ", wearable);
		});
	}
}

(function() {
	AutoUpdate();
	GameEvents.Subscribe("dynamic_wearables_toggle_hud_panel", TogglePanelVisible);
	GameEvents.Subscribe("dynamic_wearables_set_avaliable", SetAvaliableWearables);
		//GameEvents.SendCustomGameEventToServer("dynamic_wearables_equip", { wearableId: -1 })

})();
