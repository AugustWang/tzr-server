package modules.nearPlayer {
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.components.menuItems.GameMenuItems;
	import com.components.menuItems.MenuItemConstant;
	import com.components.menuItems.TargetRoleInfo;
	import com.managers.Dispatch;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Button;
	import com.ming.ui.layout.LayoutUtil;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import modules.ModuleCommand;

	import proto.common.p_map_role;

	public class NearPlayerItem extends Sprite implements IDataRenderer {
		private var role_name:TextField;
		private var level:TextField;
		private var team:TextField;
		private var faction:TextField;
		private var teamBtn:Button;
		private var pvo:p_map_role;
		private var menuItems:Array;
		private var targetRoleInfo:TargetRoleInfo;

		public function NearPlayerItem() {
			super();
			var tf:TextFormat=Style.textFormat;
			tf.align="center";
			role_name=ComponentUtil.createTextField("", 0, 0, tf, 108, 22, this);
			level=ComponentUtil.createTextField("", 0, 0, tf, 50, 22, this);
			team=ComponentUtil.createTextField("", 0, 0, tf, 50, 22, this);
			faction=ComponentUtil.createTextField("", 0, 0, tf, 50, 22, this);
			teamBtn=ComponentUtil.createButton("组队", 0, 1, 45, 20, this);
			LayoutUtil.layoutHorizontal(this);
			role_name.mouseEnabled=true;
			role_name.addEventListener(MouseEvent.CLICK, onClick);
			teamBtn.addEventListener(MouseEvent.CLICK, onClickTeam);
			menuItems=[MenuItemConstant.FOLLOW, MenuItemConstant.CHAT, MenuItemConstant.OPEN_FRIEND_CHAT, MenuItemConstant.SELECED, MenuItemConstant.DEAL, MenuItemConstant.REQUEST_GROUP, MenuItemConstant.APPLY_TEAM, MenuItemConstant.FLOWER, MenuItemConstant.VIEW_DETAIL, MenuItemConstant.FRIEND, MenuItemConstant.INVITE_JOIN_FAMILY];
			targetRoleInfo=new TargetRoleInfo();
		}

		private function onClick(e:MouseEvent):void {
			targetRoleInfo.roleId=pvo.role_id;
			targetRoleInfo.roleName=pvo.role_name;
			targetRoleInfo.faction_id=pvo.faction_id;
			targetRoleInfo.pvo=pvo; //暂时不知道选中和跟随是怎么实现，所以这样便于参数传递
			targetRoleInfo.faction_id=pvo.faction_id;
			targetRoleInfo.family_id=pvo.family_id;
			targetRoleInfo.team_id=pvo.team_id;
			targetRoleInfo.sex=pvo.skin.skinid % 2 == 1 ? 1 : 2;
			GameMenuItems.getInstance().show(menuItems, targetRoleInfo);
		}

		private function onClickTeam(e:MouseEvent):void {
			if (teamBtn.label == "组队") {
				var obj:Object={role_id: pvo.role_id, type_id: 0};
				Dispatch.dispatch(ModuleCommand.START_TEAM, obj);
			} else if (teamBtn.label == "入队") {
				Dispatch.dispatch(ModuleCommand.APPLY_TEAM, {role_id: pvo.role_id});
			}
		}

		public function set data(obj:Object):void {
			var tf1:TextFormat=new TextFormat(null, null, 0xffffff);
			var tf2:TextFormat=new TextFormat(null, null, 0xff0000);
			var vo:p_map_role=p_map_role(obj);
			if (vo.family_id != 0 && vo.family_id == GlobalObjectManager.getInstance().user.base.family_id) {
				role_name.htmlText=HtmlUtil.font(vo.role_name, "#2FE1FE");
			} else {
				role_name.htmlText=HtmlUtil.font(vo.role_name, "#F6F5CD");
			}
			level.text=vo.level + "";
			team.text=vo.family_name; //由于p_map_role没有队员身份属性，暂时用门派名
			faction.text=GameConstant.getNation(vo.faction_id);
			if (vo.faction_id == GlobalObjectManager.getInstance().user.base.faction_id) {
				faction.setTextFormat(tf1);
			} else {
				faction.setTextFormat(tf2);
			}
			if (vo.faction_id == GlobalObjectManager.getInstance().getRoleFactionID()) {
				if (vo.team_id == 0) {
					teamBtn.label="组队";
					teamBtn.enabled=true;
				} else if (vo.team_id > 0 && GlobalObjectManager.getInstance().getTeamID() == 0) {
					teamBtn.label="入队";
					teamBtn.enabled=true;
				} else {
					teamBtn.label="组队";
					teamBtn.enabled=false;
				}
			} else {
				teamBtn.label="组队";
				teamBtn.enabled=false;
			}
			pvo=vo;
		}

		public function get data():Object {
			return pvo;
		}
	}
}