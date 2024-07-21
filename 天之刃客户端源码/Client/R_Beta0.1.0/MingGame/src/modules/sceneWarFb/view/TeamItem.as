package modules.sceneWarFb.view {
	import com.common.GlobalObjectManager;
	import com.managers.Dispatch;
	import com.ming.core.IDataRenderer;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import modules.ModuleCommand;

	import proto.common.p_scene_war_fb_role_info;
	import proto.common.p_scene_war_fb_team_info;


	public class TeamItem extends Sprite implements IDataRenderer {
		private var nameTxt:TextField;
		private var levelTxt:TextField;
		private var teamNumTxt:TextField;
		private var joinBtn:Button;
		private var _vo:p_scene_war_fb_team_info;

		public function TeamItem() {
			super();
			var bg:UIComponent=new UIComponent;
			Style.setBorder1Skin(bg);
			bg.width=234;
			bg.height=60;
			addChild(bg);
			var tf:TextFormat=new TextFormat(null, null, 0xAFE0EE);
			nameTxt=ComponentUtil.createTextField("", 10, 0, tf, 150, 22, this);
			levelTxt=ComponentUtil.createTextField("", 10, 20, tf, 150, 22, this);
			teamNumTxt=ComponentUtil.createTextField("", 10, 40, tf, 150, 22, this);
			joinBtn=ComponentUtil.createButton("加   入", 156, 15, 60, 30, this);
			joinBtn.addEventListener(MouseEvent.CLICK, onClick);
		}

		private function onClick(e:MouseEvent):void {
			Dispatch.dispatch(ModuleCommand.APPLY_TEAM, {role_id: _vo.leader.roleid});
		}

		public function set data(value:Object):void {
			_vo=value as p_scene_war_fb_team_info;
			nameTxt.text="队长：" + _vo.leader.name + " (" + _vo.leader.level + "级)";
			var level:String;
			if (_vo.fb_level == 1) {
				level="20";
			} else if (_vo.fb_level == 2) {
				level="20-29";
			} else if (_vo.fb_level == 3) {
				level="30-39";
			}
			levelTxt.text=level + "级难度";
			teamNumTxt.text="队伍人数 " + (_vo.members.length + 1) + " / 6";
			joinBtn.enabled=GlobalObjectManager.getInstance().getTeamID() > 0 ? false : true;
		}

		public function get data():Object {
			return _vo;
		}
	}
}