package modules.team.view
{
	import com.common.FilterCommon;
	import com.common.GlobalObjectManager;
	import com.managers.TimerManager;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.core.UIComponent;
	import com.scene.sceneManager.LoopManager;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.IRole;
	import com.scene.sceneUnit.MyRole;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	
	import modules.team.TeamModule;
	import modules.team.view.items.UnFullTeamItem;
	import modules.team.view.items.UnTeamMemberItem;
	
	public class NearTeamView extends Sprite
	{
		private var leftList:List;
		private var rightList:List;
		private var inited:Boolean = false;
		private var timeOut:int;
		public function NearTeamView()
		{
			addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE,removedToStageHandler);
		}
		
		private function addedToStageHandler(event:Event):void{
			if(inited == false){
				initView();
				inited = true;
			}
			TimerManager.getInstance().add(updateDatas,30);
			updateDatas();
		}
		
		private function removedToStageHandler(event:Event):void{
			TimerManager.getInstance().remove(updateDatas);
		}
		
		private function initView():void{
			var leftBg:UIComponent = ComponentUtil.createUIComponent(8,8,314,242);
			Style.setBorderSkin(leftBg);
			addChild(leftBg);
			
			var rightBg:UIComponent = ComponentUtil.createUIComponent(leftBg.x+leftBg.width+3,8,314,242);
			Style.setBorderSkin(rightBg);
			addChild(rightBg);
			
			var title:TextField = ComponentUtil.createTextField("未满人组队",8,5,Style.themeTextFormat,100,20,leftBg);
			title.textColor=0xffffff;
			title.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			var leftListTitle:TextField = ComponentUtil.createTextField("         队长         等级/人数         状态           操作",0,25,null,leftBg.width,25,leftBg);
			leftListTitle.textColor=0xfffd4b;
			leftListTitle.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			leftList = new List();
			leftList.bgSkin = null;
			leftList.x = 3;
			leftList.y = 50;
			leftList.itemHeight = 25;
			leftList.itemRenderer = UnFullTeamItem;
			leftList.verticalScrollPolicy = "on";
			leftList.width = leftBg.width - 6;
			leftList.height = leftBg.height - 55;
			leftBg.addChild(leftList);
			
			title = ComponentUtil.createTextField("未组队玩家",8,5,Style.themeTextFormat,100,20,rightBg);
			title.textColor=0xffffff;
			title.filters = FilterCommon.FONT_BLACK_FILTERS;
			
			var rightListTitle:TextField = ComponentUtil.createTextField("         角色名           等级           职业           操作",0,25,Style.centerTextFormat,rightBg.width,25,rightBg);
			rightListTitle.textColor=0xfffd4b;
			rightListTitle..filters = FilterCommon.FONT_BLACK_FILTERS;
			
			rightList = new List();
			rightList.bgSkin = null;
			rightList.x = 3;
			rightList.y = 50;
			rightList.itemHeight = 25;
			rightList.itemRenderer = UnTeamMemberItem;
			rightList.verticalScrollPolicy = "on";
			rightList.width = rightBg.width - 6;
			rightList.height = rightBg.height - 55;
			rightBg.addChild(rightList);
		}
		
		private function updateDatas():void{
			TeamModule.getInstance().pro.getNearbyTeam();
			var roles:Array=[];
			var roleHash:Dictionary = SceneUnitManager.roleHash;
			var factionId:int = GlobalObjectManager.getInstance().user.base.faction_id;
			for (var s:String in roleHash) {
				var role:IRole=roleHash[s];
				if (role is MyRole == false && role.pvo.faction_id == factionId && role.pvo.team_id == 0) {
					roles.push(role.pvo);
				}
			}
			rightList.dataProvider=roles;
		}
		
		public function updateNearbyTeam(datas:Array):void{
			leftList.dataProvider = datas;
		}
		
	}
}