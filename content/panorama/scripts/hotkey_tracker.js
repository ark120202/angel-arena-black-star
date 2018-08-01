'use strict';

function GetKeybind(key) {
	var keyElement = $.GetContextPanel().FindChildTraverse(key)
	keyElement.visible = false;
	return keyElement.GetChild(0).text;
}

function RegisterKeybind(command) {
	Game.Events[command] = [];
	Game.AddCommand('+' + command, function() {
		for (var key in Game.Events[command]) {
			Game.Events[command][key]();
		}
	}, '', 0);
	Game.AddCommand('-' + command, function() {}, '', 0);
}

function GenerateKeybind(defaultName, sign, command) {
	RegisterKeybind(command);
	Game.CreateCustomKeyBind(GetKeybind(defaultName), sign + command)
}

(function() {
	GenerateKeybind("ShopToggle", "+", "F4Pressed")
	GenerateKeybind("PurchaseQuickbuy", "+", "F5Pressed")
	GenerateKeybind("PurchaseSticky", "+", "F8Pressed")
})();
