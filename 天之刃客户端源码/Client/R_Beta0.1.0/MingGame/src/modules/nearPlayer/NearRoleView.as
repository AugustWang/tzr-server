package modules.nearPlayer {
	import com.common.GlobalObjectManager;
	import com.components.DataGrid;
	import com.managers.Dispatch;
	import com.ming.events.ItemEvent;
	import com.ming.ui.controls.Button;
	import com.ming.ui.layout.LayoutUtil;
	import com.scene.sceneManager.SceneUnitManager;
	import com.scene.sceneUnit.IRole;
	import com.scene.sceneUnit.MyRole;
	import com.scene.sceneUnit.Role;
	import com.utils.ComponentUtil;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;

	import modules.ModuleCommand;
	import modules.chat.ChatModule;
	import modules.deal.DealModule;
	import modules.team.TeamModule;

	import proto.common.p_map_role;
	import proto.line.p_team_role;

	public class NearRoleView extends Sprite {
		private var grid:DataGrid;

		public function NearRoleView() {
			super();
			init();
		}

		public function init():void {
			grid=new DataGrid;
			grid.x=6;
			grid.y=3;
			grid.width=318;
			grid.height=292;
			grid.addColumn("玩家名字", 108);
			grid.addColumn("等级", 50);
			grid.addColumn("队伍", 50);
			grid.addColumn("国家", 50);
			grid.addColumn("操作", 60);
			grid.itemRenderer=NearPlayerItem;
			grid.pageCount=12;
			grid.itemHeight=24;
			grid.list.itemDoubleClickEnabled=true;
			grid.list.addEventListener(ItemEvent.ITEM_CLICK, onItemClick);
			addChild(grid);
			var sp:Sprite=new Sprite;
			sp.x=25;
			sp.y=312;
			addChild(sp);
			var refresh:Button=ComponentUtil.createButton("刷新", 256, -25, 65, 25, this);
			var chat:Button=ComponentUtil.createButton("私聊", 5, 0, 65, 25, sp);
			var follow:Button=ComponentUtil.createButton("跟随", 80, 0, 65, 25, sp);
			var friend:Button=ComponentUtil.createButton("好友", 150, 0, 65, 25, sp);
			var deal:Button=ComponentUtil.createButton("交易", 220, 0, 65, 25, sp);
			LayoutUtil.layoutHorizontal(sp, 8);
			refresh.addEventListener(MouseEvent.CLICK, refreshHandler);
//			team.addEventListener(MouseEvent.CLICK, doTeam);
			chat.addEventListener(MouseEvent.CLICK, doChat);
			follow.addEventListener(MouseEvent.CLICK, doFollow);
			friend.addEventListener(MouseEvent.CLICK, doFriend);
			deal.addEventListener(MouseEvent.CLICK, doDeal);
		}

		public function refreshHandler(e:MouseEvent=null):void {
			refreshRoles();
		}

		private function refreshRoles():void {
			var teamArr:Array=TeamModule.getInstance().members; //放p_team_role
			var roles:Array=[];
			var dict:Dictionary=SceneUnitManager.roleHash;
			for (var s:String in dict) {
				var role:IRole=dict[s];
				if (role is MyRole == false) {
					checkTeam(teamArr, role.pvo);
					roles.push(role.pvo);
				}
			}
			grid.dataProvider=roles;
		}

		private function checkTeam(teamArr:Array, pvo:p_map_role):void {
			for (var i:int=0; i < teamArr.length; i++) {
				if (pvo.role_id == p_team_role(teamArr[i]).role_id) {
					pvo.family_name=p_team_role(teamArr[i]).is_leader ? "队长" : "队员";
					pvo.faction_id=GlobalObjectManager.getInstance().user.base.faction_id;
					return;
				}
			}
			pvo.family_name=pvo.team_id == 0 ? "无" : "有";
			return;
		}

		private function onItemClick(e:ItemEvent):void {

		}

		private function doTeam(e:MouseEvent):void {
			var pvo:p_map_role=grid.list.selectedItem as p_map_role;
			if (pvo != null && pvo.team_id == 0) {
				Dispatch.dispatch(ModuleCommand.START_TEAM, {"role_id":pvo.role_id});
			}
		}

		private function doChat(e:MouseEvent):void {
			var pvo:p_map_role=grid.list.selectedItem as p_map_role;
			if (pvo != null) {
				ChatModule.getInstance().priChatHandler(pvo.role_name); //私聊
			}
		}

		private function doFollow(e:MouseEvent):void {
			var pvo:p_map_role=grid.list.selectedItem as p_map_role;
			if (pvo != null) {
				Dispatch.dispatch(ModuleCommand.FOLLOW, pvo.role_id);
			}
		}

		private function doFriend(e:MouseEvent):void {
			var pvo:p_map_role=grid.list.selectedItem as p_map_role;
			if (pvo != null) {
				Dispatch.dispatch(ModuleCommand.ADD_FRIEND, pvo.role_name);
			}
		}

		private function doDeal(e:MouseEvent):void {
			var pvo:p_map_role=grid.list.selectedItem as p_map_role;
			if (pvo != null) {
				DealModule.getInstance().requestDeal(pvo.role_id);
			}
		}
	}
}