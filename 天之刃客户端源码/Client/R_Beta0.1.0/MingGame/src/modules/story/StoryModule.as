package modules.story {
	import com.components.BasePanel;
	import com.scene.tile.Pt;
	
	import modules.BaseModule;
	import modules.story.cases.StoryFlyCase;

	public class StoryModule extends BaseModule {
		
		private static var instance:StoryModule;
		public static function getInstance():StoryModule{
			if(instance == null){
				instance = new StoryModule();
			}
			return instance;
		}
		
		public function StoryModule() {
		}
		
		public function showFly($pt:Pt,complete:Function=null):void{
			var storyFlyCase:StoryFlyCase = new StoryFlyCase();
			storyFlyCase.execute($pt,complete);
		}
	}
}