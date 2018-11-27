function Console(panel) {
	this.panel = panel;
	this.codeEntry = panel.FindChildrenWithClassTraverse('content__entry')[0];
	this.stackLabel = panel.FindChildrenWithClassTraverse('content__stack')[0];
	this.playerList = panel.FindChildrenWithClassTraverse('header__js-player')[0];
	this.header = panel.FindChildrenWithClassTraverse('header__top')[0];

	var think = (function() {
		this.updateHeroes();
		$.Schedule(1, think);
	}).bind(this);
	think();

	this.setPinned(false);

	$.RegisterEventHandler('DragStart', this.header, this.onDragStart.bind(this));
	$.RegisterEventHandler('DragEnd', this.header, this.onDragEnd.bind(this));

	GameEvents.Subscribe('console-stack', function(event) {
		this.setStack(event.stack);
	}.bind(this));

	GameEvents.Subscribe('console-set-visible', function(event) {
		this.setVisible(event.value != null ? event.value : !this.isVisible());
	}.bind(this));
}

Console.prototype.setPinned = function(pinned) {
	this.header.SetDraggable(!pinned);
};

Console.prototype.isVisible = function() {
	return this.panel.BHasClass('console_visible');
};

Console.prototype.setVisible = function(visible) {
	this.panel.SetHasClass('console_visible', visible);
	if (visible && !this.opened) {
		this.opened = true;
		$.Schedule(1 / 30, (function() {
			// Save center position and reset it to fix dragging offset
			this.panel.style.position = this.panel.actualxoffset + 'px ' + this.panel.actualyoffset + 'px 0';
			this.panel.style.align = 'left top';
		}).bind(this));
	}
};

Console.prototype.setStack = function(stack) {
	this.stackLabel.text = '>>>\n' + stack;
};

Console.prototype.onDragStart = function(panelId, event) {
	event.displayPanel = this.panel;

	var cursor = GameUI.GetCursorPosition();

	event.offsetX = cursor[0] - this.panel.actualxoffset;
	event.offsetY = cursor[1] - this.panel.actualyoffset;
	event.removePositionBeforeDrop = false;
	return false;
};

Console.prototype.onDragEnd = function() {
	this.panel.SetParent($.GetContextPanel());
	this.setPinned(false);
	return true;
};

Console.prototype.updateHeroes = function() {
	var lines = _.map(Game.GetAllPlayerIDs(), function(playerId) {
		var team = Players.GetTeam(playerId);
		var line = '';
		line += playerId + ': ' + $.Localize(GetPlayerHeroName(playerId)) + ' - ' + Players.GetPlayerName(playerId);
		return line;
	});

	var generated = _.map(this.playerList.AccessDropDownMenu().Children(), function(panel) {
		return panel.text;
	});

	var playerList = this.playerList;

	if (!_.isEqualWith(generated, lines, _.isMatch)) {
		/**
		 * Regenerate all options if some are not matching
		 * Required to have consistent order
		 * TODO: More performant panel sorting with AddOption and RemoveOption
		 */

		playerList.RemoveAllOptions();

		_.each(lines, function(line) {
			var label = $.CreatePanel('Label', playerList, line.split(':')[0]);
			label.text = line;
			playerList.AddOption(label);
		});

		playerList.SetSelected(lines[0].split(':')[0]);
	}
};

Console.prototype.getCode = function() {
	return this.codeEntry.text;
};

Console.prototype.sendLua = function() {
	GameEvents.SendCustomGameEventToServer('console-evaluate', {
		type: 'lua',
		code: this.getCode(),
	})
};

Console.prototype.sendJS = function(target) {
	if (target === 'self') {
		try {
			this.setStack(eval(this.getCode()));
		} catch(err) {
			this.setStack(err.stack);
		}
		return;
	} else if (target === 'player') {
		target = this.playerList.GetSelected().id;
	}

	GameEvents.SendCustomGameEventToServer('console-evaluate', {
		type: 'js',
		target: target,
		code: this.getCode(),
	})
};

// Export 'con' variable, so it can be called from layout event handlers
var con = new Console($('#console'));

GameEvents.Subscribe('console-evaluate', function(event) {
	eval(event.code);
});
