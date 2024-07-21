package modules.factionsWar.views
{
	import com.common.GameConstant;
	import com.components.BasePanel;
	import com.components.DataGrid;
	import com.components.LoadingSprite;
	import com.components.alert.Alert;
	import com.events.ParamEvent;
	import com.managers.WindowManager;
	import com.ming.managers.ToolTipManager;
	import com.ming.ui.controls.Button;
	import com.ming.ui.controls.core.UIComponent;
	import com.utils.ComponentUtil;
	import com.utils.DateFormatUtil;
	import com.utils.MoneyTransformUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import modules.factionsWar.FactionWarDataManager;
	import modules.factionsWar.views.items.FactionGuardsItem;
	import modules.factionsWar.views.items.FactionPropItem;
	import modules.shop.ShopConstant;
	import modules.shop.ShopModule;
	
	import proto.line.m_waroffaction_record_toc;
	import proto.line.m_waroffaction_warinfo_toc;
	
	public class FactionsWarView extends LoadingSprite
	{
		public static const ASKWARINFO_EVENT:String="ASKWARINFO_EVENT";
		public static const DECLAREWAR_EVENT:String="DECLAREWAR_EVENT";
		public static const BUYGUARDER_EVENT:String="BUYGUARDER_EVENT";
		public static const ASKRECORD_EVENT:String="ASKRECORD_EVENT";
		
		private var guardLevels:Array=["", "一", "二", "三", "四", "五", "六", "七"];
		
		private var recordView:FactionWarRecordView; //国战记录界面
		private var otherGuardView:FactionGuardsView; //其他守卫界面
		private var warRecordBtn:Button;
		private var declareWarBtn1:Button;
		private var declareWarBtn2:Button;
		private var recruitBtn1:Button;
		private var recruitBtn2:Button;
		private var recruitOtherBtn1:Button;
		private var recruitOtherBtn2:Button;
		private var layBtn:Button;
		private var dongtai:TextField; //国战动态
		public var factionMoneyTxt:TextField; //国库库银
		private var grid:DataGrid;
		private var factionID:int;
		
		private var pvo:m_waroffaction_warinfo_toc;
		
		public function FactionsWarView()
		{
			super();
			initView();
			var e:ParamEvent=new ParamEvent(ASKWARINFO_EVENT);
			this.dispatchEvent(e);
			setLoadingSize(461,314);
		}
		
		private function initView():void
		{
			var bg1:UIComponent = ComponentUtil.createUIComponent(5,5,455,50);
			var bg2:UIComponent = ComponentUtil.createUIComponent(5,bg1.y+bg1.height+4,455,60);
			var bg3:UIComponent = ComponentUtil.createUIComponent(5,bg2.y+bg2.height+4,455,158);
			var bg4:UIComponent = ComponentUtil.createUIComponent(5,bg3.y+bg3.height+4,455,26);
			Style.setBorderSkin(bg1);
			Style.setBorderSkin(bg2);
			Style.setBorderSkin(bg3);
			Style.setBorderSkin(bg4);
			addChild(bg1);
			addChild(bg2);
			addChild(bg3);
			addChild(bg4);
			
			var tf:TextFormat=new TextFormat(null, null, 0xAFE0EE);
			ComponentUtil.createTextField("国战动态：", 7, 4, tf, NaN, 22, bg1);
			dongtai=ComponentUtil.createTextField("", 7, 28, tf, 330, 22, bg1);
			warRecordBtn=ComponentUtil.createButton("查看国战记录", 340, 6, 106, 25, bg1);
			warRecordBtn.addEventListener(MouseEvent.CLICK, toLookRecord);
			
			ComponentUtil.createTextField("国战操作：", 7, 4, tf, NaN, 22, bg2);	
			var factionWarDescBtn:Button = ComponentUtil.createButton("国战说明", 360, 4, 70, 25, bg2);
			
			declareWarBtn1=ComponentUtil.createButton("向沧州发起国战", 10, 30, 110, 25, bg2);
			declareWarBtn2=ComponentUtil.createButton("向幽州发起国战", declareWarBtn1.x+declareWarBtn1.width+5, 30, 110, 25, bg2);
			declareWarBtn1.addEventListener(MouseEvent.CLICK, onClickDeclare1);
			declareWarBtn2.addEventListener(MouseEvent.CLICK, onClickDeclare2);
			var buyMPL:Button = ComponentUtil.createButton("购买门派令", declareWarBtn2.x+declareWarBtn2.width+5, 30, 100, 25, bg2);
			var buyGZZJL:Button = ComponentUtil.createButton("购买国战征集令", buyMPL.x+buyMPL.width+5, 30, 100, 25, bg2);
			buyMPL.addEventListener(MouseEvent.CLICK,buyMPLHandler);
			buyGZZJL.addEventListener(MouseEvent.CLICK,buyGZZJLHandler);
			
			grid=new DataGrid;
			grid.x=2;
			grid.y=2;
			grid.width=455;
			grid.height=153;
			grid.itemHeight=20;
			grid.addColumn("国战设施", 120);
			grid.addColumn("当前状态", 120);
			grid.addColumn("消耗国银", 120);
			grid.addColumn("操作", 97);
			grid.itemRenderer=FactionPropItem;
			grid.list.selected=false;
			bg3.addChild(grid);
			
			var tf2:TextFormat=new TextFormat(null, null, 0xAFE0EE, null, null, null, null, null, "right");
			factionMoneyTxt=ComponentUtil.createTextField("当前国库银0锭0两0文", 2, 4, tf2, 440, 22, bg4);
			factionMoneyTxt.mouseEnabled = true;
			factionMoneyTxt.addEventListener(MouseEvent.MOUSE_OVER, showFactionMoneyToolTip);
			factionMoneyTxt.addEventListener(MouseEvent.MOUSE_OUT, hideFactionMoneyToolTip);
			
		}
		
		private function buyGZZJLHandler(event:MouseEvent):void{
			ShopModule.getInstance().requestShopItem(ShopConstant.TYPE_SUNDRY,11600004,new Point(stage.mouseX-178, stage.mouseY-90));
		}
		
		private function buyMPLHandler(event:MouseEvent):void{
			ShopModule.getInstance().requestShopItem(ShopConstant.TYPE_SUNDRY,11600002,new Point(stage.mouseX-178, stage.mouseY-90));
		}
		
		private function showFactionMoneyToolTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().show("国库最大容量120锭，每天固定获得税收20锭");
		}
		
		private function hideFactionMoneyToolTip(e:MouseEvent):void
		{
			ToolTipManager.getInstance().hide();
		}
		
		public function update(vo:m_waroffaction_warinfo_toc):void
		{
			removeDataLoading();
			this.pvo=vo;
			var i:int, j:int;
			if (vo.dest_faction_id > 0)
			{
				var f:String=GameConstant.getNation(vo.dest_faction_id);
				if (vo.is_attack_faction == true)
				{
					dongtai.text="我国向" + f + "宣战，战争将于" + DateFormatUtil.format(vo.next_war_tick) + "开始";
				}
				else
				{
					dongtai.text=f + "向我国宣战，战争将于" + DateFormatUtil.format(vo.next_war_tick) + "开始";
				}
			}
			declareWarBtn1.enabled=vo.declare_war1;
			declareWarBtn2.enabled=vo.declare_war2;
			//TODO 显示国库的银子
			//TODO 显示国战开始时间
			switch (vo.faction_id)
			{
				case 1:
					declareWarBtn1.label="向沧州发起国战";
					declareWarBtn2.label="向幽州发起国战";
					break;
				case 2:
					declareWarBtn1.label="向云州发起国战";
					declareWarBtn2.label="向幽州发起国战";
					break;
				case 3:
					declareWarBtn1.label="向云州发起国战";
					declareWarBtn2.label="向沧州发起国战";
					break;
				default:
					break;
			}
			grid.dataProvider=createDataProvider(vo);
			FactionWarDataManager.factionMoney=vo.silver;
			factionMoneyTxt.text="当前国库银子：" + MoneyTransformUtil.silverToOtherString(vo.silver);
			
		}
		
		private function createDataProvider(vo:m_waroffaction_warinfo_toc):Array{
			var dataProvider:Array = [];
			var jumaenable:Boolean = true;
			var leftenbale:Boolean = true;
			var rightenable:Boolean = true;
			if (vo.dest_faction_id > 0){
				if (vo.is_attack_faction == false){
					leftenbale = vo.left_guarder_level > 0 ? false : true;
					rightenable = vo.right_guarder_level > 0 ? false : true;
					jumaenable = vo.road_block > 0 ? false : true;
				}
				else{
					jumaenable = false;
					leftenbale = false;
					rightenable = false;
				}
			}else{
				jumaenable = false;
				leftenbale = false;
				rightenable = false;
			}
			var jumaState:String=vo.road_block > 0 ? "已招募" : "未招募";
			var juma:Object={name:"拒马", state:jumaState, cost:"5锭",enabled:jumaenable,pvo:pvo};
			dataProvider.push(juma);
			var obj:Object;
			var leftHandlerState:int = 1;
			if(vo.left_guarder_level > 0){
				leftHandlerState = 0;
			}
			for(var i:int=1;i<=4;i++){
				obj = {};
				obj.name = guardLevels[i] + "级国家卫士（左哨）";
				if(vo.left_guarder_level == i){
					obj.state = "已招募";
				}else{
					obj.state = "未招募";
				}
				obj.cost = FactionWarDataManager.moneys[i] + "锭";
				obj.enabled = leftenbale;
				obj.pvo = pvo;
				dataProvider.push(obj);
			}
			
			for(i=1;i<=4;i++){
				obj = {};
				obj.name = guardLevels[i] + "级国家卫士（右哨）";
				if(vo.right_guarder_level == i){
					obj.state = "已招募";
				}else{
					obj.state = "未招募";
				}
				obj.cost = FactionWarDataManager.moneys[i] + "锭";
				obj.enabled = rightenable;
				obj.pvo = pvo;
				dataProvider.push(obj);
			}
			return dataProvider;
			
		}
		
		public function resetDeclareBtn(abled:Boolean):void
		{
			declareWarBtn1.enabled=abled;
			declareWarBtn2.enabled=abled;
		}
		
		public function updateRecord(vo:m_waroffaction_record_toc):void
		{
			recordView.update(vo.records);
		}
		
		public function closeGuardView():void
		{
			if (otherGuardView != null && otherGuardView.parent != null)
			{
				otherGuardView.parent.removeChild(otherGuardView);
			}
		}
		
		private function toLookRecord(e:MouseEvent):void
		{
			if (recordView == null)
			{
				recordView=new FactionWarRecordView;
			}
			WindowManager.getInstance().popUpWindow(recordView);
			WindowManager.getInstance().centerWindow(recordView);
			this.dispatchEvent(new Event(ASKRECORD_EVENT));
		}
	
		public function get vo():m_waroffaction_warinfo_toc
		{
			return this.pvo;
		}
		
		//向第一个国家宣战
		private function onClickDeclare1(e:MouseEvent):void
		{
			if (this.pvo != null)
			{
				var faction_id:int;
				for (faction_id=1; faction_id <= 3; faction_id++)
				{
					if (faction_id != pvo.faction_id)
					{
						break;
					}
				}
				Alert.show("发动国战消耗10锭国库银子，是否确认发动？", "提示", confirmDeclare, null, "确定", "取消", [faction_id]);
			}
		}
		
		private function confirmDeclare(faction_id:int):void
		{
			var ee:ParamEvent=new ParamEvent(DECLAREWAR_EVENT, faction_id);
			this.dispatchEvent(ee);
		}
		
		//向第二个国家宣战
		private function onClickDeclare2(e:MouseEvent):void
		{
			if (this.pvo != null)
			{
				var faction_id:int;
				for (faction_id=3; faction_id >= 1; faction_id--)
				{
					if (faction_id != pvo.faction_id)
					{
						break;
					}
				}
				Alert.show("发动国战消耗10锭国库银子，是否确认发动？", "提示", confirmDeclare, null, "确定", "取消", [faction_id]);
			}
		}
	}
}