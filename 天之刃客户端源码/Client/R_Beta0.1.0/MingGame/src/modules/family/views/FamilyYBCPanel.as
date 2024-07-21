package modules.family.views
{
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.components.alert.Alert;
	import com.components.menuItems.GameMenuItems;
	import com.components.menuItems.MenuItemConstant;
	import com.components.menuItems.TargetRoleInfo;
	import com.ming.events.ItemEvent;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.Button;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import modules.family.FamilyConstants;
	import modules.family.FamilyLocator;
	import modules.family.FamilyYBCModule;
	import modules.family.views.items.YBCMember;
	
	import proto.line.p_family_ybc_member_info;
	
	public class FamilyYBCPanel extends BasePanel
	{
		private var members:DataGrid;
		private var hpBar:Shape;
		private var memberDatas:Array;
		private var buttonsContainer:Sprite;
		public function FamilyYBCPanel(key:String=null)
		{
			super();
//			this.panelSkin = Style.getInstance().panelSkinNoBg;
			this.title = "门派拉镖";
			width = 284;
			height = 380;
			
			var bgSkin:Sprite = Style.getBlackSprite(264,250);
			bgSkin.x = 10;
			bgSkin.y = 2;
			bgSkin.mouseChildren = true;
			addChild(bgSkin);
			
			members = new DataGrid();
			members.x = 1;
			members.y = 2;
			members.itemRenderer = YBCMember;
			members.width = 262;
			members.height = 240;
			members.addColumn("姓名",180);
			members.addColumn("状态",84);
			members.itemHeight = 25;
			members.pageCount = 9;
			members.list.addEventListener(ItemEvent.ITEM_CLICK,onItemClick);
			members.verticalScrollPolicy = ScrollPolicy.AUTO;
			bgSkin.addChild(members);
			
			buttonsContainer = new Sprite();
			buttonsContainer.y = 310;
			buttonsContainer.x = 12;
			addChild(buttonsContainer);
			var refresh:Button = ComponentUtil.createButton("刷新",12,0,60,26,buttonsContainer);
			refresh.addEventListener(MouseEvent.CLICK,onUpdate);
			var factionId:int = FamilyLocator.getInstance().getRoleID();
			if(factionId != FamilyConstants.ZY){
				var tip:Button = ComponentUtil.createButton("提醒帮众",7,0,60,26,buttonsContainer);
				tip.addEventListener(MouseEvent.CLICK,onTipMember);
				var remove:Button = ComponentUtil.createButton("踢除队员",74,0,65,26,buttonsContainer);
				remove.addEventListener(MouseEvent.CLICK,onRemove);
			}else{
				var exitButton:Button = ComponentUtil.createButton("退出镖队",74,0,65,26,buttonsContainer);
				exitButton.addEventListener(MouseEvent.CLICK,onExitHandler);
			}
//			var addHP:Button = ComponentUtil.createButton("给镖车加血",143,0,75,26,buttonsContainer);
			
//			addHP.addEventListener(MouseEvent.CLICK,onAddHP);
			
			LayoutUtil.layoutHorizontal(buttonsContainer,10);
			
			var text:TextField = ComponentUtil.createTextField("",12,260,null,258,NaN,this);
			text.wordWrap = true;
			text.multiline = true;
			text.htmlText = HtmlUtil.font("温馨提示：护送镖车到边城交给蓝玉将军，请保护好镖车，镖车血为零则任务失败，无法获得奖励且不退回押金。","#ffff00");
			
			
//			var hpBg:Skin = Style.getSkin("textSkin",GameConfig.T1_UI,new Rectangle(4,4,46,14));
//			hpBg.y = 330;
//			hpBg.x = 7;
//			hpBg.setSize(268,19);
//			addChild(hpBg);
//			
//			var hpBar:Shape = new Shape();
//			hpBar.x = hpBar.y = 2;
//			hpBg.addChild(hpBar);
//			var fillType:String = GradientType.LINEAR;
//			var colors:Array = [0x333333,0xFF0000];
//			var alphas:Array = [1, 1];
//			var ratios:Array = [0x00, 0xFF];
//			var matr:Matrix = new Matrix();
//			matr.createGradientBox(264, 15, Math.PI/2, 0, 0);
//			var spreadMethod:String = SpreadMethod.REFLECT;
//			hpBar.graphics.beginGradientFill(fillType, colors, alphas, ratios, matr, spreadMethod);  
//			hpBar.graphics.drawRect(0,0,264,15);
		}
		
		private var menuItems:Array;
		private var targetRoleInfo:TargetRoleInfo;
		private function onItemClick(event:ItemEvent):void{
			if(menuItems == null){
				menuItems=[MenuItemConstant.FOLLOW, MenuItemConstant.CHAT, MenuItemConstant.OPEN_FRIEND_CHAT, MenuItemConstant.SELECED, MenuItemConstant.DEAL, MenuItemConstant.REQUEST_GROUP,MenuItemConstant.APPLY_TEAM,MenuItemConstant.FLOWER, MenuItemConstant.VIEW_DETAIL, MenuItemConstant.FRIEND];
				targetRoleInfo =new TargetRoleInfo();
			}
			var member:p_family_ybc_member_info = event.selectItem as p_family_ybc_member_info;
			if(member.role_id != GlobalObjectManager.getInstance().user.attr.role_id){
				targetRoleInfo.roleId=member.role_id;
				targetRoleInfo.roleName=member.role_name;
				targetRoleInfo.faction_id=GlobalObjectManager.getInstance().user.base.faction_id;
				GameMenuItems.getInstance().show(menuItems, targetRoleInfo);
			}
		}
		
		public function setMembers(datas:Array):void{
			memberDatas = datas;
			memberDatas.sort(sortHandler);
			members.dataProvider = memberDatas;
		}
		
		public function setHP(percent:Number):void{
			hpBar.width = percent*266;
		}
		
		public function removeMember(roleId:int):void{
			if(memberDatas == null)return;
			for(var i:int=0;i<memberDatas.length;i++){
				var targetId:int = memberDatas[i].role_id;
				if(targetId == roleId){
					memberDatas.splice(i,1);
					break;
				}
			}
			members.dataProvider = memberDatas;
		}
		
		private function sortHandler(p1:p_family_ybc_member_info,p2:p_family_ybc_member_info):int{
			if(p1.status > p2.status){
				return 1;
			}else if(p1.status < p2.status){
				return -1;
			}else{
				return 0;
			}
		}
		
		private function onUpdate(event:MouseEvent):void{
			FamilyYBCModule.getInstance().getFamilyYBCMembers();
		}
		
		private function onRemove(event:MouseEvent):void{
			var item:p_family_ybc_member_info = members.list.selectedItem as p_family_ybc_member_info;
			if(item){
				Alert.show("你确定要踢除该队员？","提示",yesHandler);
			}
			function yesHandler():void{
				FamilyYBCModule.getInstance().kickMember(item.role_id);
			}
		}
		
		private function onTipMember(event:MouseEvent):void{
			var item:p_family_ybc_member_info = members.list.selectedItem as p_family_ybc_member_info;
			if(item){
				FamilyYBCModule.getInstance().alertMember(item.role_id);
			}
		}
		
		private function onExitHandler(event:MouseEvent):void{
			Alert.show("你确定要放弃此次拉镖活动？","提示",yesHandler);
			function yesHandler():void{
				FamilyYBCModule.getInstance().giveUpYBC();
			}
		}
			
		private function onAddHP(event:MouseEvent):void{
			
		}
	}
}