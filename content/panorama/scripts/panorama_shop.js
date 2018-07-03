var ItemList = {},
	ItemData = {},
	SmallItems = [],
	SmallItemsAlwaysUpdated = [],
	SearchingFor = null,
	QuickBuyNotFinishedThisTick = true,
	QuickBuyData = [],
	BoughtQuickbuySmallItem = [],
	LastHero = null,
	ItemStocks = [],
	ItemCount = {};

function OpenCloseShop(newState) {
	if (typeof newState !== 'boolean') newState = !$('#ShopBase').BHasClass('ShopBaseOpen');
	$('#ShopBase').SetHasClass('ShopBaseOpen', newState);

	if (newState) {
		Game.EmitSound('Shop.PanelUp');
		UpdateShop();
		//$("#ShopBase").SetFocus();
	} else {
		Game.EmitSound('Shop.PanelDown');
		ClearSearch();
	}
}

function ClearSearch() {
	$.DispatchEvent('DropInputFocus', $('#ShopSearchEntry'));
	$('#ShopSearchEntry').text = '';
}

function SearchItems() {
	var searchStr = $('#ShopSearchEntry').text.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, '\\$&');
	if (SearchingFor !== searchStr) {
		SearchingFor = searchStr;
		var ShopSearchOverlay = $('#ShopSearchOverlay');
		_.each(ShopSearchOverlay.Children(), function(child) {
			child.DestroyItemPanel();
		});
		$.GetContextPanel().SetHasClass('InSearchMode', searchStr.length > 0);
		if (searchStr.length > 0) {
			var searchRegExp = new RegExp(_.escapeRegExp(searchStr), 'i');
			var foundItems = _.filter(_.keys(ItemData), function (itemName) {
				var localizedName = $.Localize('DOTA_Tooltip_ability_' + itemName);
				return !_.startsWith(itemName, 'item_recipe_') &&
					_.some(_.values(ItemData[itemName].names).concat(localizedName), function (title) {
						return title.search(searchRegExp) > -1;
					});
			});

			foundItems.sort(function(x1, x2) {
				return ItemData[x1].cost - ItemData[x2].cost;
			});
			_.each(foundItems, function(itemName) {
				SnippetCreate_SmallItem($.CreatePanel('Panel', ShopSearchOverlay, 'ShopSearchOverlay_item_' + itemName), itemName);
			});
		}
	}
}

function PushItemsToList() {
	var isTabSelected = false;
	_.each(ItemList, function(shopContent, shopName) {
		var TabButton = $.CreatePanel('RadioButton', $('#ShopTabs'), 'shop_tab_' + shopName);
		TabButton.AddClass('ShopTabButton');
		TabButton.style.width = (100 / Object.keys(ItemList).length) + '%';
		var TabButtonLabel = $.CreatePanel('Label', TabButton, '');
		TabButtonLabel.text = $.Localize('panorama_shop_shop_tab_' + shopName);
		TabButtonLabel.hittest = false;
		TabButton.SetPanelEvent('onactivate', (function(_shopName) {
			return function() {
				SelectShopTab(_shopName);
			};
		})(shopName));
		var TabShopItemlistPanel = $.CreatePanel('Panel', $('#ShopItemsBase'), 'shop_panels_tab_' + shopName);
		TabShopItemlistPanel.AddClass('ItemsPageInnerContainer');
		FillShopTable(TabShopItemlistPanel, shopContent);

		if (!isTabSelected) {
			SelectShopTab(shopName);
			TabButton.checked = true;
			isTabSelected = true;
		}
	});
}

function SelectShopTab(tabTitle) {
	_.each($('#ShopItemsBase').Children(), function(child) {
		child.SetHasClass('SelectedPage', child.id.replace('shop_panels_tab_', '') === tabTitle);
	});
}

function FillShopTable(panel, shopData) {
	for (var groupName in shopData) {
		var groupPanel = $.CreatePanel('Panel', panel, panel.id + '_group_' + groupName);
		groupPanel.AddClass('ShopItemGroup');
		_.each(shopData[groupName], function(itemName) {
			var itemPanel = $.CreatePanel('Panel', groupPanel, groupPanel.id + '_item_' + itemName);
			SnippetCreate_SmallItem(itemPanel, itemName);
			//groupPanel.AddClass("ShopItemGroup")
		});
	}
}

function SnippetCreate_SmallItem(panel, itemName, skipPush, onDragStart, onDragEnd) {
	panel.BLoadLayoutSnippet('SmallItem');
	if (itemName === '__indent__') {
		panel.style.opacity = 0;
		return;
	}
	panel.itemName = itemName;
	panel.FindChildTraverse('SmallItemImage').itemname = itemName;
	if (itemName.lastIndexOf('item_recipe', 0) === 0)
		panel.FindChildTraverse('SmallItemImage').SetImage('raw://resource/flash3/images/items/recipe.png');
	panel.SetPanelEvent('onactivate', function() {
		if (!$.GetContextPanel().BHasClass('InSearchMode')) {
			$('#ShopBase').SetFocus();
		}
		if (GameUI.IsAltDown()) {
			GameEvents.SendCustomGameEventToServer('custom_chat_send_message', {
				shop_item_name: panel.IsInQuickbuy ? panel.QuickBuyTarget : itemName,
				isQuickbuy: panel.IsInQuickbuy,
				gold: GetRemainingPrice(panel.IsInQuickbuy ? panel.QuickBuyTarget : itemName, {})
			});
		} else {
			ShowItemRecipe(itemName);
			if (GameUI.IsShiftDown()) {
				SetQuickbuyTarget(itemName, GameUI.IsControlDown());
			}
		}
	});
	panel.SetPanelEvent('oncontextmenu', function() {
		if (panel.BHasClass('CanBuy')) {
			if (!(panel.IsInQuickbuy && panel.itemBought)) {
				if(!panel.BHasClass('NotPurchasableItem')) {
					panel.itemBought = true;
					BoughtQuickbuySmallItem.push(panel);
				}
				SendItemBuyOrder(itemName);
			}
		} else {
			GameEvents.SendEventClientSide('dota_hud_error_message', {
				'splitscreenplayer': 0,
				'reason': 80,
				'message': '#dota_hud_error_not_enough_gold'
			});
			Game.EmitSound('General.NoGold');
		}
	});
	panel.SetPanelEvent('onmouseover', function() {
		ItemShowTooltip(panel);
	});
	panel.SetPanelEvent('onmouseout', function() {
		ItemHideTooltip(panel);
	});
	panel.DestroyItemPanel = function() {
		var id1 = SmallItemsAlwaysUpdated.indexOf(panel);
		var id2 = SmallItems.indexOf(panel);
		if (id1 > -1)
			SmallItemsAlwaysUpdated.splice(id1, 1);
		if (id2 > -1)
			SmallItems.splice(id2, 1);
		panel.visible = false;
		panel.DeleteAsync(0);
	};
	if (!panel.IsInQuickbuy) {
		$.RegisterEventHandler('DragStart', panel, function(panelId, dragCallbacks) {
			var itemName = panel.itemName;
			if (!onDragStart || onDragStart(panel)) {
				$.GetContextPanel().AddClass('DropDownMode');
				ItemHideTooltip(panel);
				var displayPanel = $.CreatePanel('DOTAItemImage', panel, 'dragImage');
				displayPanel.itemname = itemName;
				if (itemName.lastIndexOf('item_recipe_', 0) === 0)
					displayPanel.SetImage('raw://resource/flash3/images/items/recipe.png');

				dragCallbacks.displayPanel = displayPanel;
				dragCallbacks.offsetX = 0;
				dragCallbacks.offsetY = 0;
				return true;
			}
			return false;
		});

		$.RegisterEventHandler('DragEnd', panel, function(panelId, draggedPanel) {
			$.GetContextPanel().RemoveClass('DropDownMode');
			draggedPanel.DeleteAsync(0);
			!onDragEnd || onDragEnd(panel);
			return true;
		});
	}
	UpdateSmallItem(panel);
	if (!skipPush)
		SmallItems.push(panel);
	return panel;
}

function ShowItemRecipe(itemName) {
	var currentItemData = ItemData[itemName];
	if (currentItemData == null)
		return;
	var RecipeData = currentItemData.Recipe;
	var BuildsIntoData = currentItemData.BuildsInto;
	var DropListData = currentItemData.DropListData;
	_.each($('#ItemRecipeBoxRow1').Children(), function(child) {
		if (child.DestroyItemPanel != null)
			child.DestroyItemPanel();
		else
			child.DeleteAsync(0);
	});
	_.each($('#ItemRecipeBoxRow2').Children(), function(child) {
		if (child.DestroyItemPanel != null)
			child.DestroyItemPanel();
		else
			child.DeleteAsync(0);
	});
	_.each($('#ItemRecipeBoxRow3').Children(), function(child) {
		if (child.DestroyItemPanel != null)
			child.DestroyItemPanel();
		else
			child.DeleteAsync(0);
	});

	$('#ItemRecipeBoxRow1').RemoveAndDeleteChildren();
	$('#ItemRecipeBoxRow2').RemoveAndDeleteChildren();
	$('#ItemRecipeBoxRow3').RemoveAndDeleteChildren();

	var itemPanel = $.CreatePanel('Panel', $('#ItemRecipeBoxRow2'), 'ItemRecipeBoxRow2_item_' + itemName);
	SnippetCreate_SmallItem(itemPanel, itemName);
	itemPanel.style.align = 'center center';
	var len = 0;
	$('#ItemRecipeBoxDrops').visible = false;
	if (RecipeData != null && RecipeData.items != null) {
		_.each(RecipeData.items[1], function(childName) {
			var itemPanel = $.CreatePanel('Panel', $('#ItemRecipeBoxRow3'), 'ItemRecipeBoxRow3_item_' + childName);
			SnippetCreate_SmallItem(itemPanel, childName);
			itemPanel.style.align = 'center center';
		});
		len = Object.keys(RecipeData.items).length;
		if (RecipeData.visible && RecipeData.recipeItemName != null) {
			len++;
			var itemPanel = $.CreatePanel('Panel', $('#ItemRecipeBoxRow3'), 'ItemRecipeBoxRow3_item_' + RecipeData.recipeItemName);
			SnippetCreate_SmallItem(itemPanel, RecipeData.recipeItemName);
			itemPanel.style.align = 'center center';
		}
	} else if (DropListData != null) {
		$('#ItemRecipeBoxDrops').visible = true;
		_.each($('#ItemRecipeBoxDrops').Children(), function(pan) {
			var unit = pan.id.replace('ItemRecipeBoxDrops_', '');
			pan.enabled = DropListData[unit] != null;
			pan.RemoveAndDeleteChildren();
			if (DropListData[unit] != null)
				_.each(DropListData[unit], function(chance) {
					var chancePanel = $.CreatePanel('Label', pan, '');
					chancePanel.AddClass('UnitItemlikeRecipePanelChance');
					chancePanel.text = chance + '%';
				});
		});
	}
	$('#ItemRecipeBoxRow3').SetHasClass('ItemRecipeBoxRowLength7', len >= 7);
	$('#ItemRecipeBoxRow3').SetHasClass('ItemRecipeBoxRowLength8', len >= 8);
	$('#ItemRecipeBoxRow3').SetHasClass('ItemRecipeBoxRowLength9', len >= 9);
	if (BuildsIntoData != null) {
		_.each(BuildsIntoData, function(childName) {
			var itemPanel = $.CreatePanel('Panel', $('#ItemRecipeBoxRow1'), 'ItemRecipeBoxRow1_item_' + childName);
			SnippetCreate_SmallItem(itemPanel, childName);
			itemPanel.style.align = 'center center';
		});
		$('#ItemRecipeBoxRow1').SetHasClass('ItemRecipeBoxRowLength7', Object.keys(BuildsIntoData).length >= 7);
		$('#ItemRecipeBoxRow1').SetHasClass('ItemRecipeBoxRowLength8', Object.keys(BuildsIntoData).length >= 8);
		$('#ItemRecipeBoxRow1').SetHasClass('ItemRecipeBoxRowLength9', Object.keys(BuildsIntoData).length >= 9);
	}
}

function SendItemBuyOrder(itemName) {
	var playerId = Game.GetLocalPlayerID();
	var unit = Players.GetLocalPlayerPortraitUnit();
	unit = Entities.IsControllableByPlayer(unit, playerId) ? unit : Players.GetPlayerHeroEntityIndex(playerId);
	GameEvents.SendCustomGameEventToServer('panorama_shop_item_buy', {
		itemName: itemName,
		unit: unit,
		isControlDown: GameUI.IsControlDown()
	});
}

function ItemShowTooltip(panel) {
	$.DispatchEvent('DOTAShowAbilityTooltipForEntityIndex', panel, panel.itemName, Players.GetLocalPlayerPortraitUnit());
}

function ItemHideTooltip(panel) {
	$.DispatchEvent('DOTAHideAbilityTooltip', panel);
}

function LoadItemsFromTable(panorama_shop_data) {
	ItemList = panorama_shop_data.ShopList;
	ItemData = panorama_shop_data.ItemData;
	PushItemsToList();
}

function UpdateSmallItem(panel, gold) {
	try {
		var notpurchasable = !ItemData[panel.itemName].purchasable;
		panel.SetHasClass('CanBuy', GetRemainingPrice(panel.itemName, {}) <= (gold || PlayerTables.GetTableValue('gold', Game.GetLocalPlayerID())) || notpurchasable);
		panel.SetHasClass('NotPurchasableItem', notpurchasable);
		if (ItemStocks[panel.itemName] != null) {
			var CurrentTime = Game.GetGameTime();
			var RemainingTime = ItemStocks[panel.itemName].current_cooldown - (CurrentTime - ItemStocks[panel.itemName].current_last_purchased_time);
			var stock = ItemStocks[panel.itemName].current_stock;
			panel.FindChildTraverse('SmallItemStock').text = stock;
			if (stock === 0 && RemainingTime > 0) {
				panel.FindChildTraverse('StockTimer').text = Math.round(RemainingTime);
				panel.FindChildTraverse('StockOverlay').style.width = (RemainingTime / ItemStocks[panel.itemName].current_cooldown * 100) + '%';
			} else {
				panel.FindChildTraverse('StockTimer').text = '';
				panel.FindChildTraverse('StockOverlay').style.width = 0;
			}
		}
	} catch (err) {
		var index = SmallItems.indexOf(panel);
		if (index > -1)
			SmallItems.splice(index, 1);
		else {
			index = SmallItemsAlwaysUpdated.indexOf(panel);
			if (index > -1)
				SmallItemsAlwaysUpdated.splice(index, 1);
		}
	}
}

function GetRemainingPrice(itemName, ItemCounter, baseItem) {
	if (ItemCounter[itemName] == null)
		ItemCounter[itemName] = 0;
	ItemCounter[itemName] = ItemCounter[itemName] + 1;

	var itemCount = GetItemCountInInventory(Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID()), itemName, true);
	var val = 0;
	if (itemCount < ItemCounter[itemName] || !baseItem) {
		if (ItemData[itemName] == null) {
			throw new Error('Unable to find item ' + itemName + '!');
		}
		var RecipeData = ItemData[itemName].Recipe;
		if (RecipeData != null && RecipeData.items != null) {
			_.each(RecipeData.items[1], function(childName) {
				val += GetRemainingPrice(childName, ItemCounter, baseItem || itemName);
			});
			if (RecipeData.visible && RecipeData.recipeItemName != null) {
				val += GetRemainingPrice(RecipeData.recipeItemName, ItemCounter, baseItem || itemName);
			}
		} else {
			val += ItemData[itemName].cost;
		}
	}
	return val;
}

function QuickBuyInstance(QuickBuyTarget) {
	this.target = QuickBuyTarget;
	this.possibleAmount = ItemCount[QuickBuyTarget] || 0;
	this.oldpossibleAmount = ItemCount[QuickBuyTarget] || 0;
	this.requirements = {};
	this.smallItems = [];
	
	this.RefreshItem = QuickBuyData_RefreshQuickbuyItem;
	this.UpdateSmallItems = QuickBuyData_UpdateSmallItems;
	this.AcquireQuickbuyItem = QuickBuyData_AcquireQuickbuyItem;
	this.ClearItems = QuickBuyData_ClearItems;
	QuickBuyData.push(this);
}

function QuickBuyData_RefreshQuickbuyItem (ItemCounter) {
	
	var target = this.target;
	this.requirements = {};
	this.oldpossibleAmount = this.possibleAmount;
	this.possibleAmount = ItemCount[target] || 0;
	FindRequiredItems(this.requirements, target, ItemCounter, true, 0);
	
	this.UpdateSmallItems();
}

function QuickBuyData_UpdateSmallItems() {
	var requirements = _.clone(this.requirements);
	var quickBuyPanel = $('#QuickBuyPanelItems');
	var smallItems = this.smallItems;
	//unmark small items from RequiredItems/destroy un-needed smallItems
	var splices = [];
	for (var x = 0; x < smallItems.length; x++) {
		var item = smallItems[x];
		var itemName = item.itemName;
		if (itemName != null) {
			if (requirements[itemName] == null) {
				splices.push(item);
			} else {
				requirements[itemName] -= 1;
				if (requirements[itemName] <= 0) {
					delete requirements[itemName];
				}
			}
		}
	}
	for	(var x = 0; x < splices.length; x++) {
		var item = splices[x];
		smallItems.splice(smallItems.indexOf(item), 1);
		item.DestroyItemPanel();
	}
	for (var itemName in requirements) {
		for (var x = 0; x < requirements[itemName]; x++) {
			var itemPanel = $.CreatePanel('Panel', quickBuyPanel, "quickbuySmallItem");
			itemPanel.IsInQuickbuy = true;
			itemPanel.QuickBuyTarget = this.target;
			smallItems.push(itemPanel);
			SnippetCreate_SmallItem(itemPanel, itemName);
			itemPanel.AddClass('QuickbuyItemPanel');
			SmallItemsAlwaysUpdated.push(itemPanel);
		}
	}
}

function QuickBuyData_AcquireQuickbuyItem(itemName) {
	var target = this.target;
	if (this.possibleAmount > this.oldpossibleAmount || itemName == target) {
		this.ClearItems(true);
		return true;
	}
	return false;
}

function AcquireQuickbuyItem(itemName, owner) {
	var localPlayer = Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID())
	if (owner == localPlayer) {
		for (var x = 0; x < QuickBuyData.length; x++) {
			if (QuickBuyData[x].AcquireQuickbuyItem(itemName)) {
				QuickBuyNotFinishedThisTick = false;
				if (QuickBuyData.length > 0)
					RefreshQuickbuyItem(false);
				break;
			}
		}
	}
}

function QuickBuyData_ClearItems(deteteAfter) {
	for(var x = 0; x < this.smallItems.length; x++) {
		var child = this.smallItems[x];
		child.DestroyItemPanel();
	}
	if (deteteAfter)
		QuickBuyData.splice(QuickBuyData.indexOf(this), 1);
}

function SetQuickbuyStickyItem(itemName) {
	_.each($('#QuickBuyStickyButtonPanel').Children(), function(child) {
		child.DestroyItemPanel();
	});
	var itemPanel = $.CreatePanel('Panel', $('#QuickBuyStickyButtonPanel'), 'QuickBuyStickyButtonPanel_item_' + itemName);
	SnippetCreate_SmallItem(itemPanel, itemName, true);
	itemPanel.AddClass('QuickBuyStickyItem');
	SmallItemsAlwaysUpdated.push(itemPanel);
}

function ClearQuickbuyItems() {
	for	(var x = 0; x < QuickBuyData.length; x++) {
		QuickBuyData[x].ClearItems();
	}
	QuickBuyData = [];
}

//Returns a list of items where everything has combined
function AssumeCombinedItems(invItemList) {
	var combinedList = {};
	//traverse through invItemList
	for (var x = 0; x < invItemList.length; x++) {
		var itemName = invItemList[x];
		AddItemToCombinedItemList(combinedList, itemName);
	}
	return combinedList;
}

function AddItemToCombinedItemList(invCombinedList, itemName) {
	ObjectIntIncrement(invCombinedList, itemName);
	var currentItemData = ItemData[itemName];
	if(currentItemData == null)
		return;
	var buildsIntoData = currentItemData.BuildsInto;
	//traverse through possible combinations
	var finishedCombining = false;
	var combinedItem;
	if (buildsIntoData != null) {
		for (var y in buildsIntoData) {
			var buildsIntoName = buildsIntoData[y];
			var recipeData = ItemData[buildsIntoName].Recipe;
			//traverse through recipes
			if (recipeData != null && recipeData.items != null) {
				for (var z in recipeData.items) {
					var currentRecipeData = recipeData.items[z];
					var canComplete = true;
					var usedComponents = [];
					var recipeItemName = recipeData.recipeItemName;
					//check if can complete recipe
					for (var w in currentRecipeData) {
						var componentItemName = currentRecipeData[w];
						ObjectIntIncrement(usedComponents, componentItemName);
						if (invCombinedList[componentItemName] === undefined || invCombinedList[componentItemName] < usedComponents[componentItemName]) {
							canComplete = false;
							break;
						}
					}
					if (recipeData.visible && recipeItemName != null) {
						ObjectIntIncrement(usedComponents, recipeItemName);
						if (invCombinedList[recipeItemName] === undefined || invCombinedList[recipeItemName] < usedComponents[recipeItemName]) {
							canComplete = false;
							break;
						}
					}
					//if can, remove from list
					if(canComplete) {
						for (w in usedComponents) {
							invCombinedList[w] -= usedComponents[w];
						}
						finishedCombining = true;
						combinedItem = buildsIntoName;
						break;
					}
				}
				if(finishedCombining)
					break;
			}
			if(finishedCombining)
				break;
		}
	}
	if (finishedCombining) {
		AddItemToCombinedItemList(invCombinedList, combinedItem);
	}
}

function ResetBoughtPanels() {
	var quickBuyPanel = $('#QuickBuyPanelItems');
	_.each(BoughtQuickbuySmallItem, function(panel) {
		panel.itemBought = false;
	});
	BoughtQuickbuySmallItem.length = 0;
}

function RefreshQuickbuyItem(IsReset) {
	var ItemCounter = [];
	for(var x = 0; x < QuickBuyData.length; x++) {
		QuickBuyData[x].RefreshItem(ItemCounter);
	}
	ResetBoughtPanels();
}

//Find the items required to create the next complete item set. Returns RequiredItems.
function FindRequiredItems(RequiredItems, itemName, ItemCounter, isOriginalTarget) {
	var RecipeData = ItemData[itemName].Recipe;
	ObjectIntIncrement(ItemCounter, itemName);
	var itemCount = ItemCount[itemName] === undefined ? 0 : ItemCount[itemName];
	
	if(itemCount < ItemCounter[itemName] || isOriginalTarget) { //Will always check for required items if is original target
		if (RecipeData != null && RecipeData.items != null) {
			var recipeToUse = 1;
			if(itemName == "item_sange_and_yasha_and_kaya")
				recipeToUse = 2
			_.each(RecipeData.items[recipeToUse], function(childName) {
				FindRequiredItems(RequiredItems, childName, ItemCounter, false);
			});
			if (RecipeData.visible && RecipeData.recipeItemName != null) {
				FindRequiredItems(RequiredItems, RecipeData.recipeItemName, ItemCounter, false);
			}
		} else {
			//ObjectIntIncrement(RequiredItems, itemName);
			RequiredItems[itemName] = itemName in RequiredItems ? RequiredItems[itemName] + 1 : 1;
		}
	}
}

function SetQuickbuyTarget(itemName, multibuy) {
	if (!multibuy)
		ClearQuickbuyItems();
	Game.EmitSound('Quickbuy.Confirmation');
	new QuickBuyInstance(itemName);
	RefreshQuickbuyItem(true);
}

function ShowItemInShop(data) {
	if (data && data.itemName != null) {
		$('#ShopBase').AddClass('ShopBaseOpen');
		ShowItemRecipe(String(data.itemName));
	}
}

function UpdateShop() {
	SearchItems();
	UpdateItembuildsForHero();
	var gold = GetPlayerGold(Game.GetLocalPlayerID());
	_.each(SmallItemsAlwaysUpdated, function(panel) {
		UpdateSmallItem(panel, gold);
	});
	if ($('#ShopBase').BHasClass('ShopBaseOpen'))
		_.each(SmallItems, function(panel) {
			UpdateSmallItem(panel, gold);
		});
	//$.GetContextPanel().SetHasClass("InRangeOfShop", Entities.IsInRangeOfShop(m_QueryUnit, 0, true))
}

function AutoUpdateShop() {
	UpdateShop();
	$.Schedule(0.5, AutoUpdateShop);
	//OpenCloseShop(FindDotaHudElement("shop").BHasClass("ShopOpen"));
}

function OnInventoryUpdated() {
	var localPlayer = Players.GetPlayerHeroEntityIndex(Game.GetLocalPlayerID());
	var nflaggedEntities = [localPlayer, FindCourier(localPlayer)];
	var invItemList = GetItemsInFlaggedUnits (localPlayer, nflaggedEntities, true);
	var newItemCount = AssumeCombinedItems(invItemList);
	if (!_.isEqual(ItemCount, newItemCount)) {
		QuickBuyNotFinishedThisTick = true;
		ItemCount = newItemCount;
		if (QuickBuyData.length > 0)
			RefreshQuickbuyItem(false);
		return true;
	}
	return false;
}

function OnDotaInventoryChanged() {
	OnInventoryUpdated();
}

function OnArenaNewItem(args) {
	var item = args.item;
	var itemName = args.itemName;
	var notPurchasable = !(ItemData[itemName] && ItemData[itemName].purchasable)
	if (args.stackable || args.isDropped || notPurchasable) {
		AcquireQuickbuyItem(itemName, args.owner);
		ResetBoughtPanels();
	}
}

function OnDotaNewInventoryItem(args) {
	var itemIndex = args.entityIndex;
	var itemName = Abilities.GetAbilityName(itemIndex);
	var owner = Items.GetPurchaser(itemIndex);
	var stackable = Items.IsStackable(itemIndex);
	if (!stackable && (OnInventoryUpdated() || QuickBuyNotFinishedThisTick)) {
		AcquireQuickbuyItem(itemName, owner);
	}
}

function SetItemStock(item, ItemStock) {
	ItemStocks[item] = ItemStock;
}

(function() {
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, true);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_SHOP_SUGGESTEDITEMS, true);
	GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_QUICKBUY, true);
	Game.Events.F4Pressed.push(OpenCloseShop);
	GameEvents.Subscribe('panorama_shop_open_close', OpenCloseShop);
	Game.Events.F5Pressed.push(function() {
		if (QuickBuyData.length > 0) {
			var bought = false;
			var QuickBuyPanelItems = $('#QuickBuyPanelItems');
			var childCount = QuickBuyPanelItems.GetChildCount();
			for (var i = 0; i < childCount; i++) {
				var child = QuickBuyPanelItems.GetChild(i);
				if (!child.BHasClass('DropDownValidTarget')) {
					UpdateSmallItem(child);
					if (child.BHasClass('CanBuy')) {
						bought = true;
						if (!child.itemBought && !child.BHasClass('NotPurchasableItem')) {
							child.itemBought = true;
							SendItemBuyOrder(child.itemName);
							BoughtQuickbuySmallItem.push(child);
							break;
						}
					}
				}
			}
			if (!bought) {
				GameEvents.SendEventClientSide('dota_hud_error_message', {
					'splitscreenplayer': 0,
					'reason': 80,
					'message': '#dota_hud_error_not_enough_gold'
				});
				Game.EmitSound('General.NoGold');
			}
		}
	});
	Game.Events.F8Pressed.push(function() {
		SendItemBuyOrder($('#QuickBuyStickyButtonPanel').GetChild(0).itemName);
	});
	Game.MouseEvents.OnLeftPressed.push(function(ClickBehaviors, eventName, arg) {
		if (ClickBehaviors === CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE) {
			$('#ShopBase').RemoveClass('ShopBaseOpen');
		}
	});

	GameEvents.Subscribe('dota_inventory_changed', OnDotaInventoryChanged);
	GameEvents.Subscribe('dota_inventory_item_changed', OnDotaNewInventoryItem);
	GameEvents.Subscribe('arena_new_item', OnArenaNewItem);
	GameEvents.Subscribe('panorama_shop_show_item', ShowItemInShop);
	GameEvents.Subscribe('dota_link_clicked', function(data) {
		if (data != null && data.link != null && data.link.lastIndexOf('dota.item.', 0) === 0) {
			$('#ShopBase').AddClass('ShopBaseOpen');
			ShowItemRecipe(data.link.replace('dota.item.', ''));
		}
	});
	GameEvents.Subscribe('panorama_shop_show_item_if_open', function(data) {
		if ($('#ShopBase').BHasClass('ShopBaseOpen')) ShowItemInShop(data);
	});
	DynamicSubscribePTListener('panorama_shop_data', function(tableName, changesObject, deletionsObject) {
		if (changesObject.ShopList) {
			LoadItemsFromTable(changesObject);
			SetQuickbuyStickyItem('item_shard_level');
		};
		var stocksChanges = changesObject['ItemStocks_team' + Players.GetTeam(Game.GetLocalPlayerID())];
		if (stocksChanges) {
			for (var item in stocksChanges) {
				var ItemStock = stocksChanges[item];
				SetItemStock(item, ItemStock);
			}
		};
	});

	GameEvents.Subscribe('arena_team_changed_update', function() {
		var stockdata = PlayerTables.GetTableValue('panorama_shop_data', 'ItemStocks_team' + Players.GetTeam(Game.GetLocalPlayerID()));
		for (var item in stockdata) {
			var ItemStock = stockdata[item];
			SetItemStock(item, ItemStock);
		}
	});

	AutoUpdateShop();

	$.RegisterEventHandler('DragDrop', $('#QuickBuyStickyButtonPanel'), function(panelId, draggedPanel) {
		if (draggedPanel.itemname != null) {
			SetQuickbuyStickyItem(draggedPanel.itemname);
		}
		return true;
	});

	$.RegisterEventHandler('DragDrop', $('#QuickBuyPanelItems'), function(panelId, draggedPanel) {
		if (draggedPanel.itemname != null) {
			SetQuickbuyTarget(draggedPanel.itemname);
		}
		return true;
	});
})();
