"use strict";
var PlayerTables = GameUI.CustomUIConfig().PlayerTables
var ItemList = {}
var ItemData = {}
var Itembuilds = {}
var SmallItems = []
var SearchingFor = null
var TabIndex = null
var QuickBuyTarget = null
var QuickBuyTargetAmount = 0
var LastHero = null


function OpenCloseShop() {
	$("#ShopBase").ToggleClass("ShopBase_Out")
	if ($("#ShopBase").BHasClass("ShopBase_Out"))
		Game.EmitSound("Shop.PanelUp")
	else
		Game.EmitSound("Shop.PanelDown")
}

function SearchItems() {
	var searchStr = $("#ShopSearchEntry").text.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&");
	if (SearchingFor != searchStr) {
		SearchingFor = searchStr
		var ShopSearchOverlay = $("#ShopSearchOverlay")
		$.Each(ShopSearchOverlay.Children(), function(child) {
			var index = SmallItems.indexOf(child);
			if (index > -1) {
				child.visible = false
				SmallItems.splice(index, 1);
			}
		})
		$.GetContextPanel().SetHasClass("InSearchMode", searchStr.length > 0)
		if (searchStr.length > 0) {
			var FoundItems = []
			for (var itemName in ItemData) {
				if (!ItemData[itemName].hidden && itemName.lastIndexOf("item_recipe_")) {
					for (var key in ItemData[itemName].names) {
						if (ItemData[itemName].names[key].search(new RegExp(searchStr, "i")) > -1) {
							FoundItems.push({
								itemName: itemName,
								cost: ItemData[itemName].cost
							})
							break;
						}
					}
				}
			}
			FoundItems.sort(dynamicSort("cost"))
			$.Each(FoundItems, function(itemTable) {
				SnippetCreate_SmallItem($.CreatePanel("Panel", ShopSearchOverlay, "ShopSearchOverlay_item_" + itemTable.itemName), itemTable.itemName)
			})
		}
	}
}

function PushItemsToList() {
	var isTabSelected = false
	for (var shopName in ItemList) {
		var TabButton = $.CreatePanel('Button', $("#ShopTabs"), "shop_tab_" + shopName)
		TabButton.AddClass("ShopTabButton")
		TabButton.style.width = (100 / Object.keys(ItemList).length) + "%";
		var TabButtonLabel = $.CreatePanel('Label', TabButton, "")
		TabButtonLabel.text = $.Localize("panorama_shop_shop_tab_" + shopName)
		TabButtonLabel.AddClass("ShopTabButtonLabel")
		var SelectShopTabAction = (function(_shopName) {
			return function() {
				SelectShopTab(_shopName)
			}
		})(shopName)
		TabButton.SetPanelEvent('onactivate', SelectShopTabAction)
		var TabShopItemlistPanel = $.CreatePanel('Panel', $("#ShopItemsBase"), "shop_panels_tab_" + shopName)
		TabShopItemlistPanel.style.height = "100%";
		TabShopItemlistPanel.style.horizontalAlign = "center";

		TabShopItemlistPanel.style.flowChildren = "right-wrap"
		FillShopTable(TabShopItemlistPanel, ItemList[shopName])
		TabShopItemlistPanel.visible = false

		if (!isTabSelected) {
			SelectShopTab(shopName)
			isTabSelected = true
		}
	}

}

function SelectShopTab(tabIndex) {
	if (TabIndex != tabIndex) {
		if (TabIndex != null) {
			$("#shop_panels_tab_" + TabIndex).visible = false
			$("#shop_tab_" + TabIndex).RemoveClass("ShopTabButtonSelected")
		}
		$("#shop_panels_tab_" + tabIndex).visible = true
		$("#shop_tab_" + tabIndex).AddClass("ShopTabButtonSelected")
		TabIndex = tabIndex
	}
}

function FillShopTable(panel, shopData) {
	for (var groupName in shopData) {
		var groupPanel = $.CreatePanel("Panel", panel, panel.id + "_group_" + groupName)
		groupPanel.AddClass("ShopItemGroup")
		$.Each(shopData[groupName], function(itemName) {
			var itemPanel = $.CreatePanel("Panel", groupPanel, groupPanel.id + "_item_" + itemName)
			SnippetCreate_SmallItem(itemPanel, itemName)
				//groupPanel.AddClass("ShopItemGroup")
		})
	}
}

function SnippetCreate_SmallItem(panel, itemName) {
	panel.BLoadLayoutSnippet("SmallItem")
	panel.itemName = itemName
	panel.FindChildTraverse("SmallItemImage").itemname = itemName;
	if (itemName.lastIndexOf("item_recipe", 0) === 0)
		panel.FindChildTraverse("SmallItemImage").SetImage("raw://resource/flash3/images/items/recipe.png")
	panel.SetPanelEvent("onactivate", function() {
		ShowItemRecipe(itemName)
		if (GameUI.IsShiftDown())
			SetQuickbuyTarget(itemName)
	})
	panel.SetPanelEvent("oncontextmenu", function() {
		if (panel.BHasClass("CanBuy")) {
			var ItemCounter = {}
			SendItemBuyOrder(itemName, ItemCounter)
		} else {
			GameEvents.SendEventClientSide("dota_hud_error_message", {
				"splitscreenplayer": 0,
				"reason": 80,
				"message": "#dota_hud_error_not_enough_gold"
			});
			Game.EmitSound("General.NoGold")
		}
	})
	panel.SetPanelEvent("onmouseover", function() {
		ItemShowTooltip(panel)
	})
	panel.SetPanelEvent("onmouseout", function() {
		ItemHideTooltip(panel)
	})
	if (!panel.IsInQuickbuy) {
		$.RegisterEventHandler('DragStart', panel, SmallItemOnDragStart);
		$.RegisterEventHandler('DragEnd', panel, SmallItemOnDragEnd);
	}
	UpdateSmallItem(panel)
	SmallItems.push(panel)
}

function SmallItemOnDragStart(panelId, dragCallbacks) {
	$.GetContextPanel().AddClass("DropDownMode")
	var panel = $("#" + panelId)
	var itemName = panel.itemName
	ItemHideTooltip(panel);

	var displayPanel = $.CreatePanel("DOTAItemImage", panel, "dragImage");
	displayPanel.itemname = itemName;
	if (itemName.lastIndexOf("item_recipe_", 0) === 0)
		displayPanel.SetImage("raw://resource/flash3/images/items/recipe.png")

	dragCallbacks.displayPanel = displayPanel;
	dragCallbacks.offsetX = 0;
	dragCallbacks.offsetY = 0;
	SetPannelDraggedChild(displayPanel, function() {
		return !$.GetContextPanel().BHasClass("DropDownMode");
	});
	return true;
}

function SmallItemOnDragEnd(panelId, draggedPanel) {
	$.GetContextPanel().RemoveClass("DropDownMode")
	draggedPanel.DeleteAsync(0);
	return true;
}

function ShowItemRecipe(itemName) {
	var currentItemData = ItemData[itemName]
	var RecipeData = currentItemData.Recipe
	var BuildsIntoData = currentItemData.BuildsInto
	$.Each($("#ItemRecipeBoxRow1").Children(), function(child) {
		var index = SmallItems.indexOf(child);
		if (index > -1) {
			child.visible = false
			SmallItems.splice(index, 1);
		}
	})
	$.Each($("#ItemRecipeBoxRow2").Children(), function(child) {
		var index = SmallItems.indexOf(child);
		if (index > -1) {
			child.visible = false
			SmallItems.splice(index, 1);
		}
	})
	$.Each($("#ItemRecipeBoxRow3").Children(), function(child) {
		var index = SmallItems.indexOf(child);
		if (index > -1) {
			child.visible = false
			SmallItems.splice(index, 1);
		}
	})
	$("#ItemRecipeBoxRow1").RemoveAndDeleteChildren();
	$("#ItemRecipeBoxRow2").RemoveAndDeleteChildren();
	$("#ItemRecipeBoxRow3").RemoveAndDeleteChildren();

	var itemPanel = $.CreatePanel("Panel", $("#ItemRecipeBoxRow2"), "ItemRecipeBoxRow2_item_" + itemName);
	SnippetCreate_SmallItem(itemPanel, itemName);
	itemPanel.style.align = "center center";
	if (RecipeData != null && RecipeData.items != null) {
		$.Each(RecipeData.items[1], function(childName) {
			var itemPanel = $.CreatePanel("Panel", $("#ItemRecipeBoxRow3"), "ItemRecipeBoxRow3_item_" + childName)
			SnippetCreate_SmallItem(itemPanel, childName);
			itemPanel.style.align = "center center";
		});
		var len = Object.keys(RecipeData.items).length;
		if (RecipeData.visible && RecipeData.recipeItemName != null) {
			len++;
			var itemPanel = $.CreatePanel("Panel", $("#ItemRecipeBoxRow3"), "ItemRecipeBoxRow3_item_" + RecipeData.recipeItemName);
			SnippetCreate_SmallItem(itemPanel, RecipeData.recipeItemName);
			itemPanel.style.align = "center center";
		}
		$("#ItemRecipeBoxRow1").SetHasClass("ItemRecipeBoxRowLength7", len >= 7);
		$("#ItemRecipeBoxRow1").SetHasClass("ItemRecipeBoxRowLength8", len >= 8);
		$("#ItemRecipeBoxRow1").SetHasClass("ItemRecipeBoxRowLength9", len >= 9);
	}
	if (BuildsIntoData != null) {
		$.Each(BuildsIntoData, function(childName) {
			var itemPanel = $.CreatePanel("Panel", $("#ItemRecipeBoxRow1"), "ItemRecipeBoxRow1_item_" + childName);
			SnippetCreate_SmallItem(itemPanel, childName);
			itemPanel.style.align = "center center";
		});
		$("#ItemRecipeBoxRow1").SetHasClass("ItemRecipeBoxRowLength7", Object.keys(BuildsIntoData).length >= 7);
		$("#ItemRecipeBoxRow1").SetHasClass("ItemRecipeBoxRowLength8", Object.keys(BuildsIntoData).length >= 8);
		$("#ItemRecipeBoxRow1").SetHasClass("ItemRecipeBoxRowLength9", Object.keys(BuildsIntoData).length >= 9);
	}
}

function SendItemBuyOrder(itemName, ItemCounter, baseItem) {
	if (ItemCounter[itemName] == null) {
		ItemCounter[itemName] = 0
		UpdateShop()
	}
	ItemCounter[itemName] = ItemCounter[itemName] + 1
	var itemCount = GetItemCountInInventory(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), itemName, true)
	if (itemCount < ItemCounter[itemName] || !baseItem) {
		if (!baseItem)
			Game.EmitSound("General.Buy")
		var unit = Players.GetLocalPlayerPortraitUnit()
		if (!Entities.IsControllableByPlayer(unit, Game.GetLocalPlayerID()) || !Entities.IsInventoryEnabled(unit))
			unit = Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID())
		var RecipeData = ItemData[itemName].Recipe
		if (RecipeData != null && RecipeData.items != null) {
			$.Each(RecipeData.items[1], function(childName) {
				SendItemBuyOrder(childName, ItemCounter, baseItem || itemName)
			})
			if (RecipeData.visible && RecipeData.recipeItemName != null) {
				SendItemBuyOrder(RecipeData.recipeItemName, ItemCounter, baseItem || itemName)
			}
		} else {
			Game.PrepareUnitOrders({
				OrderType: dotaunitorder_t.DOTA_UNIT_ORDER_PURCHASE_ITEM,
				AbilityIndex: ItemData[itemName].id,
				Queue: false
			})
		}
	}
}

function ItemShowTooltip(panel) {
	$.DispatchEvent("DOTAShowAbilityTooltipForEntityIndex", panel, panel.itemName, Players.GetLocalPlayerPortraitUnit());
}

function ItemHideTooltip(panel) {
	$.DispatchEvent("DOTAHideAbilityTooltip", panel);
}

function LoadItemsFromTable(panorama_shop_data) {
	ItemList = panorama_shop_data.ShopList
	ItemData = panorama_shop_data.ItemData
	Itembuilds = panorama_shop_data.Itembuilds
	PushItemsToList()
}

function UpdatePanoramaState() {
	var panorama_shop_data = PlayerTables.GetAllTableValues("panorama_shop_data")
	if (panorama_shop_data != null) {
		LoadItemsFromTable(panorama_shop_data)
		SetQuickbuyStickyItem("item_tpscroll")
	} else {
		$.Schedule(0.1, UpdatePanoramaState)
	}
}

function UpdateSmallItem(panel, gold) {
	try {
		panel.SetHasClass("CanBuy", GetRemainingPrice(panel.itemName, {}) < (gold || PlayerTables.GetTableValue("arena", "gold")[Game.GetLocalPlayerID()]))
	} catch (err) {
		var index = SmallItems.indexOf(panel);
		if (index > -1) {
			SmallItems.splice(index, 1);
		}
	}
}

function GetRemainingPrice(itemName, ItemCounter, baseItem) {
	if (ItemCounter[itemName] == null)
		ItemCounter[itemName] = 0
	ItemCounter[itemName] = ItemCounter[itemName] + 1

	var itemCount = GetItemCountInInventory(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), itemName, true)
	var val = 0
	if (itemCount < ItemCounter[itemName] || !baseItem) {
		var RecipeData = ItemData[itemName].Recipe
		if (RecipeData != null && RecipeData.items != null) {
			$.Each(RecipeData.items[1], function(childName) {
				val += GetRemainingPrice(childName, ItemCounter, baseItem || itemName)
			})
			if (RecipeData.visible && RecipeData.recipeItemName != null) {
				val += GetRemainingPrice(RecipeData.recipeItemName, ItemCounter, baseItem || itemName)
			}
		} else {
			val += ItemData[itemName].cost
		}
	}
	return val
}

function SetQuickbuyStickyItem(itemName) {
	$.Each($("#QuickBuyStickyButtonPanel").Children(), function(child) {
		var index = SmallItems.indexOf(child);
		if (index > -1) {
			child.visible = false
			SmallItems.splice(index, 1);
		}
		child.DeleteAsync(0)
	})
	var itemPanel = $.CreatePanel("Panel", $("#QuickBuyStickyButtonPanel"), "QuickBuyStickyButtonPanel_item_" + itemName)
	SnippetCreate_SmallItem(itemPanel, itemName)
	itemPanel.AddClass("QuickBuyStickyItem")
}

function ClearQuickbuyItems() {
	QuickBuyTarget = null
	QuickBuyTargetAmount = null
	$.Each($("#QuickBuyPanelItems").Children(), function(child) {
		if (!child.BHasClass("DropDownValidTarget")) {
			var index = SmallItems.indexOf(child);
			if (index > -1) {
				child.visible = false
				SmallItems.splice(index, 1);
			}
			child.DeleteAsync(0)
		} else {
			//child.visible = false
		}
	})
}

function RefreshQuickbuyItem(itemName) {
	var a = {}
	var b = {}
	MakeQuickbuyCheckItem(itemName, a, b, QuickBuyTargetAmount)
}

function MakeQuickbuyCheckItem(itemName, ItemCounter, ItemIndexer, sourceExpectedCount) {
	var RecipeData = ItemData[itemName].Recipe
	if (ItemCounter[itemName] == null)
		ItemCounter[itemName] = 0
	if (ItemIndexer[itemName] == null)
		ItemIndexer[itemName] = 0
	ItemCounter[itemName] = ItemCounter[itemName] + 1
	ItemIndexer[itemName] = ItemIndexer[itemName] + 1
	var itemCount = GetItemCountInCourier(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), itemName, true) + GetItemCountInInventory(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), itemName, true)
	if ((itemCount < ItemCounter[itemName] || (itemName == QuickBuyTarget && itemCount - (sourceExpectedCount - 1) < ItemCounter[itemName]))) {
		if (RecipeData != null && RecipeData.items != null) {
			$.Each(RecipeData.items[1], function(childName) {
				MakeQuickbuyCheckItem(childName, ItemCounter, ItemIndexer)
			})
			if (RecipeData.visible && RecipeData.recipeItemName != null) {
				MakeQuickbuyCheckItem(RecipeData.recipeItemName, ItemCounter, ItemIndexer)
			}
		} else if ($("#QuickBuyPanelItems").FindChildTraverse("QuickBuyPanelItems_item_" + itemName + "_id_" + ItemIndexer[itemName]) == null) {
			var itemPanel = $.CreatePanel("Panel", $("#QuickBuyPanelItems"), "QuickBuyPanelItems_item_" + itemName + "_id_" + ItemIndexer[itemName])
			itemPanel.IsInQuickbuy = true
			SnippetCreate_SmallItem(itemPanel, itemName)
			itemPanel.AddClass("QuickbuyItemPanel")
		}
	} else {
		if (itemName == QuickBuyTarget) {
			ClearQuickbuyItems()
		} else {
			RemoveQuickbuyItemChildren(itemName, ItemIndexer, false)
		}
	}
}

function RemoveQuickbuyItemChildren(itemName, ItemIndexer, bIncrease) {
	var RecipeData = ItemData[itemName].Recipe
	if (bIncrease)
		ItemIndexer[itemName] = (ItemIndexer[itemName] || 0) + 1
	RemoveQuckbuyPanel(itemName, ItemIndexer[itemName])
	if (RecipeData != null && RecipeData.items != null) {
		$.Each(RecipeData.items[1], function(childName) {
			RemoveQuickbuyItemChildren(childName, ItemIndexer, true)
		})
		if (RecipeData.visible && RecipeData.recipeItemName != null) {
			RemoveQuickbuyItemChildren(RecipeData.recipeItemName, ItemIndexer, true)
		}
	}
}

function RemoveQuckbuyPanel(itemName, index) {
	var panel = $("#QuickBuyPanelItems").FindChildTraverse("QuickBuyPanelItems_item_" + itemName + "_id_" + index)
	if (panel != null) {
		var id = SmallItems.indexOf(panel);
		if (id > -1) {
			panel.visible = false
			SmallItems.splice(id, 1);
		}
		panel.DeleteAsync(0)
	}
}

function SetQuickbuyTarget(itemName) {
	ClearQuickbuyItems()
	Game.EmitSound("Quickbuy.Confirmation")
	QuickBuyTarget = itemName
	QuickBuyTargetAmount = GetItemCountInCourier(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), itemName, true) + GetItemCountInInventory(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), itemName, true) + 1
	RefreshQuickbuyItem(itemName)
}

function ShowItemInShop(data) {
	if (data && data.itemName != null) {
		$("#ShopBase").RemoveClass("ShopBase_Out")
		ShowItemRecipe(String(data.itemName))
	}
}

function UpdateShop() {
	SearchItems()
	var gold = PlayerTables.GetTableValue("arena", "gold")[Game.GetLocalPlayerID()]
	$.Each(SmallItems, function(panel) {
		UpdateSmallItem(panel, gold)
	})
	UpdateItembuildsForHero();
	//$.GetContextPanel().SetHasClass("InRangeOfShop", Entities.IsInRangeOfShop(m_QueryUnit, 0, true))
}

function AutoUpdateShop() {
	UpdateShop()
	$.Schedule(0.5, AutoUpdateShop)
}

function AutoUpdateQuickbuy() {
	if (QuickBuyTarget != null) {
		RefreshQuickbuyItem(QuickBuyTarget)
	}
	$.Schedule(0.15, AutoUpdateQuickbuy)
}

function UpdateItembuildsForHero() {
	var heroName = GetPlayerHeroName(Game.GetLocalPlayerID())
	if (LastHero != heroName) {
		LastHero = heroName;
		var DropRoot = $("#Itembuild_select");
		var content = "";
		var SelectedTable;
		if (Itembuilds[heroName]) {
			$.Each(Itembuilds[heroName], function(build, i) {
				content = content + "<Label text='" + build.title + "' id='Itembuild_select_element_index_" + i + "'/>";
				if (SelectedTable == null)
					SelectedTable = build;
			});
		}
		DropRoot.BLoadLayoutFromString("<root><Panel><DropDown id='Itembuild_select'> " + content + " /></DropDown></Panel></root>", true, true);
		DropRoot.FindChildTraverse("Itembuild_select").SetPanelEvent("oninputsubmit", function() {
			var index = Number(DropRoot.FindChildTraverse("Itembuild_select").GetSelected().id.replace("Itembuild_select_element_index_", ""))
			if (Itembuilds[heroName] != null && Itembuilds[heroName][index] != null) {
				SelectItembuild(Itembuilds[heroName][index])
			}
		})
		SelectItembuild(SelectedTable);
	}
}

function SelectItembuild(t) {
	var groupsRoot = $("#ItembuildPanelsRoot")
	groupsRoot.RemoveAndDeleteChildren();
	if (t != null) {
		$("#Itembuild_author").text = t.author || "?";
		$("#Itembuild_patch").text = t.patch || "?";
		$.Each(t.items, function(groupData) {
			var groupRoot = $.CreatePanel("Panel", groupsRoot, "");
			groupRoot.AddClass("ItembuildItemGroup");
			var groupTitle = $.CreatePanel("Label", groupRoot, "");
			groupTitle.AddClass("ItembuildItemGroupTitle");
			groupTitle.text = $.Localize(groupData.title);
			var itemsRoot = $.CreatePanel("Panel", groupRoot, "");
			itemsRoot.AddClass("ItembuildItemGroupItemRoot");

			$.Each(groupData.content, function(itemName) {
				var itemPanel = $.CreatePanel("Panel", itemsRoot, "shop_itembuild_items_" + itemName)
				SnippetCreate_SmallItem(itemPanel, itemName)
				itemPanel.AddClass("BigItemPanel")
			})
		})
	} else {
		$("#Itembuild_author").text = "";
		$("#Itembuild_patch").text = "";
	}
}

function ShowHideItembuilds() {
	$.GetContextPanel().ToggleClass("ItembuildsHidden");
	$("#ShowHideItemguidesLabel").text = $.GetContextPanel().BHasClass("ItembuildsHidden") ? "<" : ">";
}

(function() {
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false)
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_GOLD, false)
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, false)
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, false)

	Game.Events.F4Pressed.push(OpenCloseShop)
	Game.Events.F5Pressed.push(function() {
		var bought = false;
		$.Each($("#QuickBuyPanelItems").Children(), function(child) {
			if (!child.BHasClass("DropDownValidTarget")) {
				UpdateSmallItem(child)
				if (child.BHasClass("CanBuy")) {
					var ItemCounter = {}
					SendItemBuyOrder(child.itemName, ItemCounter)
					bought = true;
					return false
				}
			}
		})
		if (!bought) {
			GameEvents.SendEventClientSide("dota_hud_error_message", {
				"splitscreenplayer": 0,
				"reason": 80,
				"message": "#dota_hud_error_not_enough_gold"
			});
			Game.EmitSound("General.NoGold")
		}
	})
	Game.Events.F8Pressed.push(function() {
		var ItemCounter = {}
		SendItemBuyOrder($("#QuickBuyStickyButtonPanel").GetChild(0).itemName, ItemCounter)
	})
	Game.MouseEvents.OnLeftPressed.push(function() {
		$("#ShopBase").AddClass("ShopBase_Out")
	})

	GameEvents.Subscribe("panorama_shop_show_item", ShowItemInShop)
	GameEvents.Subscribe("panorama_shop_show_item_if_open", function(data) {
		if (!$("#ShopBase").BHasClass("ShopBase_Out"))
			ShowItemInShop(data)
	})
	UpdatePanoramaState()
	AutoUpdateShop()
	AutoUpdateQuickbuy()

	$.RegisterEventHandler('DragDrop', $("#QuickBuyStickyButtonPanel"), function(panelId, draggedPanel) {
		if (draggedPanel.itemname != null) {
			SetQuickbuyStickyItem(draggedPanel.itemname)
		}
		draggedPanel.DeleteAsync(0);
	});

	$.RegisterEventHandler('DragDrop', $("#QuickBuyPanelItems"), function(panelId, draggedPanel) {
		if (draggedPanel.itemname != null) {
			SetQuickbuyTarget(draggedPanel.itemname)
		}
		draggedPanel.DeleteAsync(0);
	});
})()