"use strict";

function DismissMenu() {
	$.Schedule(0.1, function() {
		$.DispatchEvent("DismissAllContextMenus");
	});
}

function OnSell() {
	var pid = Game.GetLocalPlayerID();
	var unit = $.GetContextPanel().Unit;
	unit = Entities.IsControllableByPlayer(unit, pid) ? unit : Players.GetPlayerHeroEntityIndex(pid);
	GameEvents.SendCustomGameEventToServer("panorama_shop_sell_item", {
		"itemIndex": $.GetContextPanel().Item,
		"unit": unit,
	});
	DismissMenu();
}

function OnDisassemble() {
	if (VerifyItem())
		Items.LocalPlayerDisassembleItem($.GetContextPanel().Item);
	DismissMenu();
}

function OnShowInShop() {
	if (VerifyItem()) {
		var itemName = Abilities.GetAbilityName($.GetContextPanel().Item);
    GameEvents.SendEventClientSide('panorama_shop_show_item', { itemName });
	}
	DismissMenu();
}

function OnDropFromStash() {
	if (VerifyItem())
		Items.LocalPlayerDropItemFromStash($.GetContextPanel().Item);
	DismissMenu();
}

function OnMoveToStash() {
	if (VerifyItem())
		Items.LocalPlayerMoveItemToStash($.GetContextPanel().Item);
	DismissMenu();
}

function OnAlert() {
	if (VerifyItem())
		Items.LocalPlayerItemAlertAllies($.GetContextPanel().Item);
	DismissMenu();
}

function VerifyItem() {
	var endPoint = 11;
	for (var i = endPoint; i >= 0; i--) {
		if (Entities.GetItemInSlot($.GetContextPanel().Unit, i) == $.GetContextPanel().Item)
			return true;
	}
	return false;
}
