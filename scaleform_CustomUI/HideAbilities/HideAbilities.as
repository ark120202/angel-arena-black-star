package {
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class HideAbilities extends MovieClip {
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;
		
		public function HideAbilities() : void {}
		
		public function onLoaded() : void {
			this.gameAPI.OnReady();
			var timer:Timer = new Timer(10);
			timer.addEventListener(TimerEvent.TIMER, HideEverything);
			timer.start();
		}
		
		public function HideEverything(e:TimerEvent) {
			globals.Loader_inventory.movieClip.inventory.stash_anim.stash.visible = false;
			var abilities:*= globals.Loader_actionpanel.movieClip.middle.abilities;
			for (var i:int = 0; i < abilities.numChildren; i++) {
				abilities.getChildAt(i).visible = false;
			}
		}
	}
}