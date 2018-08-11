Game.Events = {};

function GetKeybind(key) {
	var keyElement = $("#" + key);
	return keyElement.GetChild(0).text;
}

function RegisterKeybind(command) {
	Game.Events[command] = [];
	Game.AddCommand(command, function() {
		for (var key in Game.Events[command]) {
			Game.Events[command][key]();
		}
	}, '', 0);
}

function GenerateKeybind(defaultName, command) {
	RegisterKeybind(command);
	var key = GetKeybind(defaultName)
	if (key !== '') Game.CreateCustomKeyBind(key, command)
}

(function() {
	GenerateKeybind("ShopToggle", "F4Pressed")
	GenerateKeybind("PurchaseQuickbuy", "F5Pressed")
	GenerateKeybind("PurchaseSticky", "F8Pressed")
})();
