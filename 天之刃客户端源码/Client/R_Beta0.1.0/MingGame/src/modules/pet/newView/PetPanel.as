package modules.pet.newView {
	import com.components.BasePanel;
	import com.events.WindowEvent;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.controls.TabNavigation;

	public class PetPanel extends BasePanel {
		private var nav:TabNavigation;
		public var petInfoView:PetInfoView;
		public var skillView:PetSkillView;
		public var petAptitudeView:PetAptitudeView;
		public var savvyView:PetSavvyView;
		public var petTrainingView:PetTrainingView;
		
		public function PetPanel() {
			initView();
		}
		
		private function initView():void{
			width = 578;
			height = 448;
			addImageTitle("");
			
			addTitleBG(446);
			addImageTitle("title_pet");
			addContentBG(6,8,18);
			
			//item
			petInfoView = new PetInfoView();
			skillView = new PetSkillView();
			petAptitudeView = new PetAptitudeView();

			savvyView = new PetSavvyView();
			
			petTrainingView = new PetTrainingView();
			nav=new TabNavigation();
			nav.tabBarPaddingLeft = 24;
			nav.addItem("信息",petInfoView, 76, 21);
			nav.addItem("技能",skillView, 76, 21);
			nav.addItem("洗灵",petAptitudeView, 76, 21);
			nav.addItem("提悟",savvyView, 76, 21);
			nav.addItem("训练",petTrainingView,76,21);
			nav.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onNavChangeHandler);
			addChild(nav);
			
			addEventListener(WindowEvent.OPEN,onOpen);
			addEventListener(WindowEvent.CLOSEED,onClose);
		}
		
		private function onNavChangeHandler(event:TabNavigationEvent):void{
			
		}
		
		public function set selectIndex(value:int):void{
			nav.selectedIndex = value;	
		}
		
		private function onOpen(event:WindowEvent):void{
			
		}
		
		private function onClose(event:WindowEvent):void{
			
		}
	}
}