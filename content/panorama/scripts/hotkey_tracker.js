Game.Events = {};
var contextPanel = $.GetContextPanel();

function GetCommandName(name) {
  return 'arena_hotkey_' + _.snakeCase(name);
}

function GetKeyBind(name) {
  contextPanel.BCreateChildren('<DOTAHotkey keybind="' + name + '" />');
  var keyElement = contextPanel.GetChild(contextPanel.GetChildCount() - 1);
  keyElement.DeleteAsync(0);
  return keyElement.GetChild(0).text;
}

function RegisterKeyBindHandler(name) {
  Game.Events[name] = {};
  Game.AddCommand(
    GetCommandName(name),
    function() {
      for (var key in Game.Events[name]) {
        Game.Events[name][key]();
      }
    },
    '',
    0,
  );
}

function RegisterKeyBind(name, callback) {
  if (Game.Events[name] == null) {
    RegisterKeyBindHandler(name);
    var key = GetKeyBind(name);
    if (key !== '') Game.CreateCustomKeyBind(key, GetCommandName(name));
  }

  Game.Events[name][callback.name] = callback;
}

GameUI.CustomUIConfig().RegisterKeyBind = RegisterKeyBind;
