package modules.sceneWarFb.view {
	import com.ming.core.IDataRenderer;
	import com.utils.ComponentUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import proto.common.p_scene_war_fb_role_info;

	public class PoyanghuTeamMember extends Sprite implements IDataRenderer {
		private var nameTxt:TextField;
		private var levelTxt:TextField;
		//private var inviteBtn:TextField
		private var _vo:p_scene_war_fb_role_info;

		public function PoyanghuTeamMember() {
			super();
			init();
		}

		private function init():void {
			var tf:TextFormat=new TextFormat(null, null, 0xAFE0EE, null, null, null, null, null, "center");
			nameTxt=ComponentUtil.createTextField("", 0, 0, tf, 120, 20, this);
			levelTxt=ComponentUtil.createTextField("", 121, 0, tf, 60, 20, this);
			//inviteBtn=ComponentUtil.createTextField("", 181, 0, tf, 120, 20, this);
			//inviteBtn.htmlText="<font color='#F6F5CD'><u>X</u></font>";
		}

		public function set data(value:Object):void {
			_vo=value as p_scene_war_fb_role_info;
			nameTxt.text=_vo.name;
			levelTxt.text=_vo.level.toString();
		}

		public function get data():Object {
			return _vo;
		}

	}
}