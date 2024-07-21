package modules.sceneWarFb.view {
	import com.common.GlobalObjectManager;
	import com.managers.Dispatch;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Button;
	import com.utils.ComponentUtil;

	import flash.display.Sprite;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import modules.ModuleCommand;

	import proto.common.p_scene_war_fb_role_info;

	public class PoyanghuNoTeamItem extends Sprite implements IDataRenderer {
		private var nameTxt:TextField;
		private var levelTxt:TextField;
		private var inviteBtn:TextField
		private var _vo:p_scene_war_fb_role_info;

		public function PoyanghuNoTeamItem() {
			super();
			init();
		}

		private function init():void {
			var tf:TextFormat=new TextFormat(null, null, 0xAFE0EE, null, null, null, null, null, "center");
			nameTxt=ComponentUtil.createTextField("", 0, 0, tf, 120, 20, this);
			levelTxt=ComponentUtil.createTextField("", 121, 0, tf, 60, 20, this);
			inviteBtn=ComponentUtil.createTextField("", 181, 0, tf, 120, 20, this);
			inviteBtn.mouseEnabled=true;
			inviteBtn.htmlText="<a href=\"event:invite\"><font color='#F6F5CD'><u>邀请组队</u></font></a>";
			inviteBtn.addEventListener(TextEvent.LINK, onLink);
		}

		private function onLink(e:TextEvent):void {
			Dispatch.dispatch(ModuleCommand.START_TEAM, {role_id: _vo.roleid, type_id: 0});
		}

		public function set data(obj:Object):void {
			_vo=obj as p_scene_war_fb_role_info;
			nameTxt.text=_vo.name;
			levelTxt.text=_vo.level.toString();
			inviteBtn.visible=_vo.roleid == GlobalObjectManager.getInstance().getRoleID() ? false : true;
		}

		public function get data():Object {
			return _vo;
		}
	}
}