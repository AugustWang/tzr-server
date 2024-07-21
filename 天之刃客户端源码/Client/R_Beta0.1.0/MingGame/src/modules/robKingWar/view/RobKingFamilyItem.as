package modules.robKingWar.view
{
	import com.common.GlobalObjectManager;
	import com.ming.core.IDataRenderer;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import proto.line.p_warofking_mark;
	
	public class RobKingFamilyItem extends Sprite implements IDataRenderer
	{
		private var _vo:p_warofking_mark;
		private var family_name:TextField;
		private var score:TextField;
		
		public function RobKingFamilyItem()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			family_name=new TextField;
			score=new TextField;
			score.x=96;
			addChild(family_name);
			addChild(score);
		}
		
		public function set data(obj:Object):void
		{
			var vo:p_warofking_mark=p_warofking_mark(obj);
			_vo=vo;
			if (vo.family_id == GlobalObjectManager.getInstance().user.base.family_id)
			{
				family_name.textColor=0x00ff00;
				score.textColor=0x00ff00;
			}
			else
			{
				family_name.textColor=0xff0000;
				score.textColor=0xff0000;
			}
			family_name.text=vo.family_name;
			score.text=vo.mark + "";
		}
		
		public function get data():Object
		{
			return _vo;
		}
	}
}