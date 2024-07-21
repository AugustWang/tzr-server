package modules.warOfCity.view
{
	import com.ming.ui.containers.List;
	import com.ming.ui.controls.core.UIComponent;
	
	import flash.display.Sprite;
	
	import com.utils.ComponentUtil;
	
	import proto.line.m_warofcity_get_mark_toc;
	
	public class WarCityScoreView extends Sprite
	{
		private var family:List;
		private var personal:List;
		
		public function WarCityScoreView()
		{
			super();
			init();
		}
		
		private function init():void
		{
			var ui:UIComponent=new UIComponent;
			Style.setRectBorder(ui);
			var ui2:UIComponent=new UIComponent;
			Style.setRectBorder(ui2);
			ui.width=130;
			ui.height=90;
			ui.alpha=0.6;
			ui2.width=130;
			ui2.height=90;
			ui2.x=132;
			ui2.alpha=0.6;
			addChild(ui);
			addChild(ui2);
			ComponentUtil.createTextField("门派积分",26,2,null,80,22,this);
			ComponentUtil.createTextField("个人积分",157,2,null,80,22,this);
//			this.graphics.beginFill(0x000000, 0.6);
//			this.graphics.drawRect(0, 0, 130, 90);
//			this.graphics.endFill();
//			this.graphics.beginFill(0x000000, 0.6);
//			this.graphics.drawRect(151, 0, 130, 90);
//			this.graphics.endFill();
			family=new List;
			family.bgSkin=null;
			family.itemRenderer=WarCityFamilyScore;
			family.x=6;
			family.y=24;
			family.width=130;
			family.height=90;
			addChild(family);
			personal=new List;
			personal.bgSkin=null;
			personal.itemRenderer=WarCityPersonalScore;
			personal.x=157;
			personal.y=24;
			personal.width=130;
			personal.height=90;
			addChild(personal);
			this.mouseChildren=false;
			this.mouseEnabled=false;
		}
		
		public function update(vo:m_warofcity_get_mark_toc):void
		{
			vo.families.sortOn("marks", Array.DESCENDING | Array.NUMERIC);
			vo.roles.sortOn("marks", Array.DESCENDING | Array.NUMERIC);
			family.dataProvider=vo.families;
			personal.dataProvider=vo.roles;
		}
	}
}