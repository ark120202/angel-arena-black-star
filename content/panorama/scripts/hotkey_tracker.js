Game.Events = {};

function GetKeybind(key) {
	var keyElement = $("#" + key);
	keyElement.visibility = "collapse";
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

function GenerateKeybind(defaultName, sign, command, defaultKey) {
	RegisterKeybind(command);
	var key = GetKeybind(defaultName)
	if (key === '') {
		key = defaultKey
	}
	Game.CreateCustomKeyBind(key, sign + command)
}

(function() {
	GenerateKeybind("ShopToggle", "+", "F4Pressed", "F4")
	GenerateKeybind("PurchaseQuickbuy", "+", "F5Pressed", "F5")
	GenerateKeybind("PurchaseSticky", "+", "F8Pressed", "F8")
})();
