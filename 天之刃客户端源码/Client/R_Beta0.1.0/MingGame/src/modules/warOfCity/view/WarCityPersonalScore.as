package modules.warOfCity.view
{
	import com.common.GlobalObjectManager;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import proto.line.p_warofcity_role_mark;
	
	public class WarCityPersonalScore extends Sprite
	{
		private var _vo:p_warofcity_role_mark;
		private var role_name:TextField;
		private var score:TextField;
		
		public function WarCityPersonalScore()
		{
			super();
		}
		
		private function initView():void
		{
			role_name=new TextField;
			score=new TextField;
			score.x=96;
			addChild(role_name);
			addChild(score);
		}
		
		public function set data(obj:Object):void
		{
			var vo:p_warofcity_role_mark=p_warofcity_role_mark(obj);
			_vo=vo;
			if (vo.role_id == GlobalObjectManager.getInstance().user.base.role_id)
			{
				role_name.textColor=0x00ff00;
				score.textColor=0x00ff00;
			}
			else
			{
				role_name.textColor=0xff0000;
				score.textColor=0xff0000;
			}
			role_name.text=vo.role_name;
			score.text=vo.marks + "";
		}
		
		public function get data():Object
		{
			return _vo;
		}
	}
}