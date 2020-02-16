"use strict";

function DismissMenu() {
	$.Schedule(0.05, function() {
		$.DispatchEvent("DismissAllContextMenus");
	});
}

function OnSell() {
	Items.LocalPlayerSellItem($.GetContextPanel().Item);

	GameEvents.SendCustomGameEventToServer("Containers_OnSell", {
		unit: Players.GetLocalPlayerPortraitUnit(),
		contID: $.GetContextPanel().Container,
		itemID: $.GetContextPanel().Item,
		slot: $.GetContextPanel().Slot
	});

	DismissMenu();
}

function OnDisassemble() {
	Items.LocalPlayerDisassembleItem($.GetContextPanel().Item);
	DismissMenu();
}

function OnShowInShop() {
	var itemName = Abilities.GetAbilityName($.GetContextPanel().Item);
  GameEvents.SendEventClientSide('panorama_shop_show_item', { itemName });
	DismissMenu();
}

function OnDropFromStash() {
	Items.LocalPlayerDropItemFromStash($.GetContextPanel().Item);
	DismissMenu();
}

function OnMoveToStash() {
	Items.LocalPlayerMoveItemToStash($.GetContextPanel().Item);
	DismissMenu();
}

function OnAlert() {
	Items.LocalPlayerItemAlertAllies($.GetContextPanel().Item);
	DismissMenu();
}
