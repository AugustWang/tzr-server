package modules.robKingWar.view
{
	import com.common.GlobalObjectManager;
	import com.globals.GameConfig;
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.Image;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import proto.line.m_warofking_getmarks_toc;
	import proto.line.p_warofking_mark;
	
	public class RobKingResult extends Sprite
	{
		private var bg:Image;
		private var txt:TextField;
		private var list:List;
		
		public function RobKingResult()
		{
			super();
			initView();
		}
		
		private function initView():void
		{
			bg=new Image;
			bg.source=GameConfig.ROOT_URL + "com/ui/robKing/robKingResult.png";
			addChild(bg);
			txt=new TextField;
			txt.selectable=false;
			txt.textColor=0xffffff;
			txt.text="王座积分";
			txt.x=70;
			txt.y=7;
			addChild(txt);
			list=new List;
			list.bgSkin=null;
			list.itemRenderer=RobKingFamilyItem;
			list.x=24;
			list.y=40;
			list.width=140;
			list.height=120;
			addChild(list);
			this.mouseChildren=false;
			this.mouseEnabled=false;
		}
		
		public function update(vo:m_warofking_getmarks_toc):void
		{
			vo.result.sortOn("mark", Array.DESCENDING|Array.NUMERIC);
			list.dataProvider=vo.result;
		}
		
		public function onStageResize():void
		{
			this.x = GlobalObjectManager.GAME_WIDTH - 178;
		}
	}
}