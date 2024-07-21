package modules.team.view
{
	import com.common.GlobalObjectManager;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.globals.GameConfig;
	import com.managers.Dispatch;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.CheckBox;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	import modules.ModuleCommand;
	import modules.broadcast.views.Tips;
	import modules.system.SystemConfig;
	import modules.system.SystemModule;
	import modules.team.TeamConstant;
	import modules.team.TeamDataManager;
	import modules.team.TeamModule;
	import modules.team.view.items.MyTeamItem;
	
	import proto.line.p_team_role;

	public class MyTeamView extends Sprite
	{
		public static const BOTTOM_Y:int = 230;
		private var memberContainer:Sprite;
		
		private var autoTeam:CheckBox; //是否允许自动组队
		private var averageBtn:Button; //平均分配
		private var dismissBtn:Button; //解散队伍
		private var getOutBtn:Button; //请出队伍
		private var appointBtn:Button; //任命队长
		private var leaveBtn:Button; //离开队伍
		
		private var leaderItem:MyTeamItem;
		private var otherItems:Array;
		
		private var selectedBorder:Bitmap;
		private var selectedItem:MyTeamItem;
		
		private var menuCotainer:Sprite;
		private var autoJoin:CheckBox;
		private var createBtn:Button;
		
		public function MyTeamView()
		{
			addEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			Dispatch.register(ModuleCommand.UPDATE_TEAMGROUP,updateMembers);
			Dispatch.register(ModuleCommand.JOIN_TEAM,updateMembers);
			Dispatch.register(ModuleCommand.CHANGE_PICK_MODE,updatePickMode);
			Dispatch.register(ModuleCommand.SYSTEM_CONFIG_AUTO_TEAM_CHANGE,updateAutoTeam);
		}
		
		private function addedToStageHandler(event:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandler);
			initView();
			updateMembers();
		}
		
		private function initView():void{
			memberContainer = new Sprite();
			otherItems = [];
			for(var i:int = 0;i<5;i++){
				var memberItem:MyTeamItem = new MyTeamItem();
				memberItem.mouseChildren = false;
				memberItem.buttonMode = memberItem.useHandCursor = true;
				memberItem.addEventListener(MouseEvent.CLICK,selectedItemHandler);
				memberItem.x = (memberItem.width + 2)*i;
				memberContainer.addChild(memberItem);
				if(i == 0){
					memberItem.jobType = TeamConstant.TEAM_DZ;
					leaderItem = memberItem;
				}else{
					memberItem.jobType = TeamConstant.TEAM_DY;
					otherItems.push(memberItem);
				}
				memberItem.index = i;
			}
			memberContainer.y = 8;
			memberContainer.x = 4;
			addChild(memberContainer);
			
			autoTeam = ComponentUtil.createCheckBox("允许自动组队",20,210,this);
			autoTeam.addEventListener(Event.CHANGE,changeHandler);
			autoTeam.setSelected(SystemConfig.autoAcceptTeam);
			
			autoJoin = ComponentUtil.createCheckBox("允许自动入队",20,230,this);
			autoJoin.addEventListener(Event.CHANGE,autoJoinChangeHandler);
			autoJoin.setSelected(SystemConfig.autoTeam);
			
			createBtn = ComponentUtil.createButton("创建队伍",250,BOTTOM_Y,60,25,this);
			averageBtn = ComponentUtil.createButton("分配方式",createBtn.x+createBtn.width+6,BOTTOM_Y,60,25,this);
			dismissBtn = ComponentUtil.createButton("解散队伍",averageBtn.x+averageBtn.width+6,BOTTOM_Y,60,25,this);
			getOutBtn = ComponentUtil.createButton("请出队伍",dismissBtn.x+dismissBtn.width+6,BOTTOM_Y,60,25,this);
			appointBtn = ComponentUtil.createButton("任命队长",getOutBtn.x+getOutBtn.width+6,BOTTOM_Y,60,25,this);
			leaveBtn = ComponentUtil.createButton("离开队伍",appointBtn.x+appointBtn.width+6,BOTTOM_Y,60,25,this);
			
			createBtn.addEventListener(MouseEvent.CLICK,createHandler);
			averageBtn.addEventListener(MouseEvent.CLICK,averageHandler);
			dismissBtn.addEventListener(MouseEvent.CLICK,dismissHandler);
			getOutBtn.addEventListener(MouseEvent.CLICK,getOutHandler);
			appointBtn.addEventListener(MouseEvent.CLICK,appointHandler);
			leaveBtn.addEventListener(MouseEvent.CLICK,leaveHandler);
		}

		private function selectedItemHandler(event:MouseEvent):void{
			selectItem(event.currentTarget as MyTeamItem);
		}
		
		private function selectItem(item:MyTeamItem):void{
			if(item && item.data){
				if(selectedBorder == null){
					selectedBorder = Style.getBitmap(GameConfig.T1_VIEWUI,"team_selectdBg");
					memberContainer.addChild(selectedBorder);
				}
				selectedBorder.visible = true;
				selectedItem = item;
				selectedBorder.x = selectedItem.x-1;
				selectedBorder.y = selectedItem.y;
			}
		}
		
		private function changeHandler(event:Event):void{
			SystemConfig.autoAcceptTeam = autoTeam.selected;
			SystemConfig.save();
		}
		
		private function autoJoinChangeHandler(event:Event):void{
			SystemConfig.autoTeam = autoJoin.selected;
			SystemConfig.save();
			SystemModule.getInstance().teamCheckBoxChange();
		}
		
		private function createHandler(event:MouseEvent):void{
			TeamModule.getInstance().pro.createTeam(GlobalObjectManager.getInstance().user.attr.role_id);
		}
		
		private function averageHandler(event:MouseEvent):void{
			if(!TeamDataManager.isTeamLeader())return;
			if(menuCotainer == null){
				menuCotainer = new Sprite();
				menuCotainer.x = averageBtn.x;
				menuCotainer.y = averageBtn.y + averageBtn.height;
				var autoPick:Button = ComponentUtil.createButton("自由拾取",0,0,75,25,menuCotainer);
				var selfPick:Button = ComponentUtil.createButton("独自拾取",0,25,75,25,menuCotainer);
				autoPick.data = 1;
				selfPick.data = 2;
				autoPick.addEventListener(MouseEvent.CLICK,clickPickModeHandler);
				selfPick.addEventListener(MouseEvent.CLICK,clickPickModeHandler);
				addChild(menuCotainer);
			}else{
				menuCotainer.visible = !menuCotainer.visible;
			}
		}
		
		private function clickPickModeHandler(event:MouseEvent):void{
			var pickButton:Button = event.currentTarget as Button;
			if(TeamDataManager.pickMode != int(pickButton.data)){
				TeamModule.getInstance().pro.toChangePick(int(pickButton.data));
			}
			menuCotainer.visible = false;
		}
		
		private function dismissHandler(event:MouseEvent):void{
			TeamModule.getInstance().pro.toDisband();
		}
		
		private function getOutHandler(event:MouseEvent):void{
			if(selectedItem && selectedItem.data){
				var role:p_team_role = selectedItem.data as p_team_role;
				if(role.role_id != GlobalObjectManager.getInstance().user.attr.role_id){
					TeamModule.getInstance().pro.toKick(role.role_id);
				}
			}
		}
		
		private function appointHandler(event:MouseEvent):void{
			if(selectedItem && selectedItem.data){
				var role:p_team_role = selectedItem.data as p_team_role;
				if(role.role_id != GlobalObjectManager.getInstance().user.attr.role_id){
					TeamModule.getInstance().pro.toChangeLeader(role.role_id,role.role_name);
				}
			}			
		}

		private function leaveHandler(event:MouseEvent):void{
			if(selectedItem && selectedItem.data || !TeamDataManager.isTeamLeader()){
				var role:p_team_role = selectedItem.data as p_team_role;
				TeamModule.getInstance().pro.toLeave();
			}else{
				Tips.getInstance().addTipsMsg("请选中一位队员");
			}
		}
		
		private function updatePickMode():void{
			if(TeamDataManager.pickMode == 1){
				averageBtn.label = "自由拾取";
			}else{
				averageBtn.label = "独自拾取";
			}	
		}
		
		private function updateAutoTeam():void{
			if(autoJoin && autoJoin.selected != SystemConfig.autoTeam){
				autoJoin.setSelected(SystemConfig.autoTeam);
			}
		}
		
		public function updateMembers():void{
			var members:Array = TeamDataManager.teamMembers;
			if(members == null)return;
			updateButton();
			updatePickMode();
			var items:Array = otherItems.concat();
			if(members.length == 0){
				leaderItem.data = null;
			}
			for each(var role:p_team_role in members){
				if(role.is_leader){
					leaderItem.data = role;
				}else{
					MyTeamItem(items.shift()).data = role;
				} 
			}
			while(items.length > 0){
				MyTeamItem(items.shift()).data = null;
			}
			if(selectedItem && selectedItem.data == null && selectedBorder){
				selectedBorder.visible = false;
			}
		}
		
		private function updateButton():void{
			if(TeamDataManager.teamMembers.length > 0){
				createBtn.visible = false;
			}else{
				createBtn.visible = true;
			}
			if(TeamDataManager.isTeamLeader()){
				averageBtn.enabled = true;
				dismissBtn.enabled  = true;
				getOutBtn.enabled  = true;
				appointBtn.enabled  = true;
				leaveBtn.enabled  = true;
				autoJoin.enable = true;
			}else{
				averageBtn.enabled = false;
				dismissBtn.enabled  = false;
				getOutBtn.enabled  = false;
				appointBtn.enabled  = false;
				if(menuCotainer && menuCotainer.visible){
					menuCotainer.visible = false;
				}
				leaveBtn.enabled  = true;
				autoJoin.enable = false;
			}
		}
	}
}