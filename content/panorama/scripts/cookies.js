Cookies = {
	operations: []
}

Cookies.Set = function(name, value) {
	GameEvents.SendCustomGameEventToServer("cookies_set", {
		name: name,
		value: value
	});
}
Cookies.Get = function(name) {
	return new Promise(function(resolve, reject) {
		GameEvents.SendCustomGameEventToServer("cookies_get", {
			name: name
		})
		var ent = {
			name: name
		};
		ent.call = function(value) {
			resolve(value)
		};
		Cookies.operations.push(ent);
	});
}

(function() {
	GameEvents.Subscribe("cookies_get", function(data) {
		$.Each(Cookies.operations, function(ent) {
			if (data.name == ent.name) {
				ent.call(data.value)
			}
		})
	})
})()

$.cookie = function(key, value) {
	if (value == null)
		return Cookies.Get(key)
	else
		return Cookies.Set(key, value)
}