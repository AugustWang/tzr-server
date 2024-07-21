package modules.family.views
{
	import com.components.BasePanel;
	import com.ming.ui.containers.Canvas;
	import com.ming.ui.layout.LayoutUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import modules.family.views.items.FamilySkillItem;
	import modules.skill.SkillConstant;
	import modules.skill.SkillDataManager;

	public class FamilySkillInfoPanel extends BasePanel
	{
		private var canvas:Canvas
		private var text:TextField;
		public function FamilySkillInfoPanel()
		{
		}
		
		public function initView():void{
			this.title = "门派技能介绍";
			this.width = 524;
			this.height = 320;
			
			this.panelSkin = Style.getInstance().panelSkin;
			
//			var uiLeft:Sprite = Style.getViewBg("npc_bg");
//			uiLeft.x=9;
//			this.addChild(uiLeft);
//			
//			var uiRight:Sprite = Style.getViewBg("npc_bg");
//			uiRight.x=263;
//			this.addChild(uiRight)
			
			text = new TextField();
			text.height = 245;
			text.width = 210;
			text.x = 286;
			text.y = 27;
			text.defaultTextFormat = Style.textFormat;
			text.selectable = false;
			text.mouseEnabled = false;
			text.htmlText = "<font color='#FFF673'>1.门派等级越高，可以研究的技能个数、技能等级越高。\n2.研究技能需要扣取门派资金和门派繁荣度。\n3.只有门派研究过的技能才能学习。个人学习门派技能，需要扣取一定的个人资金和门派贡献度。</font>\n<font color='#ff0000'>4.个人离开门派之后，已学习的门派技能将会消失！</font>";
			text.wordWrap = true;
			addChild(text);
			
			canvas = new Canvas();
			canvas.x = 24;
			canvas.y = 12;
			canvas.width = 226;
			canvas.height = 260;
			addChild(canvas);
			var sp:Sprite = new Sprite();
			var array:Array = SkillDataManager.getCategory(SkillConstant.CATEGORY_FAMILY);
			for( var i:int = 0; i < array.length; i++ ){
				var item:FamilySkillItem = new FamilySkillItem();
				item.initView(FamilySkillItem.INFO);
				item.data = array[i];
				sp.addChild(item);
			}
			
			LayoutUtil.layoutGrid(sp, 2, 46, 23);
			sp.x = 30;
			sp.y = 30;
			canvas.addChild(sp);
		}
	}
}