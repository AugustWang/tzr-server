package modules.factionsWar.views
{
	import com.common.GameConstant;
	import com.common.GlobalObjectManager;
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.ming.managers.ToolTipManager;
	import com.utils.ComponentUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.factionsWar.FactionWarDataManager;
	import modules.factionsWar.views.items.FactionGuardsItem;
	
	public class FactionGuardsView extends BasePanel
	{
		private var grid:DataGrid;
		private var factionMoney:TextField;
		
		public function FactionGuardsView(key:String=null)
		{
			super(key);
			this.title="请选择国战守卫"
			initView();
		}
		
		private function initView():void
		{
			this.width=340;
			this.height=244;
			var bg1:Sprite=Style.getBlackSprite(320, 167, 6);
			var bg2:Sprite=Style.getBlackSprite(320, 30, 6);
			bg1.x=10;
			bg1.y=2;
			bg2.x=10;
			bg2.y=171;
			addChild(bg1);
			addChild(bg2);
			grid=new DataGrid;
			grid.x=2;
			grid.y=2;
			grid.width=316;
			grid.height=166;
			grid.itemHeight=21;
			grid.addColumn("当前可招募 ", 120);
			grid.addColumn("消耗国库银", 120);
			grid.addColumn("操作", 76);
			grid.itemRenderer=FactionGuardsItem;
			grid.list.verticalScrollPolicy="off";
			bg1.addChild(grid);
			var tf:TextFormat=new TextFormat(null, null, 0xAFE0EE, null, null, null, null, null, "right");
			factionMoney=ComponentUtil.createTextField("当前国库银子0锭0两0文", 2, 4, tf, 314, 22, bg2);
			factionMoney.mouseEnabled = true;
			factionMoney.addEventListener(MouseEvent.MOUSE_OVER, showFactionMoneyToolTip);
			factionMoney.addEventListener(MouseEvent.MOUSE_OUT, hideFactionMoneyToolTip);
		}
		private var guards:Array;
		private var levels:Array=["一", "二", "三", "四", "五", "六", "七"];
		private var moneys:Array=[0, 5, 10, 15, 20, 30, 40, 50];
		
		private function showFactionMoneyToolTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().show("国库最大容量120锭，每天固定获得税收20锭");
		}
		
		private function hideFactionMoneyToolTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		public function update(max_level:int, isLeft:Boolean):void
		{
			guards=[];
			var dir:String=isLeft ? "左" : "右";
			for (var i:int=1; i <= max_level; i++)
			{
				var t:String=levels[i - 1] + "级" + GameConstant.getNation(GlobalObjectManager.getInstance().user.base.faction_id) + "守卫（" + dir + "哨）";
				var op:String="<font color='#00ff00'><a href='event:zhaomu'><u>招募</u></a></font>"
				var obj:Object={g:t, m:moneys[i], o:op,level:i,left:isLeft};
				guards.push(obj);
			}
			guards.reverse();
			grid.dataProvider=guards;
			factionMoney.text="当前国库银子" + MoneyTransformUtil.silverToOtherString(FactionWarDataManager.factionMoney);
		}
	}
}