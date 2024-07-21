package modules.family.views
{
	import com.common.Constant;
	import com.components.DataGrid;
	import com.components.DataGridColumn;
	import com.ming.ui.constants.ScrollPolicy;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.HtmlUtil;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.family.FamilyActItem;
	
	public class FamilyAlertPanel extends Sprite
	{
		private var list:DataGrid;
		public var BossState:TextField;
		public var ybState:TextField;
		public function FamilyAlertPanel()
		{
			super();
			init();
		}
		
		private function init():void
		{
			var tfy:TextFormat=new TextFormat(null, 12, 0xFFFFFF, null);
			ComponentUtil.createTextField("门派小提示", 187, 3, tfy, 78, 40, this);
			var txt:TextField=ComponentUtil.createTextField("", 0, 22, tfy, 446, 240, this);
			var str:String="1、创建门派需要50不绑定元宝，门派创建后即可拥有相应的门派地图；";
			str+="\n2、组织门派拉镖、打门派BOSS、门徒经常在线，可提升门派的繁荣度，增加门派资金；";
			str+="\n3、参加门派拉镖、打门派BOSS，可增加门派贡献度，凭门派贡献度可领取国运镖车，兑换商贸宝典；";
			str+="\n4、门派活动参与的人数越多，获得的奖励也越多。";
			txt.text=str;		
			
			var backBg:UIComponent = ComponentUtil.createUIComponent(0,155,459,150);
			Style.setBorderSkin(backBg);
			backBg.mouseEnabled = false;
			addChild(backBg);
			
			list = new DataGrid();
			list.x = 2;
			list.y = 2;
			list.width = 455;
			list.height = 147;
			list.itemHeight = 25;
			list.pageCount = 6;
			list.itemRenderer = FamilyActItem;
			list.verticalScrollPolicy = ScrollPolicy.ON;
			list.addColumn("门派活动名称",150);		
			list.addColumn("活动方式",124);	
			list.addColumn("完成情况",180);		
			backBg.addChild(list);
	
		}
		
		
		public function setFamilyData(everydayArr:Array):void{
			
			if(!everydayArr||everydayArr.length==0)
				return;
			list.dataProvider = everydayArr;
			list.list.selectedIndex = 0;
		}


		
		

	}
}