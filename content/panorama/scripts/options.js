//Options.GetValue(name)
//Options.IsEquals(name, value)
//Options.Subscribe(name, function(value) {})
var Options = {
	container: {},
	callbacks: {},
	SetValue: function(name, value) {
		if (this.container[name] != value && callbacks[name])
			for (var i = 0; i < callbacks.length; i++)
				callbacks[i](value);
		this.container[name] = value;
	},
	GetValue: function(name) {
		return this.container[name]
	},
	IsEquals: function(name, value) {
		if (value === undefined)
			return this.GetValue(name) == true;
		else
			return this.GetValue(name) == value;
	},
	Subscribe: function(name, callback) {
		if (!this.callbacks[name]) this.callbacks[name] = [];
		this.callbacks[name].push(callback);
		var cv = this.GetValue(name);
		if (cv) callback(cv);
	}
};

(function() {
	GameUI.CustomUIConfig().Options = Options;
	DynamicSubscribePTListener("options", function(tableName, changesObject, deletionsObject) {
		for (var k in changesObject) {
			Options.SetValue(k, changesObject[k]);
		}
		/*for (var k in deletionsObject) {
			Options.SetValue(k, null);
		}*/
	})
})()