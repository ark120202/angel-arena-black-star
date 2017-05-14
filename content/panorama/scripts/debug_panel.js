(function() {
	GameEvents.Subscribe('debug_cprint', function(d) {
		$.Msg(d.text);
	});
})();
