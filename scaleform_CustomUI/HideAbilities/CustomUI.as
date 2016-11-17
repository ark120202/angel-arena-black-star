package {
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import ValveLib.Globals;
	
	public class CustomUI extends MovieClip{
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;
		
		public function CustomUI() : void {
		}
		
		public function onLoaded() : void {
			this.gameAPI.OnReady();
			var timer:Timer = new Timer(10);
			timer.addEventListener(TimerEvent.TIMER, HideEverything);
			timer.start();
		}
		
		public function HideEverything(e:TimerEvent) {
			var abilities:*= globals.Loader_actionpanel.movieClip.middle.abilities;
			for (var i = 0; i <= 5; i++) {
				abilities["Ability" + i].visible = false;
				abilities["abilitybuild_ability" + i].visible = false;
				abilities["abilityBind" + i].visible = false;
				abilities["abilityMana" + i].visible = false;
				abilities["abilityLevelPips" + i].visible = false;
				abilities["abilityGold" + i].visible = false;
			}
		}
	}
}