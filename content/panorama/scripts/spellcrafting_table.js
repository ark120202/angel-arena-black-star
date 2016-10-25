var ContID = 0
if (GameUI.CustomUIConfig().Containers == null) {
	GameUI.CustomUIConfig().Containers = {}
}
if (GameUI.CustomUIConfig().Containers.eventHandlers == null) {
	GameUI.CustomUIConfig().Containers.eventHandlers = {}
}
if ($("#main_cad_slot") == null) {
	/*var card_slots_cont = $.CreatePanel("Panel", $("#SpellCardsPanel"), "card_slots_cont");
	card_slots_cont.BLoadLayout("file://{resources}/layout/custom_game/containers/container.xml", false, false);
	card_slots_cont.NewContainer(-1)*/
	//card_slots_cont.AddClass("SpellCardPanel")
	/*card_slots_cont.SetItem(-1, 0 /*contid , i + 2, {
		deleted: false
	} /*, $.GetContextPanel() );*/
}

if ($("#main_cad_slot") == null) {
	var child = $.CreatePanel("Panel", $("#CADSlot"), "main_cad_slot");
	child.BLoadLayout("file://{resources}/layout/custom_game/containers/inventory_item.xml", false, false);
	child.SetItem(-1, ContID, Game.GetLocalPlayerID() + 1, $.GetContextPanel());
}

function UpdateCADSlot(keys) {
	var conts = CustomNetTables.GetTableValue("CAD", "itemContIds")
	if (keys.id != null) {
		if (!isNaN(conts[keys.id])) {
			$("#SpellCardsPanel").RemoveAndDeleteChildren()
			var card_slots_cont = $.CreatePanel("Panel", $("#SpellCardsPanel"), "card_slots_cont");
			card_slots_cont.BLoadLayout("file://{resources}/layout/custom_game/containers/alt_container_clean.xml", false, false);
			card_slots_cont.NewContainer(Number(conts[keys.id]))
			card_slots_cont.style.position = "0 0 0"
		} else if (keys.id == -1) {
			$("#SpellCardsPanel").RemoveAndDeleteChildren()
		}
		//card_slots_cont.AddClass("SpellCardPanel")
	}
}

GameEvents.Subscribe("spellcrafting_update_slot_cad", UpdateCADSlot)