package modules.pet.view
{
	
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.events.WindowEvent;
	import com.managers.Dispatch;
	import com.ming.events.TabNavigationEvent;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.TabNavigation;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import modules.pet.PetConstant;
	import modules.pet.PetModule;
	import modules.pet.newView.PetInfoView;
	import modules.playerGuide.GuideConstant;
	
	import proto.common.p_pet_id_name;
	import proto.line.m_pet_info_tos;
	
	public class PetPanel extends BasePanel
	{
		
		public var petInfoView:modules.pet.newView.PetInfoView;
		public var skillView:PetLearnSkillView;
		public var savvyView:PetSavvyView;
		public var aptitudeView:PetAptitudeView;
		public var feedView:PetFeedView;
		public var trickView:PetTrickSkillView;
		private var labels:Array;
		
		private var nav:TabNavigation;
		
		public function PetPanel(key:String=null)
		{
			super("");

		}
		
		override protected function init():void
		{
			width=558;
			height=490;
			
			addTitleBG(446);
			addImageTitle("title_pet");
			addContentBG(5,5,24);
			
			nav=new TabNavigation();
			petInfoView=new PetInfoView();
			skillView=new PetLearnSkillView();
			savvyView=new PetSavvyView();
			aptitudeView=new PetAptitudeView();
			feedView=new PetFeedView();
			trickView=new PetTrickSkillView;
			createNav();
			
			//变态需求 改变容器深度
			nav.addChild(nav.tabContainer);
			nav.x=10;
			nav.width=540;
			nav.height=440;//456
			nav.addEventListener(TabNavigationEvent.SELECT_TAB_CHANGED, onNavChangeHandler);
			addChild(nav);
			this.addEventListener(WindowEvent.OPEN,onOpen);
			this.addEventListener(WindowEvent.CLOSEED,onClose); 
			
		}
		
		public function createNav():void {
			if (nav.tabBar.buttonList.length > 0) {
				nav.tabBar.removeItems();
				nav.tabContainer.removeItems();
			}
			
				nav.addItem(PetConstant.PET_LABEL_INFO, petInfoView, 60, 25);
				nav.addItem(PetConstant.PET_LABEL_LEARN_SKILL, skillView, 60, 25);
				nav.addItem(PetConstant.PET_LABEL_REFRESH_APTITUDE, aptitudeView, 60, 25);
				nav.addItem(PetConstant.PET_LABEL_ADD_UNDERSTANDING, savvyView, 60, 25);
				nav.addItem(PetConstant.PET_LABEL_FEED, feedView, 60, 25);
//				nav.addItem("神技", trickView, 60, 25);

			var l:int=nav.tabBar.buttonList.length;
			labels=[];
			for (var i:int=0; i < l; i++) {
				labels.push(nav.tabBar.buttonList[i].label);
			}
		}
		
		public function seleteIndex(value:String):void {
			var index:int=0;
			if (value == "") {
				value = PetConstant.PET_LABEL_INFO;
			}
			switch (value) {
				case "":
					index=0;
					break;
				case PetConstant.PET_LABEL_INFO:
					index=labels.indexOf(PetConstant.PET_LABEL_INFO);
					break;
				case PetConstant.PET_LABEL_LEARN_SKILL:
					index=labels.indexOf(PetConstant.PET_LABEL_LEARN_SKILL);
					break;
				case PetConstant.PET_LABEL_REFRESH_APTITUDE:
					index=labels.indexOf(PetConstant.PET_LABEL_REFRESH_APTITUDE);
					break;
				case PetConstant.PET_LABEL_ADD_UNDERSTANDING:
					index=labels.indexOf(PetConstant.PET_LABEL_ADD_UNDERSTANDING);
					break;
				case PetConstant.PET_LABEL_FEED:
					index=labels.indexOf(PetConstant.PET_LABEL_FEED);
					break;
			}
			if (this.nav)
				this.nav.selectedIndex=index;
		}

		
		private function onNavChangeHandler(e:TabNavigationEvent):void {
			dispatchEvent(e);
			var btnLabel:String=nav.tabBar.buttonList[e.index].label;
			switch (btnLabel) {
				case PetConstant.PET_LABEL_INFO:
					toGetDefaultPetInfo(petInfoView.list);
					break;
				case PetConstant.PET_LABEL_REFRESH_APTITUDE:
					toGetDefaultPetInfo(aptitudeView.headerContent.list);
					aptitudeView.updateUseItemNum();
					break;
				case PetConstant.PET_LABEL_ADD_UNDERSTANDING:
					toGetDefaultPetInfo(savvyView.headerContent.list);
					savvyView.updateUseItemNum();
					break;
				case PetConstant.PET_LABEL_FEED:
					toGetDefaultPetInfo(feedView.headerContent.list);
					feedView.toGetFeedInfo();
					feedView.updateUseItemNum();
					break;
				case PetConstant.PET_LABEL_LEARN_SKILL:
					toGetDefaultPetInfo(skillView.headerContent.list);
					break;
			}
			
		}
		
		public function toGetDefaultPetInfo(list:List):void
		{
			if(list == null || list.dataProvider == null || list.dataProvider.length <= 0)
			{
				return;
			}
			else if(list.selectedIndex == -1 || list.selectedItem == null)
			{
				list.selectedIndex = 0;
				var ipname:p_pet_id_name=list.dataProvider[0] as p_pet_id_name;
				var vo2:m_pet_info_tos=new m_pet_info_tos;
				vo2.pet_id=ipname.pet_id;
				vo2.role_id=GlobalObjectManager.getInstance().user.base.role_id;
				PetModule.getInstance().send(vo2);
			}
		}
		
		private function onOpen(e:WindowEvent):void{
//			petInfoView.startAvatar();
//			skillView.startAvatar();
//			savvyView.startAvatar();
//			 aptitudeView.startAvatar();
//			 feedView.startAvatar();
			
		}
		
		private function onClose(e:WindowEvent):void{
//			petInfoView.stopAvatar();
//			skillView.stopAvatar();
//			savvyView.startAvatar();
//			aptitudeView.stopAvatar();
//			feedView.stopAvatar();
			Dispatch.dispatch(GuideConstant.CLOSE_PET_PANEL);
			
		}
		
	}
}