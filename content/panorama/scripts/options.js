//Options.GetValue(name)
//Options.IsEquals(name, value)
//Options.Subscribe(name, function(value) {})
var Options = {
  container: {},
  callbacks: {},
  SetValue: function(name, value) {
    var callbacks = this.callbacks[name];
    if (this.container[name] !== value && callbacks)
      for (var i = 0; i < this.callbacks[name].length; i++) this.callbacks[name][i](value);
    this.container[name] = value;
  },
  DeleteValue: function(name) {
    delete this.container[name];
  },
  GetValue: function(name) {
    return this.container[name];
  },
  IsEquals: function(name, value) {
    if (value === undefined) return this.GetValue(name) === 1;
    else return (this.GetValue(name) === typeof value) === 'boolean' ? (value ? 1 : 0) : value;
  },
  Subscribe: function(name, callback) {
    if (!this.callbacks[name]) this.callbacks[name] = [];
    this.callbacks[name].push(callback);

    var cv = this.GetValue(name);
    if (cv) callback(cv);
  },
  GetMapInfo: function() {
    var name = Game.GetMapInfo().map_display_name;
    var underscoreIndex = name.indexOf('_');
    return {
      landscape: name.substr(0, underscoreIndex === -1 ? name.length : underscoreIndex),
      gamemode: name.substr((underscoreIndex === -1 ? name.length : underscoreIndex) + 1),
      name: name,
    };
  },
};

(function() {
  GameUI.CustomUIConfig().Options = Options;
  DynamicSubscribePTListener('options', function(tableName, changesObject, deletionsObject) {
    for (var k in changesObject) {
      Options.SetValue(k, changesObject[k]);
    }
    for (var k in deletionsObject) {
      Options.DeleteValue(k);
    }
  });
})();
